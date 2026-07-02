import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/collections_cubit.dart';

/// Opens a bottom sheet that lets the user toggle a quote in/out of each
/// collection and create new collections on the fly.
Future<void> showAddToCollectionSheet(
  BuildContext context, {
  required String quoteId,
}) {
  final cubit = context.read<CollectionsCubit>();
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => BlocProvider.value(
      value: cubit,
      child: _AddToCollectionSheet(quoteId: quoteId),
    ),
  );
}

class _AddToCollectionSheet extends StatefulWidget {
  const _AddToCollectionSheet({required this.quoteId});

  final String quoteId;

  @override
  State<_AddToCollectionSheet> createState() => _AddToCollectionSheetState();
}

class _AddToCollectionSheetState extends State<_AddToCollectionSheet> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Rebuild so the "Create" button enables/disables as the user types.
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged() => setState(() {});

  /// Creates a brand-new collection from the text field, drops the quote in,
  /// then closes the sheet with a confirmation so the user knows it worked.
  Future<void> _createAndAdd() async {
    final name = _controller.text.trim();
    if (name.isEmpty) return;
    // Capture these before the await / pop so we never use a stale context.
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    await context.read<CollectionsCubit>().addQuote(name, widget.quoteId);
    HapticFeedback.selectionClick();
    if (!mounted) return;
    navigator.pop();
    _showResult(messenger, 'Added to “$name”');
  }

  /// Toggles the quote in/out of an existing collection, then closes the sheet
  /// and confirms the change on the screen below.
  void _toggle(String collectionName, bool add) {
    HapticFeedback.selectionClick();
    final cubit = context.read<CollectionsCubit>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    if (add) {
      cubit.addQuote(collectionName, widget.quoteId);
    } else {
      cubit.removeQuote(collectionName, widget.quoteId);
    }
    navigator.pop();
    _showResult(
      messenger,
      add ? 'Added to “$collectionName”' : 'Removed from “$collectionName”',
    );
  }

  void _showResult(ScaffoldMessengerState messenger, String message) {
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final canCreate = _controller.text.trim().isNotEmpty;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + bottomInset),
      child: BlocBuilder<CollectionsCubit, CollectionsState>(
        builder: (context, state) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Add to collection',
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(
                'Tap a collection to add or remove this quote.',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.outline),
              ),
              const SizedBox(height: 8),
              if (state.collections.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'No collections yet. Create your first one below.',
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: theme.colorScheme.outline),
                  ),
                )
              else
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      for (final c in state.collections)
                        CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(c.name),
                          subtitle: Text('${c.length} saved'),
                          value: c.contains(widget.quoteId),
                          onChanged: (checked) =>
                              _toggle(c.name, checked == true),
                        ),
                    ],
                  ),
                ),
              const Divider(),
              Text('Create new collection',
                  style: theme.textTheme.labelLarge),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.done,
                      decoration: const InputDecoration(
                        hintText: 'e.g. Work, Stoic, Favorites',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      onSubmitted: (_) => _createAndAdd(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: canCreate ? _createAndAdd : null,
                    child: const Text('Create'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Done'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
