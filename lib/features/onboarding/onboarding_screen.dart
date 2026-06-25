import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/storage/preferences_service.dart';
import '../../data/models/tag.dart';
import '../../data/repositories/quote_repository.dart';
import '../../shell/home_shell.dart';

/// First-run screen where the user picks topics of interest.
///
/// Unlike the old flow (which forced exactly 20 tags yet never used them to
/// filter the feed), selections here are optional and actually drive the feed:
/// pick some topics, or skip to see everything.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _selected = <String>{};
  List<Tag> _tags = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repository = context.read<QuoteRepository>();
    await repository.ensureLoaded();
    if (!mounted) return;
    setState(() {
      _tags = repository.tags();
      _loading = false;
    });
  }

  Future<void> _continue() async {
    final prefs = context.read<PreferencesService>();
    await prefs.setSelectedTags(_selected.toList());
    await prefs.setOnboardingComplete(true);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeShell()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('What inspires you?',
                            style: theme.textTheme.headlineMedium
                                ?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text(
                          'Pick a few topics to personalize your feed. '
                          'You can change this anytime — or skip for all quotes.',
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(color: theme.colorScheme.outline),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
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
                            }),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        TextButton(
                          onPressed: () {
                            _selected.clear();
                            _continue();
                          },
                          child: const Text('Skip'),
                        ),
                        const Spacer(),
                        FilledButton(
                          onPressed: _continue,
                          child: Text(
                            _selected.isEmpty
                                ? 'Continue'
                                : 'Continue (${_selected.length})',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
