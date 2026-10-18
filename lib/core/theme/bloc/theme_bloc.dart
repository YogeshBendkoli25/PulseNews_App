import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:traker_task/core/theme/bloc/theme_event.dart';
import 'package:traker_task/core/theme/bloc/theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  static const String _themePrefKey = 'is_dark_mode';
  final SharedPreferences sharedPreferences;

  ThemeBloc({required this.sharedPreferences})
      : super(const ThemeState(themeMode: ThemeMode.system)) {
    on<LoadThemeEvent>(_onLoadTheme);
    on<ToggleThemeEvent>(_onToggleTheme);
  }

  void _onLoadTheme(LoadThemeEvent event, Emitter<ThemeState> emit) {
    final isDark = sharedPreferences.getBool(_themePrefKey);
    if (isDark == null) {
      emit(const ThemeState(themeMode: ThemeMode.system));
    } else {
      emit(ThemeState(themeMode: isDark ? ThemeMode.dark : ThemeMode.light));
    }
  }

  Future<void> _onToggleTheme(
    ToggleThemeEvent event,
    Emitter<ThemeState> emit,
  ) async {
    final newMode =
        state.themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await sharedPreferences.setBool(_themePrefKey, newMode == ThemeMode.dark);
    emit(ThemeState(themeMode: newMode));
  }
}
