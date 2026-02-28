import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/danmaku_settings.dart';

class DanmakuSettingsProvider extends ChangeNotifier {
  static const String _globalConfigKey = 'danmaku_global_config';
  static const String _sendConfigKey = 'danmaku_send_config';
  
  DanmakuGlobalConfig _globalConfig = const DanmakuGlobalConfig();
  DanmakuSendConfig _sendConfig = const DanmakuSendConfig();
  bool _isLoaded = false;

  DanmakuGlobalConfig get globalConfig => _globalConfig;
  DanmakuSendConfig get sendConfig => _sendConfig;
  bool get isLoaded => _isLoaded;
  
  bool get isEnabled => _globalConfig.isEnabled;
  double get speedMultiplier => _globalConfig.speedMultiplier;
  double get opacity => _globalConfig.opacity;
  DanmakuArea get area => _globalConfig.area;
  double get fontSize => _globalConfig.fontSize;
  
  DanmakuColor get sendColor => _sendConfig.color;
  DanmakuPosition get sendPosition => _sendConfig.position;
  int get sendColorValue => _sendConfig.colorValue;

  Future<void> load() async {
    if (_isLoaded) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final globalJsonStr = prefs.getString(_globalConfigKey);
      if (globalJsonStr != null) {
        final json = jsonDecode(globalJsonStr) as Map<String, dynamic>;
        _globalConfig = DanmakuGlobalConfig.fromJson(json);
      }
      
      final sendJsonStr = prefs.getString(_sendConfigKey);
      if (sendJsonStr != null) {
        final json = jsonDecode(sendJsonStr) as Map<String, dynamic>;
        _sendConfig = DanmakuSendConfig.fromJson(json);
      }
      
      _isLoaded = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load danmaku settings: $e');
      _isLoaded = true;
    }
  }

  Future<void> _saveGlobalConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_globalConfigKey, jsonEncode(_globalConfig.toJson()));
    } catch (e) {
      debugPrint('Failed to save danmaku global config: $e');
    }
  }

  Future<void> _saveSendConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_sendConfigKey, jsonEncode(_sendConfig.toJson()));
    } catch (e) {
      debugPrint('Failed to save danmaku send config: $e');
    }
  }

  Future<void> setEnabled(bool enabled) async {
    if (_globalConfig.isEnabled == enabled) return;
    
    _globalConfig = _globalConfig.copyWith(isEnabled: enabled);
    notifyListeners();
    await _saveGlobalConfig();
  }

  Future<void> setSpeed(DanmakuSpeed speed) async {
    if (_globalConfig.speed == speed) return;
    
    _globalConfig = _globalConfig.copyWith(speed: speed);
    notifyListeners();
    await _saveGlobalConfig();
  }

  Future<void> setOpacity(double opacity) async {
    if (_globalConfig.opacity == opacity) return;
    
    _globalConfig = _globalConfig.copyWith(opacity: opacity.clamp(0.0, 1.0));
    notifyListeners();
    await _saveGlobalConfig();
  }

  Future<void> setArea(DanmakuArea area) async {
    if (_globalConfig.area == area) return;
    
    _globalConfig = _globalConfig.copyWith(area: area);
    notifyListeners();
    await _saveGlobalConfig();
  }

  Future<void> setFontSize(double fontSize) async {
    if (_globalConfig.fontSize == fontSize) return;
    
    _globalConfig = _globalConfig.copyWith(fontSize: fontSize.clamp(0.5, 2.0));
    notifyListeners();
    await _saveGlobalConfig();
  }

  Future<void> setSendColor(DanmakuColor color) async {
    debugPrint('🎨 setSendColor called: $color');
    if (_sendConfig.color == color) return;
    
    _sendConfig = _sendConfig.copyWith(color: color);
    debugPrint('🎨 _sendConfig.color: ${_sendConfig.color}, colorValue: 0x${_sendConfig.colorValue.toRadixString(16)}');
    notifyListeners();
    await _saveSendConfig();
  }

  Future<void> setSendPosition(DanmakuPosition position) async {
    if (_sendConfig.position == position) return;
    
    _sendConfig = _sendConfig.copyWith(position: position);
    notifyListeners();
    await _saveSendConfig();
  }

  Future<void> resetGlobalConfig() async {
    _globalConfig = const DanmakuGlobalConfig();
    notifyListeners();
    await _saveGlobalConfig();
  }

  Future<void> resetSendConfig() async {
    _sendConfig = const DanmakuSendConfig();
    notifyListeners();
    await _saveSendConfig();
  }
}
