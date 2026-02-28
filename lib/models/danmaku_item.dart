import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'danmaku_settings.dart';

class DanmakuItem {
  final String id;
  final String content;
  final String senderName;
  final DateTime createdAt;
  final double speed;
  final int trackIndex;
  final ColorType colorType;
  final Color? customColor;
  final DanmakuPosition position;

  double _progress = 0.0;
  bool _isFinished = false;

  DanmakuItem({
    required this.id,
    required this.content,
    required this.senderName,
    required this.createdAt,
    this.speed = 1.0,
    this.trackIndex = 0,
    this.colorType = ColorType.normal,
    this.customColor,
    this.position = DanmakuPosition.scroll,
  });

  double get progress => _progress;
  bool get isFinished => _isFinished;

  Color get displayColor {
    debugPrint('DanmakuItem: Getting displayColor for $id, customColor: $customColor, colorType: $colorType');
    if (customColor != null) {
      debugPrint('DanmakuItem: Using customColor: $customColor');
      return customColor!;
    }
    final color = Color(colorType.colorValue);
    debugPrint('DanmakuItem: Using colorType color: $color');
    return color;
  }

  void updateProgress(double delta) {
    _progress += delta;
    if (_progress >= 1.0) {
      _progress = 1.0;
      _isFinished = true;
    }
  }

  void markFinished() {
    _isFinished = true;
  }

  static String generateId() {
    return 'danmaku_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(10000)}';
  }
}

enum ColorType {
  normal,
  host,
  system,
}

extension ColorTypeExtension on ColorType {
  int get colorValue {
    switch (this) {
      case ColorType.host:
        return 0xFFFFB800;
      case ColorType.system:
        return 0xFF00BFFF;
      case ColorType.normal:
      default:
        return 0xFFFFFFFF;
    }
  }
}
