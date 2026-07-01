/// The language filter applied to the quote feed.
///
/// Kept free of any model/Flutter dependency so it can live in [core] and be
/// persisted by name. The actual per-quote matching (which relies on script
/// detection) is done in the repository.
enum QuoteLanguage {
  all('الكل'),
  arabic('عربي'),
  english('English');

  const QuoteLanguage(this.label);

  /// Short, user-facing label for the filter control.
  final String label;
}
