import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/enums/all_enum.dart';

final themeProvider = StateNotifierProvider<ThemeProvider, ThemeEnum>(
  (_) => ThemeProvider(),
);

class ThemeProvider extends StateNotifier<ThemeEnum> {
  final prefsKey = 'isDarkMode';

  ThemeProvider() : super(ThemeEnum.light) {
    // Initial theme setup if needed
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDarkMode = prefs.getBool(prefsKey) ?? true;
    state = isDarkMode ? ThemeEnum.dark : ThemeEnum.light;
  }

  Future<void> toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    if (state == ThemeEnum.light) {
      state = ThemeEnum.dark;
      await prefs.setBool(prefsKey, true);
    } else {
      state = ThemeEnum.light;
      await prefs.setBool(prefsKey, false);
    }
  }
}
