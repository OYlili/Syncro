import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppProvider extends ChangeNotifier {
  static const String _keyAutoPlay = 'auto_play';
  static const String _keyHardwareDecoding = 'hardware_decoding';
  static const String _keyDefaultVolume = 'default_volume';
  static const String _keyAutoDiscovery = 'auto_discovery';
  static const String _keySyncDelayCompensation = 'sync_delay_compensation';
  static const String _keyDynamicColor = 'dynamic_color';
  static const String _keyThemeMode = 'theme_mode';

  bool _autoPlay = true;
  bool _hardwareDecoding = true;
  double _defaultVolume = 0.8;
  bool _autoDiscovery = true;
  double _syncDelayCompensation = 100;
  bool _dynamicColor = true;
  ThemeMode _themeMode = ThemeMode.system;

  bool get autoPlay => _autoPlay;
  bool get hardwareDecoding => _hardwareDecoding;
  double get defaultVolume => _defaultVolume;
  bool get autoDiscovery => _autoDiscovery;
  double get syncDelayCompensation => _syncDelayCompensation;
  bool get dynamicColor => _dynamicColor;
  ThemeMode get themeMode => _themeMode;

  AppProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      _autoPlay = prefs.getBool(_keyAutoPlay) ?? true;
      _hardwareDecoding = prefs.getBool(_keyHardwareDecoding) ?? true;
      _defaultVolume = prefs.getDouble(_keyDefaultVolume) ?? 0.8;
      _autoDiscovery = prefs.getBool(_keyAutoDiscovery) ?? true;
      _syncDelayCompensation = prefs.getDouble(_keySyncDelayCompensation) ?? 100;
      _dynamicColor = prefs.getBool(_keyDynamicColor) ?? true;
      
      final themeModeIndex = prefs.getInt(_keyThemeMode) ?? 0;
      if (themeModeIndex >= 0 && themeModeIndex < ThemeMode.values.length) {
        _themeMode = ThemeMode.values[themeModeIndex];
      }
    } catch (e) {
      debugPrint('AppProvider loadSettings error: $e');
    }
    
    notifyListeners();
  }

  Future<void> setAutoPlay(bool value) async {
    _autoPlay = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyAutoPlay, value);
    notifyListeners();
  }

  Future<void> setHardwareDecoding(bool value) async {
    _hardwareDecoding = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyHardwareDecoding, value);
    notifyListeners();
  }

  Future<void> setDefaultVolume(double value) async {
    _defaultVolume = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyDefaultVolume, value);
    notifyListeners();
  }

  Future<void> setAutoDiscovery(bool value) async {
    _autoDiscovery = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyAutoDiscovery, value);
    notifyListeners();
  }

  Future<void> setSyncDelayCompensation(double value) async {
    _syncDelayCompensation = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keySyncDelayCompensation, value);
    notifyListeners();
  }

  Future<void> setDynamicColor(bool value) async {
    _dynamicColor = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyDynamicColor, value);
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode value) async {
    _themeMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyThemeMode, value.index);
    notifyListeners();
  }
}
