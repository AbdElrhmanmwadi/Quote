import 'package:flutter_test/flutter_test.dart';
import 'package:quote/core/nlp/semantic_index.dart';

void main() {
  group('SemanticIndex', () {
    final docs = [
      'The only thing we have to fear is fear itself', // 0
      'Courage is being scared but saddling up anyway', // 1
      'A recipe for the perfect chocolate cake', // 2
      'Happiness depends upon ourselves and inner joy', // 3
    ];
    final index = SemanticIndex.build(docs);

    test('ranks the literal match first', () {
      final results = index.query('fear');
      expect(results.first.index, 0);
    });

    test('bridges related concepts via the thesaurus', () {
      // "fear" is not in the courage quote, but expansion should connect them.
      final ranked = index.query('fear').map((r) => r.index).toList();
      expect(ranked, contains(1));
    });

    test('an unrelated query does not match everything', () {
      final ranked = index.query('chocolate').map((r) => r.index).toList();
      expect(ranked.first, 2);
      expect(ranked, isNot(contains(0)));
    });

    test('empty / stopword-only query returns nothing', () {
      expect(index.query('   ').isEmpty, isTrue);
      expect(index.query('the and but').isEmpty, isTrue);
    });

    test('similarity is symmetric and self-similarity is highest', () {
      expect(index.similarity(0, 1), closeTo(index.similarity(1, 0), 1e-9));
      expect(index.similarity(0, 0), greaterThan(index.similarity(0, 2)));
    });

    test('scores are bounded to [0, 1]', () {
      for (final r in index.query('joy and happiness')) {
        expect(r.score, inInclusiveRange(0, 1 + 1e-9));
      }
    });
  });

  group('SemanticIndex (Arabic)', () {
    final docs = [
      'العلم نور والجهل ظلام', // 0
      'من طلب العلا سهر الليالي وطلب المعرفة', // 1
      'وصفة لتحضير كعكة الشوكولاتة', // 2
      'الشجاعة أن تواجه ما تخاف منه', // 3
    ];
    final index = SemanticIndex.build(docs);

    test('matches ignoring diacritics and definite article', () {
      // Query has tashkeel and no "ال"; docs differ — should still match doc 0.
      expect(index.query('عِلم').first.index, 0);
    });

    test('normalizes alef/ya/ta-marbuta spelling variants', () {
      // "المعرفه" (ta marbuta) vs indexed "المعرفة" (ة) must still match doc 1.
      final ranked = index.query('معرفه').map((r) => r.index).toList();
      expect(ranked, contains(1));
    });

    test('thesaurus bridges fear and courage in Arabic', () {
      // "خوف" is not literally in the courage quote; expansion connects them.
      expect(index.query('خوف').map((r) => r.index), contains(3));
    });

    test('an unrelated Arabic query stays unrelated', () {
      expect(index.query('شوكولاتة').first.index, 2);
    });
  });

  group('SemanticIndex (cross-language bridge)', () {
    final docs = [
      'The only thing we have to fear is fear itself', // 0 EN fear
      'A recipe for the perfect chocolate cake', // 1 EN unrelated
      'الشجاعة أن تواجه ما تخاف منه', // 2 AR courage/fear
      'العلم نور والجهل ظلام', // 3 AR knowledge
    ];
    final index = SemanticIndex.build(docs);

    test('English query surfaces Arabic quotes on the same concept', () {
      // "fear" (EN) should reach the Arabic courage/fear quote via the bridge.
      expect(index.query('fear').map((r) => r.index), contains(2));
    });

    test('Arabic query surfaces English quotes on the same concept', () {
      // "خوف" (AR) should reach the English fear quote.
      expect(index.query('خوف').map((r) => r.index), contains(0));
    });

    test('the bridge does not create spurious cross-language matches', () {
      // "knowledge" links to علم (doc 3), never to the chocolate recipe.
      final ranked = index.query('knowledge').map((r) => r.index).toList();
      expect(ranked, contains(3));
      expect(ranked, isNot(contains(1)));
    });
  });
}
