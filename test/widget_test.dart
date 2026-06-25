import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:quote/app.dart';
import 'package:quote/core/storage/preferences_service.dart';
import 'package:quote/data/models/quote.dart';
import 'package:quote/data/repositories/quote_repository.dart';

void main() {
  // A small in-memory dataset so tests never touch rootBundle (the test binding
  // evicts the asset cache between tests, which makes a real asset load hang).
  const seed = [
    Quote(id: '1', content: 'Stay curious.', author: 'Anon', tags: ['wisdom']),
    Quote(
        id: '2', content: 'Keep going.', author: 'Anon', tags: ['motivation']),
  ];

  Future<(PreferencesService, QuoteRepository)> setUpDeps({
    required bool onboarded,
  }) async {
    SharedPreferences.setMockInitialValues({'onboarding_complete': onboarded});
    final prefs = await PreferencesService.create();
    final repository = QuoteRepository(seed: seed);
    return (prefs, repository);
  }

  // Pumps a few bounded frames to let async loads resolve. Avoids
  // `pumpAndSettle`, which never returns while a progress indicator animates.
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  testWidgets('shows the feed when onboarding is complete', (tester) async {
    final (prefs, repository) = await setUpDeps(onboarded: true);

    await tester.pumpWidget(QuoteApp(prefs: prefs, repository: repository));
    await settle(tester);

    // Bottom navigation exposes all three destinations.
    expect(find.text('Quotes'), findsWidgets);
    expect(find.text('Random'), findsOneWidget);
    expect(find.text('Favorites'), findsOneWidget);
    // The seeded quote is rendered in the feed. (SelectableText surfaces its
    // text in both an EditableText and an internal Text, so allow >= 1.)
    expect(find.text('Stay curious.'), findsAtLeastNWidgets(1));
  });

  testWidgets('shows onboarding on first run', (tester) async {
    final (prefs, repository) = await setUpDeps(onboarded: false);

    await tester.pumpWidget(QuoteApp(prefs: prefs, repository: repository));
    await settle(tester);

    expect(find.text('What inspires you?'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
  });
}
