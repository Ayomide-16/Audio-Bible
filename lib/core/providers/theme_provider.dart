import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Global theme mode provider - accessible throughout the app
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system) {
    _loadPreference();
  }

  static const String _key = 'theme_mode';

  Future<void> _loadPreference() async {
    final prefs = await SharedPreferences.getInstance();
    final modeIndex = prefs.getInt(_key);
    if (modeIndex != null && modeIndex < ThemeMode.values.length) {
      state = ThemeMode.values[modeIndex];
    }
  }

  Future<void> setMode(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, mode.index);
  }

  void toggleTheme() {
    if (state == ThemeMode.light) {
      setMode(ThemeMode.dark);
    } else if (state == ThemeMode.dark) {
      setMode(ThemeMode.light);
    } else {
      // System mode - toggle to light
      setMode(ThemeMode.light);
    }
  }
}
