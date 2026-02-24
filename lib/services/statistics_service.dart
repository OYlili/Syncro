import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class StatisticsModel {
  final Duration totalWatchDuration;
  final int roomJoinCount;
  final int videoWatchCount;
  final List<String> recentActivities;
  final DateTime createdAt;
  final DateTime updatedAt;

  const StatisticsModel({
    this.totalWatchDuration = Duration.zero,
    this.roomJoinCount = 0,
    this.videoWatchCount = 0,
    this.recentActivities = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory StatisticsModel.empty() {
    final now = DateTime.now();
    return StatisticsModel(
      createdAt: now,
      updatedAt: now,
    );
  }

  factory StatisticsModel.fromJson(Map<String, dynamic> json) {
    return StatisticsModel(
      totalWatchDuration: Duration(
        milliseconds: json['totalWatchDurationMs'] as int? ?? 0,
      ),
      roomJoinCount: json['roomJoinCount'] as int? ?? 0,
      videoWatchCount: json['videoWatchCount'] as int? ?? 0,
      recentActivities: (json['recentActivities'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalWatchDurationMs': totalWatchDuration.inMilliseconds,
      'roomJoinCount': roomJoinCount,
      'videoWatchCount': videoWatchCount,
      'recentActivities': recentActivities,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  StatisticsModel copyWith({
    Duration? totalWatchDuration,
    int? roomJoinCount,
    int? videoWatchCount,
    List<String>? recentActivities,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StatisticsModel(
      totalWatchDuration: totalWatchDuration ?? this.totalWatchDuration,
      roomJoinCount: roomJoinCount ?? this.roomJoinCount,
      videoWatchCount: videoWatchCount ?? this.videoWatchCount,
      recentActivities: recentActivities ?? this.recentActivities,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get formattedWatchDuration {
    final hours = totalWatchDuration.inHours;
    final minutes = totalWatchDuration.inMinutes.remainder(60);
    if (hours > 0) {
      return '$hours 小时 ${minutes > 0 ? '$minutes 分钟' : ''}';
    }
    return '$minutes 分钟';
  }

  String get formattedWatchDurationShort {
    final hours = totalWatchDuration.inHours;
    if (hours > 0) {
      return '$hours 小时';
    }
    return '${totalWatchDuration.inMinutes} 分钟';
  }
}

class StatisticsService extends ChangeNotifier {
  static const String _keyStatistics = 'statistics_data';
  static const int _maxActivities = 20;

  static StatisticsService? _instance;
  static final _lock = Object();

  StatisticsModel _statistics = StatisticsModel.empty();
  bool _isInitialized = false;
  bool _isLoading = false;
  String? _error;

  StatisticsService._internal();

  factory StatisticsService() {
    if (_instance == null) {
      synchronized(_lock, () {
        _instance ??= StatisticsService._internal();
      });
    }
    return _instance!;
  }

  static StatisticsService get instance => StatisticsService();

  StatisticsModel get statistics => _statistics;
  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Duration get totalWatchDuration => _statistics.totalWatchDuration;
  int get roomJoinCount => _statistics.roomJoinCount;
  int get videoWatchCount => _statistics.videoWatchCount;
  List<String> get recentActivities => _statistics.recentActivities;

  Future<void> initialize() async {
    if (_isInitialized) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString(_keyStatistics);

      if (data != null) {
        try {
          final json = jsonDecode(data) as Map<String, dynamic>;
          _statistics = StatisticsModel.fromJson(json);
        } catch (e) {
          debugPrint('StatisticsService parse error: $e');
          _statistics = StatisticsModel.empty();
        }
      }

      _isInitialized = true;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = '加载统计数据失败: $e';
      _isLoading = false;
      _isInitialized = true;
      debugPrint('StatisticsService initialize error: $e');
      notifyListeners();
    }
  }

  Future<bool> saveTotalWatchDuration(Duration duration) async {
    try {
      _statistics = _statistics.copyWith(
        totalWatchDuration: _statistics.totalWatchDuration + duration,
        updatedAt: DateTime.now(),
      );
      await _saveStatistics();
      notifyListeners();
      return true;
    } catch (e) {
      _error = '保存观看时长失败: $e';
      debugPrint('StatisticsService saveTotalWatchDuration error: $e');
      notifyListeners();
      return false;
    }
  }

  Future<bool> incrementRoomJoinCount() async {
    try {
      _statistics = _statistics.copyWith(
        roomJoinCount: _statistics.roomJoinCount + 1,
        updatedAt: DateTime.now(),
      );
      await _saveStatistics();
      notifyListeners();
      return true;
    } catch (e) {
      _error = '保存房间加入次数失败: $e';
      debugPrint('StatisticsService incrementRoomJoinCount error: $e');
      notifyListeners();
      return false;
    }
  }

  Future<bool> incrementVideoWatchCount() async {
    try {
      _statistics = _statistics.copyWith(
        videoWatchCount: _statistics.videoWatchCount + 1,
        updatedAt: DateTime.now(),
      );
      await _saveStatistics();
      notifyListeners();
      return true;
    } catch (e) {
      _error = '保存视频观看数量失败: $e';
      debugPrint('StatisticsService incrementVideoWatchCount error: $e');
      notifyListeners();
      return false;
    }
  }

  Future<bool> addRecentActivity(String activity) async {
    try {
      final activities = List<String>.from(_statistics.recentActivities);
      activities.insert(0, activity);

      if (activities.length > _maxActivities) {
        activities.removeRange(_maxActivities, activities.length);
      }

      _statistics = _statistics.copyWith(
        recentActivities: activities,
        updatedAt: DateTime.now(),
      );
      await _saveStatistics();
      notifyListeners();
      return true;
    } catch (e) {
      _error = '保存活动记录失败: $e';
      debugPrint('StatisticsService addRecentActivity error: $e');
      notifyListeners();
      return false;
    }
  }

  Future<StatisticsModel> getStatistics() async {
    if (!_isInitialized) {
      await initialize();
    }
    return _statistics;
  }

  Future<bool> clearStatistics() async {
    try {
      _statistics = StatisticsModel.empty();
      await _saveStatistics();
      notifyListeners();
      return true;
    } catch (e) {
      _error = '清除统计数据失败: $e';
      debugPrint('StatisticsService clearStatistics error: $e');
      notifyListeners();
      return false;
    }
  }

  Future<void> _saveStatistics() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyStatistics, jsonEncode(_statistics.toJson()));
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

void synchronized(Object lock, void Function() action) {
  action();
}
