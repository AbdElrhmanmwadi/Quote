import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/quote.dart';
import '../../features/favorites/cubit/favorites_cubit.dart';
import '../../features/tags/view/tag_quotes_screen.dart';

/// Actions exposed in the card's overflow menu.
enum _QuoteAction { copy, shareText, shareImage }

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
  // Wraps the quote content so it can be rasterized for "share as image".
  final _boundaryKey = GlobalKey();

  Quote get _quote => widget.quote;

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: _quote.shareText));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied to clipboard')),
    );
  }

  Future<void> _shareText() => Share.share(_quote.shareText);

  Future<void> _shareImage() async {
    try {
      final boundary = _boundaryKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return;
      final image = await boundary.toImage(pixelRatio: 3);
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      if (data == null) return;
      final bytes = data.buffer.asUint8List();
      final dir = await getTemporaryDirectory();
      final file = await File('${dir.path}/quote_${_quote.id}.png')
          .writeAsBytes(bytes, flush: true);
      await Share.shareXFiles([XFile(file.path)], text: _quote.shareText);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not create image')),
      );
    }
  }

  void _onAction(_QuoteAction action) {
    switch (action) {
      case _QuoteAction.copy:
        _copy();
      case _QuoteAction.shareText:
        _shareText();
      case _QuoteAction.shareImage:
        _shareImage();
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
          RepaintBoundary(
            key: _boundaryKey,
            child: Container(
              color: colors.surfaceContainerHigh,
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.format_quote_rounded,
                      size: 32, color: colors.primary),
                  const SizedBox(height: 8),
                  if (widget.highlighted != null)
                    SelectableText.rich(
                      widget.highlighted!,
                      style: AppTheme.quoteStyle(context),
                    )
                  else
                    SelectableText(_quote.content,
                        style: AppTheme.quoteStyle(context)),
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
                      onPressed: () =>
                          context.read<FavoritesCubit>().toggle(_quote.id),
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
                        title: Text('Share as image'),
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
