import 'dart:math';

/// A single document's index and its similarity score to a query.
typedef ScoredIndex = ({int index, double score});

/// A fully offline semantic search / similarity engine.
///
/// This is on-device NLP — no network, no model files, no new dependencies.
/// It represents every document as an L2-normalized **TF-IDF** vector and ranks
/// by **cosine similarity**, so ranking is driven by *meaningful* overlapping
/// terms (rare words weigh more than common ones) instead of raw substring
/// matching. A small concept thesaurus expands queries so that searching
/// "fear" also surfaces quotes about courage, bravery and doubt — matching on
/// intent rather than exact wording.
///
/// Complexity is O(N) per query over the sparse vectors, which is instant for
/// the ~1.6k bundled quotes. The index is built once and reused.
class SemanticIndex {
  SemanticIndex._(this._idf, this._vectors);

  /// Inverse document frequency per vocabulary term.
  final Map<String, double> _idf;

  /// One unit-length sparse TF-IDF vector per document, aligned to input order.
  final List<Map<String, double>> _vectors;

  /// Builds the index from [documents], in order. Each document's text should
  /// combine everything worth matching on (e.g. quote content + author + tags).
  factory SemanticIndex.build(List<String> documents) {
    final n = documents.length;
    final termDocs = <String, int>{}; // document frequency per term
    final termFreqs = <Map<String, int>>[]; // raw term counts per document

    for (final text in documents) {
      final counts = <String, int>{};
      for (final token in _tokenize(text)) {
        counts[token] = (counts[token] ?? 0) + 1;
      }
      termFreqs.add(counts);
      for (final term in counts.keys) {
        termDocs[term] = (termDocs[term] ?? 0) + 1;
      }
    }

    // Smoothed IDF: ln((N + 1) / (df + 1)) + 1 — always positive, damps terms
    // that appear in almost every document.
    final idf = <String, double>{
      for (final e in termDocs.entries)
        e.key: log((n + 1) / (e.value + 1)) + 1,
    };

    final vectors = [
      for (final counts in termFreqs) _normalize(_weigh(counts, idf)),
    ];

    return SemanticIndex._(idf, vectors);
  }

  /// Ranks documents by semantic similarity to [text], best first.
  ///
  /// Only documents with a positive score are returned, capped at [limit].
  /// The query is expanded through the concept thesaurus so related ideas match
  /// even when they share no literal words.
  List<ScoredIndex> query(String text, {int limit = 50}) {
    final queryVector = _normalize(
      _weigh(_expandedCounts(text), _idf),
    );
    if (queryVector.isEmpty) return const [];

    final scored = <ScoredIndex>[];
    for (var i = 0; i < _vectors.length; i++) {
      final score = _cosine(queryVector, _vectors[i]);
      if (score > 0) scored.add((index: i, score: score));
    }
    scored.sort((a, b) => b.score.compareTo(a.score));
    return scored.length > limit ? scored.sublist(0, limit) : scored;
  }

  /// Cosine similarity between two documents already in the index.
  double similarity(int a, int b) => _cosine(_vectors[a], _vectors[b]);

  /// Term counts for a query, including reduced-weight thesaurus expansions so
  /// conceptually related quotes rank even without shared vocabulary.
  Map<String, double> _expandedCounts(String text) {
    final counts = <String, double>{};
    for (final token in _tokenize(text)) {
      counts[token] = (counts[token] ?? 0) + 1;
      for (final related in _thesaurus[token] ?? const <String>[]) {
        // Expansions count for less than words the user actually typed.
        counts[related] = (counts[related] ?? 0) + 0.5;
      }
    }
    return counts;
  }

  static Map<String, double> _weigh(
    Map<String, dynamic> counts,
    Map<String, double> idf,
  ) {
    final vector = <String, double>{};
    counts.forEach((term, tf) {
      final weight = idf[term];
      if (weight != null) vector[term] = (tf as num).toDouble() * weight;
    });
    return vector;
  }

  static Map<String, double> _normalize(Map<String, double> vector) {
    var sumSquares = 0.0;
    for (final v in vector.values) {
      sumSquares += v * v;
    }
    if (sumSquares == 0) return const {};
    final norm = sqrt(sumSquares);
    return {for (final e in vector.entries) e.key: e.value / norm};
  }

  /// Dot product of two unit vectors == cosine similarity. Iterates the smaller
  /// map for speed.
  static double _cosine(Map<String, double> a, Map<String, double> b) {
    final small = a.length <= b.length ? a : b;
    final large = a.length <= b.length ? b : a;
    var dot = 0.0;
    small.forEach((term, weight) {
      final other = large[term];
      if (other != null) dot += weight * other;
    });
    return dot;
  }

  /// Splits [text] into normalized, stemmed terms. Works on both scripts:
  /// Latin text is lowercased and lightly stemmed ("dreams"/"dreaming" →
  /// "dream"); Arabic text is stripped of diacritics, letter-shape–normalized
  /// (أ/إ/آ→ا, ة→ه, ى→ي) and stemmed of clitics like the definite article
  /// "ال" so "الحياة"/"حياتي" collapse to one term. Stopwords and very short
  /// tokens in either language are dropped.
  static Iterable<String> _tokenize(String text) sync* {
    final normalized = _normalizeArabic(text.toLowerCase());
    for (final raw in normalized.split(RegExp(r"[^a-z0-9'ء-ي]+"))) {
      if (raw.isEmpty) continue;
      if (_isArabic(raw)) {
        if (raw.length < 2) continue;
        if (_arabicStopwords.contains(raw)) continue;
        yield _stemArabic(raw);
      } else {
        if (raw.length < 3) continue;
        if (_stopwords.contains(raw)) continue;
        yield _stem(raw);
      }
    }
  }

  static bool _isArabic(String token) {
    final first = token.runes.first;
    return first >= 0x0621 && first <= 0x064a;
  }

  /// Strips Arabic diacritics/tatweel and unifies interchangeable letter shapes
  /// so search is insensitive to tashkeel and spelling variants. Latin text is
  /// untouched.
  static String _normalizeArabic(String text) {
    final buffer = StringBuffer();
    for (final rune in text.runes) {
      // Drop harakat (fatha…sukun), superscript alef, and tatweel.
      if ((rune >= 0x064b && rune <= 0x0652) ||
          rune == 0x0670 ||
          rune == 0x0640) {
        continue;
      }
      var r = rune;
      if (r == 0x0622 || r == 0x0623 || r == 0x0625) r = 0x0627; // آأإ → ا
      if (r == 0x0649) r = 0x064a; // ى → ي
      if (r == 0x0629) r = 0x0647; // ة → ه
      if (r == 0x0624) r = 0x0648; // ؤ → و
      if (r == 0x0626) r = 0x064a; // ئ → ي
      buffer.writeCharCode(r);
    }
    return buffer.toString();
  }

  /// A deliberately conservative suffix stripper — enough to merge common
  /// inflections without a full Porter stemmer's dependencies or surprises.
  static String _stem(String word) {
    if (word.length <= 4) return word;
    for (final suffix in _suffixes) {
      if (word.length - suffix.length >= 3 && word.endsWith(suffix)) {
        return word.substring(0, word.length - suffix.length);
      }
    }
    return word;
  }

  /// Light Arabic stemmer: strips a leading conjunction/preposition + the
  /// definite article, then a common inflectional suffix. Conservative — it
  /// never cuts a stem below three letters.
  static String _stemArabic(String word) {
    var s = word;
    for (final prefix in _arabicPrefixes) {
      if (s.length - prefix.length >= 3 && s.startsWith(prefix)) {
        s = s.substring(prefix.length);
        break;
      }
    }
    for (final suffix in _arabicSuffixes) {
      if (s.length - suffix.length >= 3 && s.endsWith(suffix)) {
        s = s.substring(0, s.length - suffix.length);
        break;
      }
    }
    return s;
  }

  /// Canonicalizes a term the same way [_tokenize] does — used to key the
  /// thesaurus and stopword sets so lookups line up with indexed tokens.
  static String _canonical(String term) {
    final t = _normalizeArabic(term.toLowerCase());
    return _isArabic(t) ? _stemArabic(t) : _stem(t);
  }

  // Ordered longest-first so "ness" strips before "s", etc.
  static const _suffixes = [
    'ness', 'ment', 'tion', 'ing', 'ies', 'ers', 'ed', 'ly', 'er', 's',
  ];

  // Longest-first: strip a wa-/fa-/bi-/ka-/li- clitic plus "ال" before shorter.
  static const _arabicPrefixes = ['وال', 'فال', 'بال', 'كال', 'ال'];
  static const _arabicSuffixes = ['ات', 'ون', 'ين', 'ان', 'ها', 'هم', 'ية', 'ه'];

  static const _stopwords = {
    'the', 'and', 'for', 'are', 'but', 'not', 'you', 'all', 'any', 'can',
    'her', 'was', 'one', 'our', 'out', 'his', 'has', 'had', 'him', 'she',
    'who', 'its', 'did', 'yes', 'get', 'got', 'let', 'now', 'too', 'use',
    'that', 'this', 'with', 'from', 'they', 'have', 'what', 'were', 'when',
    'your', 'them', 'then', 'than', 'into', 'been', 'more', 'will', 'would',
    'there', 'their', 'about', 'which', 'these', 'those', 'because',
  };

  /// Arabic function words, stored already normalized so they match indexed
  /// tokens (e.g. "إلى" and "على" arrive here as "الي"/"علي").
  static final Set<String> _arabicStopwords = {
    for (final w in const [
      'من', 'في', 'على', 'عن', 'إلى', 'أن', 'إن', 'كان', 'قد', 'هذا', 'هذه',
      'ذلك', 'التي', 'الذي', 'ما', 'لا', 'لم', 'لن', 'هو', 'هي', 'هم', 'نحن',
      'أنت', 'كل', 'بعض', 'عند', 'حتى', 'ثم', 'أو', 'يا', 'كما', 'قال', 'به',
      'كنت', 'كانت', 'وقد', 'وما', 'ولا', 'إذا',
    ])
      _normalizeArabic(w),
  };

  /// A compact concept thesaurus keyed by *stemmed* term. Kept small and
  /// quote-flavored on purpose: it bridges the most common theme searches
  /// (fear, love, success, sadness…) so results feel intent-aware while the
  /// whole thing stays offline and dependency-free. Extend freely.
  static final Map<String, List<String>> _thesaurus = _prepThesaurus({
    // English concepts.
    'fear': ['courage', 'brave', 'afraid', 'doubt', 'anxious'],
    'courage': ['fear', 'brave', 'bold', 'strength'],
    'love': ['heart', 'passion', 'compassion', 'kindness'],
    'happiness': ['joy', 'content', 'smile', 'peace', 'gratitude'],
    'sad': ['sorrow', 'grief', 'pain', 'loss', 'lonely'],
    'success': ['achieve', 'goal', 'win', 'accomplish', 'ambition'],
    'failure': ['mistake', 'lose', 'fall', 'defeat'],
    'hope': ['faith', 'dream', 'optimism', 'believe'],
    'wisdom': ['knowledge', 'truth', 'insight', 'learn'],
    'time': ['moment', 'today', 'future', 'past', 'life'],
    'work': ['effort', 'discipline', 'persistence', 'hustle'],
    'change': ['grow', 'transform', 'progress', 'begin'],
    'peace': ['calm', 'stillness', 'serenity', 'mind'],
    'strength': ['power', 'resilience', 'endure', 'strong'],
    'friend': ['friendship', 'trust', 'loyalty', 'together'],
    // Arabic concepts (values expand within Arabic, keeping search offline).
    'خوف': ['شجاعة', 'جرأة', 'قوة', 'إقدام'],
    'شجاعة': ['خوف', 'جرأة', 'إقدام', 'قوة'],
    'حب': ['قلب', 'عشق', 'هوى', 'وفاء'],
    'حياة': ['عيش', 'دنيا', 'وجود', 'أيام'],
    'أمل': ['تفاؤل', 'حلم', 'غد', 'رجاء'],
    'علم': ['معرفة', 'تعلم', 'حكمة', 'دراسة'],
    'حكمة': ['علم', 'معرفة', 'عقل', 'رشد'],
    'نجاح': ['طموح', 'مجد', 'عزم', 'تفوق'],
    'طموح': ['نجاح', 'عزم', 'مجد', 'همة'],
    'صبر': ['احتمال', 'ثبات', 'جلد'],
    'وطن': ['بلاد', 'أرض', 'دار'],
  });

  /// Cross-language concept groups. Every term links to all the others in its
  /// group, in both directions, so an English query surfaces Arabic quotes on
  /// the same idea and vice-versa (e.g. "fear" → خوف, "حكمة" → wisdom). Terms
  /// absent from the corpus simply add no weight, so over-listing is harmless.
  static const _bridge = <List<String>>[
    ['fear', 'courage', 'brave', 'خوف', 'شجاعة', 'جرأة', 'إقدام'],
    ['love', 'حب', 'عشق', 'هوى'],
    ['hope', 'أمل', 'رجاء', 'تفاؤل'],
    ['wisdom', 'حكمة', 'عقل'],
    ['knowledge', 'science', 'learn', 'علم', 'معرفة', 'تعلم'],
    ['life', 'حياة', 'عيش', 'دنيا'],
    ['success', 'ambition', 'نجاح', 'طموح', 'مجد'],
    ['patience', 'صبر', 'ثبات'],
    ['homeland', 'nation', 'وطن', 'بلاد'],
    ['strength', 'power', 'قوة'],
    ['friend', 'friendship', 'صديق', 'صداقة'],
    ['time', 'وقت', 'زمن'],
    ['happiness', 'joy', 'سعادة', 'فرح'],
    ['sad', 'sorrow', 'حزن'],
    ['morals', 'ethics', 'أخلاق'],
  ];

  /// Normalizes and stems every key/value so lookups line up with the tokens
  /// from [_tokenize], regardless of language, then folds in the [_bridge]
  /// groups as bidirectional cross-language links (merged, not overwritten).
  static Map<String, List<String>> _prepThesaurus(
    Map<String, List<String>> raw,
  ) {
    final merged = <String, Set<String>>{};
    void link(String from, String to) {
      if (from == to) return;
      (merged[from] ??= <String>{}).add(to);
    }

    for (final e in raw.entries) {
      final key = _canonical(e.key);
      for (final v in e.value) {
        link(key, _canonical(v));
      }
    }
    for (final group in _bridge) {
      final terms = group.map(_canonical).toSet();
      for (final term in terms) {
        for (final other in terms) {
          link(term, other);
        }
      }
    }

    return {
      for (final e in merged.entries) e.key: e.value.toList(growable: false),
    };
  }
}
