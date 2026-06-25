import 'package:flutter/material.dart';

import '../../core/storage/preferences_service.dart';
import '../../core/theme/app_theme.dart';
import '../../data/repositories/quote_repository.dart';

/// Shows a "Quote of the day" dialog at most once per calendar day.
class DailyQuote {
  const DailyQuote._();

  static Future<void> maybeShow(
    BuildContext context, {
    required QuoteRepository repository,
    required PreferencesService prefs,
  }) async {
    final last = prefs.lastDailyQuoteDate;
    final now = DateTime.now();
    final shownToday = last != null &&
        last.year == now.year &&
        last.month == now.month &&
        last.day == now.day;
    if (shownToday) return;

    await repository.ensureLoaded();
    final quote = repository.randomQuote();
    await prefs.setLastDailyQuoteDate(now);
    if (!context.mounted) return;

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quote of the day'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(quote.content, style: AppTheme.quoteStyle(context)),
            const SizedBox(height: 12),
            Text(
              '— ${quote.author}',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Nice'),
          ),
        ],
      ),
    );
  }
}
