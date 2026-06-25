import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/quote.dart';
import '../../features/favorites/cubit/favorites_cubit.dart';

/// Reusable card that renders a single [Quote] with favorite + share actions.
///
/// Optionally renders [highlighted] rich text instead of the plain content
/// (used by search to emphasize the matched term).
class QuoteCard extends StatelessWidget {
  const QuoteCard({super.key, required this.quote, this.highlighted});

  final Quote quote;
  final TextSpan? highlighted;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.format_quote_rounded, size: 32, color: colors.primary),
            const SizedBox(height: 8),
            if (highlighted != null)
              SelectableText.rich(
                highlighted!,
                style: AppTheme.quoteStyle(context),
              )
            else
              SelectableText(quote.content,
                  style: AppTheme.quoteStyle(context)),
            const SizedBox(height: 16),
            Text(
              '— ${quote.author}',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            if (quote.tags.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  for (final tag in quote.tags.take(3))
                    Chip(
                      label: Text(tag),
                      labelStyle: Theme.of(context).textTheme.labelSmall,
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                ],
              ),
            ],
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                BlocBuilder<FavoritesCubit, FavoritesState>(
                  buildWhen: (prev, curr) =>
                      prev.ids.contains(quote.id) !=
                      curr.ids.contains(quote.id),
                  builder: (context, state) {
                    final isFav = state.ids.contains(quote.id);
                    return IconButton(
                      tooltip: isFav ? 'Remove favorite' : 'Add to favorites',
                      icon: Icon(
                        isFav ? Icons.favorite : Icons.favorite_border,
                        color: isFav ? colors.error : null,
                      ),
                      onPressed: () =>
                          context.read<FavoritesCubit>().toggle(quote.id),
                    );
                  },
                ),
                IconButton(
                  tooltip: 'Share',
                  icon: const Icon(Icons.share_outlined),
                  onPressed: () => Share.share(quote.shareText),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
