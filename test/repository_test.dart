import 'package:flutter_test/flutter_test.dart';
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

    test('search() matches content and author, case-insensitively', () {
      expect(repo().search('AMY').map((q) => q.id), ['2', '4']);
      expect(repo().search('beta').single.id, '2');
      expect(repo().search('   ').isEmpty, isTrue);
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
}
