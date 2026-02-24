import 'package:flutter/foundation.dart';

enum DanmakuSpeed {
  slow,
  normal,
  fast,
}

enum DanmakuArea {
  full,
  topHalf,
  bottomHalf,
}

enum DanmakuPosition {
  scroll,
  topFixed,
  bottomFixed,
}

enum DanmakuColor {
  white,
  red,
  orange,
  yellow,
  green,
  cyan,
  blue,
  purple,
  pink,
}

class DanmakuGlobalConfig {
  final bool isEnabled;
  final DanmakuSpeed speed;
  final double opacity;
  final DanmakuArea area;
  final double fontSize;

  const DanmakuGlobalConfig({
    this.isEnabled = true,
    this.speed = DanmakuSpeed.normal,
    this.opacity = 1.0,
    this.area = DanmakuArea.full,
    this.fontSize = 1.0,
  });

  double get speedMultiplier {
    switch (speed) {
      case DanmakuSpeed.slow:
        return 0.5;
      case DanmakuSpeed.normal:
        return 1.0;
      case DanmakuSpeed.fast:
        return 1.5;
    }
  }

  DanmakuGlobalConfig copyWith({
    bool? isEnabled,
    DanmakuSpeed? speed,
    double? opacity,
    DanmakuArea? area,
    double? fontSize,
  }) {
    return DanmakuGlobalConfig(
      isEnabled: isEnabled ?? this.isEnabled,
      speed: speed ?? this.speed,
      opacity: opacity ?? this.opacity,
      area: area ?? this.area,
      fontSize: fontSize ?? this.fontSize,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isEnabled': isEnabled,
      'speed': speed.index,
      'opacity': opacity,
      'area': area.index,
      'fontSize': fontSize,
    };
  }

  factory DanmakuGlobalConfig.fromJson(Map<String, dynamic> json) {
    return DanmakuGlobalConfig(
      isEnabled: json['isEnabled'] as bool? ?? true,
      speed: DanmakuSpeed.values[json['speed'] as int? ?? 1],
      opacity: (json['opacity'] as num?)?.toDouble() ?? 1.0,
      area: DanmakuArea.values[json['area'] as int? ?? 0],
      fontSize: (json['fontSize'] as num?)?.toDouble() ?? 1.0,
    );
  }
}

class DanmakuSendConfig {
  final DanmakuColor color;
  final DanmakuPosition position;

  const DanmakuSendConfig({
    this.color = DanmakuColor.white,
    this.position = DanmakuPosition.scroll,
  });

  int get colorValue {
    switch (color) {
      case DanmakuColor.white:
        return 0xFFFFFFFF;
      case DanmakuColor.red:
        return 0xFFFF0000;
      case DanmakuColor.orange:
        return 0xFFFFA500;
      case DanmakuColor.yellow:
        return 0xFFFFFF00;
      case DanmakuColor.green:
        return 0xFF00FF00;
      case DanmakuColor.cyan:
        return 0xFF00FFFF;
      case DanmakuColor.blue:
        return 0xFF0000FF;
      case DanmakuColor.purple:
        return 0xFF800080;
      case DanmakuColor.pink:
        return 0xFFFFC0CB;
    }
  }

  DanmakuSendConfig copyWith({
    DanmakuColor? color,
    DanmakuPosition? position,
  }) {
    return DanmakuSendConfig(
      color: color ?? this.color,
      position: position ?? this.position,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'color': color.index,
      'position': position.index,
    };
  }

  factory DanmakuSendConfig.fromJson(Map<String, dynamic> json) {
    return DanmakuSendConfig(
      color: DanmakuColor.values[json['color'] as int? ?? 0],
      position: DanmakuPosition.values[json['position'] as int? ?? 0],
    );
  }
}
