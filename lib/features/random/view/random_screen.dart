import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';

import '../../../shared/widgets/quote_card.dart';
import '../../../shared/widgets/status_view.dart';
import '../cubit/random_cubit.dart';

/// Shows one random quote at a time with a shuffle button.
class RandomScreen extends StatelessWidget {
  const RandomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Random'),
        actions: [
          BlocBuilder<RandomCubit, RandomState>(
            buildWhen: (p, c) => p.quote != c.quote,
            builder: (context, state) {
              final quote = state.quote;
              return IconButton(
                tooltip: 'Share',
                icon: const Icon(Icons.share_outlined),
                onPressed:
                    quote == null ? null : () => Share.share(quote.shareText),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<RandomCubit, RandomState>(
        builder: (context, state) {
          switch (state.status) {
            case RandomStatus.initial:
            case RandomStatus.loading:
              return const Center(child: CircularProgressIndicator());
            case RandomStatus.failure:
              return StatusView(
                icon: Icons.error_outline,
                message: 'Could not load a quote.',
                onRetry: () => context.read<RandomCubit>().shuffle(),
              );
            case RandomStatus.success:
              return Center(
                child: SingleChildScrollView(
                  child: QuoteCard(quote: state.quote!),
                ),
              );
          }
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          HapticFeedback.selectionClick();
          context.read<RandomCubit>().shuffle();
        },
        icon: const Icon(Icons.shuffle),
        label: const Text('Shuffle'),
      ),
    );
  }
}
