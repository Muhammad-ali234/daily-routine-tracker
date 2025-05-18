import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  Color _primaryColor = Colors.deepPurple;
  
  ThemeMode get themeMode => _themeMode;
  Color get primaryColor => _primaryColor;
  
  ThemeProvider() {
    _loadThemePreferences();
  }
  
  Future<void> _loadThemePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final themeModeIndex = prefs.getInt('theme_mode') ?? 0;
    final primaryColorValue = prefs.getInt('primary_color') ?? Colors.deepPurple.value;
    
    _themeMode = ThemeMode.values[themeModeIndex];
    _primaryColor = Color(primaryColorValue);
    
    notifyListeners();
  }
  
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_mode', mode.index);
    
    notifyListeners();
  }
  
  Future<void> setPrimaryColor(Color color) async {
    _primaryColor = color;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('primary_color', color.value);
    
    notifyListeners();
  }
}