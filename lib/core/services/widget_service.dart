import 'package:home_widget/home_widget.dart';

import '../../data/repositories/quote_repository.dart';

/// Pushes a quote into the Android home-screen widget.
///
/// The native widget (see `android/.../QuoteWidgetProvider.kt`) reads two keys
/// from shared storage — `widget_quote` and `widget_author` — and renders them.
/// This keeps the Dart side trivial: write the data, ask the OS to redraw.
class WidgetService {
  WidgetService(this._repository);

  final QuoteRepository _repository;

  static const _providerName = 'QuoteWidgetProvider';
  static const _quoteKey = 'widget_quote';
  static const _authorKey = 'widget_author';

  /// Renders a fresh random quote into the widget. Best-effort: failures
  /// (e.g. running on a platform without the widget) are swallowed.
  Future<void> refresh() async {
    try {
      await _repository.ensureLoaded();
      final quote = _repository.randomQuote();
      await HomeWidget.saveWidgetData<String>(_quoteKey, quote.content);
      await HomeWidget.saveWidgetData<String>(_authorKey, '— ${quote.author}');
      await HomeWidget.updateWidget(
        name: _providerName,
        androidName: _providerName,
      );
    } catch (_) {
      // Widget not available on this platform; ignore.
    }
  }
}
