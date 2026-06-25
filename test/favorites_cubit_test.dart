import 'package:flutter_test/flutter_test.dart';
import 'package:quote/core/storage/preferences_service.dart';
import 'package:quote/features/favorites/cubit/favorites_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Future<FavoritesCubit> build({List<String> initial = const []}) async {
    SharedPreferences.setMockInitialValues({'favorite_ids': initial});
    final prefs = await PreferencesService.create();
    return FavoritesCubit(prefs);
  }

  test('hydrates from stored favorites', () async {
    final cubit = await build(initial: ['a', 'b']);
    expect(cubit.state.ids, {'a', 'b'});
    expect(cubit.isFavorite('a'), isTrue);
    expect(cubit.isFavorite('z'), isFalse);
  });

  test('toggle adds then removes and persists', () async {
    final cubit = await build();
    await cubit.toggle('x');
    expect(cubit.state.ids, {'x'});

    // A fresh cubit on the same prefs sees the persisted value.
    final reloaded = await PreferencesService.create();
    expect(reloaded.favoriteIds, ['x']);

    await cubit.toggle('x');
    expect(cubit.state.ids, isEmpty);
  });

  test('clearAll empties favorites', () async {
    final cubit = await build(initial: ['a', 'b', 'c']);
    await cubit.clearAll();
    expect(cubit.state.ids, isEmpty);
    final reloaded = await PreferencesService.create();
    expect(reloaded.favoriteIds, isEmpty);
  });
}
