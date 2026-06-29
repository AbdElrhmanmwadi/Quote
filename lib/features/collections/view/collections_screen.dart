import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../shared/widgets/status_view.dart';
import '../cubit/collections_cubit.dart';
import 'collection_detail_screen.dart';

/// Lists the user's collections with create / rename / delete actions.
class CollectionsScreen extends StatelessWidget {
  const CollectionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Collections')),
      body: BlocBuilder<CollectionsCubit, CollectionsState>(
        builder: (context, state) {
          if (state.isEmpty) {
            return const StatusView(
              icon: Icons.collections_bookmark_outlined,
              message: 'Group quotes into collections.\n'
                  'Tap + to create your first one.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: state.collections.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final c = state.collections[index];
              return ListTile(
                leading: const Icon(Icons.collections_bookmark_outlined),
                title: Text(c.name),
                subtitle: Text('${c.length} '
                    '${c.length == 1 ? 'quote' : 'quotes'}'),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'rename') {
                      _renameDialog(context, c.name);
                    } else if (value == 'delete') {
                      _deleteDialog(context, c.name);
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'rename', child: Text('Rename')),
                    PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                ),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: context.read<CollectionsCubit>(),
                      child: CollectionDetailScreen(name: c.name),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _createDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('New'),
      ),
    );
  }

  Future<void> _createDialog(BuildContext context) async {
    final name = await _nameDialog(context, title: 'New collection');
    if (name != null && context.mounted) {
      await context.read<CollectionsCubit>().create(name);
    }
  }

  Future<void> _renameDialog(BuildContext context, String current) async {
    final name = await _nameDialog(context,
        title: 'Rename collection', initial: current);
    if (name != null && context.mounted) {
      await context.read<CollectionsCubit>().rename(current, name);
    }
  }

  Future<void> _deleteDialog(BuildContext context, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete "$name"?'),
        content: const Text(
            'The collection is removed. Your favorites are not affected.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<CollectionsCubit>().remove(name);
    }
  }

  Future<String?> _nameDialog(BuildContext context,
      {required String title, String? initial}) {
    final controller = TextEditingController(text: initial);
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(hintText: 'Collection name'),
          onSubmitted: (value) => Navigator.of(context).pop(value.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.of(context).pop(controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
