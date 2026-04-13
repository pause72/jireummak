import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'theme_provider.g.dart';

const _kThemeKey = 'theme_mode';

@riverpod
Future<SharedPreferences> sharedPreferences(Ref ref) async {
  return SharedPreferences.getInstance();
}

@riverpod
class ThemeNotifier extends _$ThemeNotifier {
  static const _dark = 'dark';
  static const _light = 'light';

  @override
  ThemeMode build() {
    final prefs = ref.watch(sharedPreferencesProvider).valueOrNull;
    final stored = prefs?.getString(_kThemeKey);
    if (stored == null || stored == 'system') return ThemeMode.system;
    return stored == _dark ? ThemeMode.dark : ThemeMode.light;
  }

  static const _system = 'system';

  void setDark() => _set(ThemeMode.dark);
  void setLight() => _set(ThemeMode.light);
  void setSystem() => _set(ThemeMode.system);

  void _set(ThemeMode mode) {
    state = mode;
    final value = switch (mode) {
      ThemeMode.dark => _dark,
      ThemeMode.light => _light,
      ThemeMode.system => _system,
    };
    ref.read(sharedPreferencesProvider).valueOrNull?.setString(_kThemeKey, value);
  }
}
