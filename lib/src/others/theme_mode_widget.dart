import 'package:flutter/material.dart';

class ThemeModeWidget extends InheritedNotifier<ValueNotifier<ThemeMode>> {
  ThemeModeWidget({super.key, required super.child}) : super(notifier: ValueNotifier(ThemeMode.system));

  static ThemeModeWidget of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<ThemeModeWidget>()!;

  void setLightMode() {
    notifier!.value = ThemeMode.light;
  }

  void setDarkMode() {
    notifier!.value = ThemeMode.dark;
  }

  void setSystemMode() {
    notifier!.value = ThemeMode.system;
  }

  ThemeMode get themeMode => notifier!.value;
}
