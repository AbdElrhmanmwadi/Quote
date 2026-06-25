import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/storage/preferences_service.dart';
import '../../../data/models/tag.dart';
import '../../../data/repositories/quote_repository.dart';
import '../../favorites/cubit/favorites_cubit.dart';
import '../../feed/bloc/feed_bloc.dart';
import '../cubit/theme_cubit.dart';

/// App settings: appearance, interest topics, and data management.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final Set<String> _selected;
  List<Tag> _tags = const [];
  bool _dirty = false;

  @override
  void initState() {
    super.initState();
    final prefs = context.read<PreferencesService>();
    _selected = prefs.selectedTags.toSet();
    _tags = context.read<QuoteRepository>().tags();
  }

  Future<void> _saveInterests() async {
    await context
        .read<PreferencesService>()
        .setSelectedTags(_selected.toList());
    if (!mounted) return;
    // Rebuild the feed with the new topic filter.
    context.read<FeedBloc>().add(const FeedRefreshed());
    setState(() => _dirty = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Interests updated')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          _SectionHeader('Appearance'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: BlocBuilder<ThemeCubit, ThemeMode>(
              builder: (context, mode) {
                return SegmentedButton<ThemeMode>(
                  segments: const [
                    ButtonSegment(
                      value: ThemeMode.system,
                      label: Text('System'),
                      icon: Icon(Icons.brightness_auto),
                    ),
                    ButtonSegment(
                      value: ThemeMode.light,
                      label: Text('Light'),
                      icon: Icon(Icons.light_mode),
                    ),
                    ButtonSegment(
                      value: ThemeMode.dark,
                      label: Text('Dark'),
                      icon: Icon(Icons.dark_mode),
                    ),
                  ],
                  selected: {mode},
                  onSelectionChanged: (s) =>
                      context.read<ThemeCubit>().setMode(s.first),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          _SectionHeader('Your interests'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Choose which topics appear in your feed. '
              'Leave all unselected to see everything.',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.outline),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _tags.map((tag) {
                final isSelected = _selected.contains(tag.slug);
                return FilterChip(
                  label: Text(tag.label),
                  selected: isSelected,
                  onSelected: (value) => setState(() {
                    if (value) {
                      _selected.add(tag.slug);
                    } else {
                      _selected.remove(tag.slug);
                    }
                    _dirty = true;
                  }),
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                onPressed: _dirty ? _saveInterests : null,
                child: const Text('Save interests'),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _SectionHeader('Data'),
          BlocBuilder<FavoritesCubit, FavoritesState>(
            builder: (context, state) {
              return ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('Clear favorites'),
                subtitle: Text('${state.ids.length} saved'),
                enabled: state.ids.isNotEmpty,
                onTap: () => _confirmClearFavorites(context),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _confirmClearFavorites(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear favorites?'),
        content:
            const Text('This removes all saved quotes. It cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<FavoritesCubit>().clearAll();
    }
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}
