import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/services/notification_service.dart';
import '../../../core/storage/preferences_service.dart';
import '../../../data/models/tag.dart';
import '../../../data/repositories/quote_repository.dart';
import '../../favorites/cubit/favorites_cubit.dart';
import '../../feed/bloc/feed_bloc.dart';
import '../../streak/streak_cubit.dart';
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

  late bool _notificationsEnabled;
  late TimeOfDay _reminderTime;
  bool _busyNotifications = false;

  @override
  void initState() {
    super.initState();
    final prefs = context.read<PreferencesService>();
    _selected = prefs.selectedTags.toSet();
    _tags = context.read<QuoteRepository>().tags();
    _notificationsEnabled = prefs.notificationsEnabled;
    _reminderTime =
        TimeOfDay(hour: prefs.notificationHour, minute: prefs.notificationMinute);
  }

  Future<void> _toggleNotifications(bool value) async {
    if (_busyNotifications) return;
    final prefs = context.read<PreferencesService>();
    final service = context.read<NotificationService>();
    // Capture the messenger up front so we never touch `context` after an await.
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busyNotifications = true);
    try {
      if (value) {
        final granted = await service.requestPermission();
        if (!granted) {
          messenger.showSnackBar(
            const SnackBar(
              content: Text(
                  'Notifications are blocked. Enable them in system settings.'),
            ),
          );
          return;
        }
        // Schedule first; only mark the preference on once it actually
        // succeeds, so prefs and the OS never disagree.
        await service.scheduleDaily(_reminderTime.hour, _reminderTime.minute);
        await prefs.setNotificationsEnabled(true);
      } else {
        await service.cancel();
        await prefs.setNotificationsEnabled(false);
      }
      if (!mounted) return;
      setState(() => _notificationsEnabled = value);
    } catch (e) {
      // Surface the failure instead of silently leaving the switch stuck.
      messenger.showSnackBar(
        SnackBar(content: Text("Couldn't update the reminder: $e")),
      );
    } finally {
      if (mounted) setState(() => _busyNotifications = false);
    }
  }

  Future<void> _pickReminderTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
    );
    if (picked == null || !mounted) return;
    final prefs = context.read<PreferencesService>();
    await prefs.setNotificationTime(picked.hour, picked.minute);
    setState(() => _reminderTime = picked);
    if (_notificationsEnabled && mounted) {
      await context
          .read<NotificationService>()
          .scheduleDaily(picked.hour, picked.minute);
    }
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
          _SectionHeader('Your streak'),
          BlocBuilder<StreakCubit, int>(
            builder: (context, streak) {
              return ListTile(
                leading: Icon(Icons.local_fire_department,
                    color: theme.colorScheme.primary),
                title: Text('$streak-day streak'),
                subtitle: Text(streak <= 1
                    ? 'Open the app daily to build your streak.'
                    : 'Keep it going — come back tomorrow!'),
              );
            },
          ),
          const SizedBox(height: 16),
          _SectionHeader('Daily reminder'),
          SwitchListTile(
            secondary: const Icon(Icons.notifications_outlined),
            title: const Text('Daily quote notification'),
            subtitle: const Text('Get a fresh quote once a day.'),
            value: _notificationsEnabled,
            onChanged: _busyNotifications ? null : _toggleNotifications,
          ),
          ListTile(
            leading: const Icon(Icons.schedule_outlined),
            title: const Text('Reminder time'),
            // Always editable: the user can set their preferred time even
            // before turning notifications on. It only reschedules a live
            // reminder when notifications are enabled.
            subtitle: Text(_notificationsEnabled
                ? _reminderTime.format(context)
                : '${_reminderTime.format(context)} · turn on the reminder above'),
            enabled: !_busyNotifications,
            onTap: _pickReminderTime,
          ),
          const SizedBox(height: 16),
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
