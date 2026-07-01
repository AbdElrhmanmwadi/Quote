import 'package:flutter_test/flutter_test.dart';
import 'package:quote/core/util/quote_language.dart';
import 'package:quote/data/models/quote.dart';
import 'package:quote/data/repositories/quote_repository.dart';

void main() {
  const seed = [
    Quote(id: '1', content: 'Alpha wisdom', author: 'Zoe', tags: ['wisdom']),
    Quote(id: '2', content: 'Beta hope', author: 'Amy', tags: ['hope', 'life']),
    Quote(id: '3', content: 'Gamma life', author: 'Bob', tags: ['life']),
    Quote(id: '4', content: 'Delta wisdom', author: 'Amy', tags: ['wisdom']),
  ];

  QuoteRepository repo() => QuoteRepository(seed: seed);

  group('QuoteRepository', () {
    test('tags() counts and sorts by popularity', () {
      final tags = repo().tags();
      expect(tags.first.slug, 'life'); // life appears most (2)
      expect(tags.firstWhere((t) => t.slug == 'life').count, 2);
      expect(tags.firstWhere((t) => t.slug == 'wisdom').label, 'Wisdom');
    });

    test('page() paginates and reports hasReachedMax', () {
      final first = repo().page(page: 1, pageSize: 2);
      expect(first.quotes.map((q) => q.id), ['1', '2']);
      expect(first.hasReachedMax, isFalse);

      final last = repo().page(page: 2, pageSize: 2);
      expect(last.quotes.map((q) => q.id), ['3', '4']);
      expect(last.hasReachedMax, isTrue);
    });

    test('page() filters by tag (match any)', () {
      final page = repo().page(page: 1, pageSize: 10, tagSlugs: ['wisdom']);
      expect(page.quotes.map((q) => q.id), ['1', '4']);
      expect(page.hasReachedMax, isTrue);
    });

    test('byTag() returns all quotes for a slug', () {
      expect(repo().byTag('life').map((q) => q.id), ['2', '3']);
    });

    test('byAuthor() returns all quotes by an author, in order', () {
      expect(repo().byAuthor('Amy').map((q) => q.id), ['2', '4']);
    });

    test('authors() counts and sorts by popularity then name', () {
      final authors = repo().authors();
      expect(authors.first.author, 'Amy'); // Amy has 2, the rest have 1
      expect(authors.first.count, 2);
      expect(authors.map((a) => a.author), containsAll(['Zoe', 'Bob']));
    });

    test('search() matches content and author, case-insensitively', () {
      expect(repo().search('AMY').map((q) => q.id), ['2', '4']);
      expect(repo().search('beta').single.id, '2');
      expect(repo().search('   ').isEmpty, isTrue);
    });

    test('semanticSearch() ranks by relevance and skips blanks', () {
      final hits = repo().semanticSearch('wisdom');
      expect(hits.map((q) => q.id), containsAll(['1', '4'])); // the wisdom quotes
      expect(repo().semanticSearch('   ').isEmpty, isTrue);
    });

    test('smartSearch() keeps exact matches first, then related ones', () {
      final results = repo().smartSearch('wisdom');
      // Exact substring hits ('Alpha wisdom', 'Delta wisdom') lead the list.
      expect(results.take(2).map((q) => q.id), containsAll(['1', '4']));
      // No duplicate ids across the substring + semantic passes.
      final ids = results.map((q) => q.id).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('similar() blends semantic content with tag/author signals', () {
      final source = seed[1]; // 'Beta hope' by Amy, tags hope/life
      final results = repo().similar(source);
      expect(results.map((q) => q.id), isNot(contains('2'))); // excludes self
      expect(results, isNotEmpty);
    });

    test('byIds() resolves and preserves order, skipping unknown', () {
      expect(repo().byIds(['3', '1', 'nope']).map((q) => q.id), ['3', '1']);
    });

    test('randomQuote() can exclude an id', () {
      final r = repo();
      for (var i = 0; i < 25; i++) {
        expect(r.randomQuote(excludeId: '1').id, isNot('1'));
      }
    });
  });

  group('QuoteRepository recommendations', () {
    const recSeed = [
      Quote(id: '1', content: 'courage and bravery win', author: 'A', tags: ['courage']),
      Quote(id: '2', content: 'be brave and bold today', author: 'B', tags: ['courage']),
      Quote(id: '3', content: 'a chocolate cake recipe', author: 'C', tags: ['food']),
    ];

    test('suggests neighbors of favorites and excludes the favorites', () {
      final recs = QuoteRepository(seed: recSeed).recommendations(['1']);
      expect(recs.map((q) => q.id), contains('2'));
      expect(recs.map((q) => q.id), isNot(contains('1')));
      expect(recs.map((q) => q.id), isNot(contains('3'))); // unrelated
    });

    test('returns nothing without favorites', () {
      expect(QuoteRepository(seed: recSeed).recommendations(const []), isEmpty);
    });
  });

  group('QuoteRepository language filter', () {
    const mixed = [
      Quote(id: 'e1', content: 'Alpha wisdom', author: 'Zoe'),
      Quote(id: 'a1', content: 'العلم نور', author: 'المتنبي'),
      Quote(id: 'e2', content: 'Beta hope', author: 'Amy'),
      Quote(id: 'a2', content: 'الصبر مفتاح الفرج', author: 'مثل'),
    ];
    QuoteRepository repo() => QuoteRepository(seed: mixed);

    test('page() returns only Arabic quotes when filtered to arabic', () {
      final page = repo().page(page: 1, pageSize: 10, language: QuoteLanguage.arabic);
      expect(page.quotes.map((q) => q.id), ['a1', 'a2']);
    });

    test('page() returns only English quotes when filtered to english', () {
      final page =
          repo().page(page: 1, pageSize: 10, language: QuoteLanguage.english);
      expect(page.quotes.map((q) => q.id), ['e1', 'e2']);
    });

    test('page() with QuoteLanguage.all returns everything', () {
      final page = repo().page(page: 1, pageSize: 10);
      expect(page.quotes.map((q) => q.id), ['e1', 'a1', 'e2', 'a2']);
    });
  });
}
