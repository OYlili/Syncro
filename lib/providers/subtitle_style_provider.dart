import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum SubtitleColor {
  white,
  yellow,
  green,
  cyan,
}

class SubtitleStyleSettings {
  final double fontSize;
  final SubtitleColor color;
  final bool showBackground;
  final double opacity;

  const SubtitleStyleSettings({
    this.fontSize = 24,
    this.color = SubtitleColor.white,
    this.showBackground = true,
    this.opacity = 1.0,
  });

  Color get textColor {
    switch (color) {
      case SubtitleColor.white:
        return Colors.white;
      case SubtitleColor.yellow:
        return const Color(0xFFFFFF00);
      case SubtitleColor.green:
        return const Color(0xFF00FF00);
      case SubtitleColor.cyan:
        return const Color(0xFF00FFFF);
    }
  }

  SubtitleStyleSettings copyWith({
    double? fontSize,
    SubtitleColor? color,
    bool? showBackground,
    double? opacity,
  }) {
    return SubtitleStyleSettings(
      fontSize: fontSize ?? this.fontSize,
      color: color ?? this.color,
      showBackground: showBackground ?? this.showBackground,
      opacity: opacity ?? this.opacity,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fontSize': fontSize,
      'color': color.index,
      'showBackground': showBackground,
      'opacity': opacity,
    };
  }

  factory SubtitleStyleSettings.fromJson(Map<String, dynamic> json) {
    return SubtitleStyleSettings(
      fontSize: (json['fontSize'] as num?)?.toDouble() ?? 24,
      color: SubtitleColor.values[json['color'] as int? ?? 0],
      showBackground: json['showBackground'] as bool? ?? true,
      opacity: (json['opacity'] as num?)?.toDouble() ?? 1.0,
    );
  }
}

class SubtitleStyleProvider extends ChangeNotifier {
  static const String _settingsKey = 'subtitle_style_settings';
  
  SubtitleStyleSettings _settings = const SubtitleStyleSettings();
  bool _isLoaded = false;

  SubtitleStyleSettings get settings => _settings;
  bool get isLoaded => _isLoaded;
  
  double get fontSize => _settings.fontSize;
  SubtitleColor get color => _settings.color;
  bool get showBackground => _settings.showBackground;
  double get opacity => _settings.opacity;
  Color get textColor => _settings.textColor;

  Future<void> load() async {
    if (_isLoaded) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_settingsKey);
      
      if (jsonStr != null) {
        final json = jsonDecode(jsonStr) as Map<String, dynamic>;
        _settings = SubtitleStyleSettings.fromJson(json);
      }
      
      _isLoaded = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load subtitle style settings: $e');
      _isLoaded = true;
    }
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_settingsKey, jsonEncode(_settings.toJson()));
    } catch (e) {
      debugPrint('Failed to save subtitle style settings: $e');
    }
  }

  Future<void> setFontSize(double fontSize) async {
    if (_settings.fontSize == fontSize) return;
    
    _settings = _settings.copyWith(fontSize: fontSize.clamp(16, 48));
    notifyListeners();
    await _save();
  }

  Future<void> setColor(SubtitleColor color) async {
    if (_settings.color == color) return;
    
    _settings = _settings.copyWith(color: color);
    notifyListeners();
    await _save();
  }

  Future<void> setShowBackground(bool showBackground) async {
    if (_settings.showBackground == showBackground) return;
    
    _settings = _settings.copyWith(showBackground: showBackground);
    notifyListeners();
    await _save();
  }

  Future<void> setOpacity(double opacity) async {
    if (_settings.opacity == opacity) return;
    
    _settings = _settings.copyWith(opacity: opacity.clamp(0.3, 1.0));
    notifyListeners();
    await _save();
  }

  Future<void> reset() async {
    _settings = const SubtitleStyleSettings();
    notifyListeners();
    await _save();
  }
}
