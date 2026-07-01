import 'package:flutter_test/flutter_test.dart';
import 'package:quote/data/models/quote.dart';

void main() {
  group('Quote.source', () {
    test('parses an optional source and folds it into the attribution', () {
      final q = Quote.fromJson(const {
        '_id': 'b1',
        'content': 'العمل هو الحب وقد صار منظورًا.',
        'author': 'جبران خليل جبران',
        'source': 'النبي',
      });
      expect(q.source, 'النبي');
      expect(q.attribution, 'جبران خليل جبران، النبي');
      expect(q.shareText, contains('— جبران خليل جبران، النبي'));
    });

    test('treats a missing or blank source as null', () {
      final none = Quote.fromJson(const {
        '_id': 'x',
        'content': 'c',
        'author': 'a',
      });
      final blank = Quote.fromJson(const {
        '_id': 'y',
        'content': 'c',
        'author': 'a',
        'source': '   ',
      });
      expect(none.source, isNull);
      expect(blank.source, isNull);
      expect(none.attribution, 'a');
      expect(none.toJson().containsKey('source'), isFalse);
    });
  });
}
