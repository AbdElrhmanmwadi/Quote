import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/theme/app_theme.dart';
import '../../core/util/bidi.dart';
import '../../data/models/quote.dart';
import '../../features/collections/widgets/add_to_collection_sheet.dart';
import '../../features/favorites/cubit/favorites_cubit.dart';
import '../../features/share/view/share_studio_screen.dart';
import '../../features/similar/view/similar_quotes_screen.dart';
import '../../features/tags/view/tag_quotes_screen.dart';

/// Actions exposed in the card's overflow menu.
enum _QuoteAction {
  copy,
  shareText,
  shareImage,
  addToCollection,
  moreLikeThis,
}

/// Reusable card that renders a single [Quote] with favorite + overflow actions.
///
/// Optionally renders [highlighted] rich text instead of the plain content
/// (used by search to emphasize the matched term).
class QuoteCard extends StatefulWidget {
  const QuoteCard({super.key, required this.quote, this.highlighted});

  final Quote quote;
  final TextSpan? highlighted;

  @override
  State<QuoteCard> createState() => _QuoteCardState();
}

class _QuoteCardState extends State<QuoteCard> {
  Quote get _quote => widget.quote;

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: _quote.shareText));
    await HapticFeedback.selectionClick();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied to clipboard')),
    );
  }

  Future<void> _shareText() => Share.share(_quote.shareText);

  void _openShareStudio() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ShareStudioScreen(quote: _quote)),
    );
  }

  void _openSimilar() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => SimilarQuotesScreen(quote: _quote)),
    );
  }

  void _onAction(_QuoteAction action) {
    switch (action) {
      case _QuoteAction.copy:
        _copy();
      case _QuoteAction.shareText:
        _shareText();
      case _QuoteAction.shareImage:
        _openShareStudio();
      case _QuoteAction.addToCollection:
        showAddToCollectionSheet(context, quoteId: _quote.id);
      case _QuoteAction.moreLikeThis:
        _openSimilar();
    }
  }

  void _openTag(String slug) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TagQuotesScreen(slug: slug, label: _label(slug)),
      ),
    );
  }

  static String _label(String slug) =>
      slug.isEmpty ? slug : '${slug[0].toUpperCase()}${slug.substring(1)}';

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
              color: colors.surfaceContainerHigh,
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              // Flip alignment/direction to match the quote's own language so
              // Arabic reads right-to-left and English left-to-right.
              child: Directionality(
                textDirection: directionOf(_quote.content),
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.format_quote_rounded,
                      size: 32, color: colors.primary),
                  const SizedBox(height: 8),
                  if (widget.highlighted != null)
                    SelectableText.rich(
                      widget.highlighted!,
                      style: AppTheme.quoteStyle(context, text: _quote.content),
                    )
                  else
                    SelectableText(_quote.content,
                        style: AppTheme.quoteStyle(context, text: _quote.content)),
                  const SizedBox(height: 16),
                  Text(
                    '— ${_quote.author}',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  if (_quote.tags.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        for (final tag in _quote.tags.take(3))
                          ActionChip(
                            label: Text(tag),
                            labelStyle: Theme.of(context).textTheme.labelSmall,
                            visualDensity: VisualDensity.compact,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            onPressed: () => _openTag(tag),
                          ),
                      ],
                    ),
                  ],
                ],
                ),
              ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                BlocBuilder<FavoritesCubit, FavoritesState>(
                  buildWhen: (prev, curr) =>
                      prev.ids.contains(_quote.id) !=
                      curr.ids.contains(_quote.id),
                  builder: (context, state) {
                    final isFav = state.ids.contains(_quote.id);
                    return IconButton(
                      tooltip: isFav ? 'Remove favorite' : 'Add to favorites',
                      icon: Icon(
                        isFav ? Icons.favorite : Icons.favorite_border,
                        color: isFav ? colors.error : null,
                      ),
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        context.read<FavoritesCubit>().toggle(_quote.id);
                      },
                    );
                  },
                ),
                PopupMenuButton<_QuoteAction>(
                  tooltip: 'More',
                  icon: const Icon(Icons.more_horiz),
                  onSelected: _onAction,
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: _QuoteAction.copy,
                      child: ListTile(
                        leading: Icon(Icons.copy_outlined),
                        title: Text('Copy'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    PopupMenuItem(
                      value: _QuoteAction.shareText,
                      child: ListTile(
                        leading: Icon(Icons.share_outlined),
                        title: Text('Share'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    PopupMenuItem(
                      value: _QuoteAction.shareImage,
                      child: ListTile(
                        leading: Icon(Icons.image_outlined),
                        title: Text('Create image'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    PopupMenuItem(
                      value: _QuoteAction.addToCollection,
                      child: ListTile(
                        leading: Icon(Icons.collections_bookmark_outlined),
                        title: Text('Add to collection'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    PopupMenuItem(
                      value: _QuoteAction.moreLikeThis,
                      child: ListTile(
                        leading: Icon(Icons.auto_awesome_outlined),
                        title: Text('More like this'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
