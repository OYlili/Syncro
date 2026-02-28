import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user_model.dart';
import '../models/user_stats.dart';

class UserProvider extends ChangeNotifier {
  static const String _keyUserData = 'user_data';
  static const String _keyStats = 'user_stats';
  static const String _keyActivities = 'user_activities';

  UserModel _user = UserModel(
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
  
  UserStats _stats = UserStats.empty();
  List<ActivityRecord> _activities = [];

  bool _isLoading = false;
  bool _isInitialized = false;
  String? _error;

  UserModel get user => _user;
  UserStats get stats => _stats;
  List<ActivityRecord> get activities => _activities;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  String? get error => _error;
  String get displayName => _user.nickname;
  String? get avatarPath => _user.avatarPath;

  UserProvider() {
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      
      final userData = prefs.getString(_keyUserData);
      if (userData != null) {
        try {
          final json = jsonDecode(userData) as Map<String, dynamic>;
          _user = UserModel.fromJson(json);
        } catch (e) {
          debugPrint('Error parsing user data: $e');
        }
      }
      
      final statsData = prefs.getString(_keyStats);
      if (statsData != null) {
        try {
          final json = jsonDecode(statsData) as Map<String, dynamic>;
          _stats = UserStats.fromJson(json);
        } catch (e) {
          debugPrint('Error parsing stats data: $e');
        }
      }
      
      final activitiesData = prefs.getString(_keyActivities);
      if (activitiesData != null) {
        try {
          final list = jsonDecode(activitiesData) as List;
          _activities = list
              .map((e) => ActivityRecord.fromJson(e as Map<String, dynamic>))
              .toList();
        } catch (e) {
          debugPrint('Error parsing activities data: $e');
        }
      }
    } catch (e) {
      _error = '加载用户数据失败: $e';
      debugPrint('Error loading user data: $e');
    }

    _isLoading = false;
    _isInitialized = true;
    notifyListeners();
  }

  Future<bool> updateNickname(String nickname) async {
    final validationError = UserModel.validateNickname(nickname);
    if (validationError != null) {
      _error = validationError;
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final sanitized = UserModel.sanitizeNickname(nickname);
      _user = _user.copyWith(
        nickname: sanitized,
        updatedAt: DateTime.now(),
      );
      await _saveUserData();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = '保存昵称失败: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateAvatar(String? avatarPath) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (avatarPath != null) {
        final file = File(avatarPath);
        if (!await file.exists()) {
          _error = '头像文件不存在';
          _isLoading = false;
          notifyListeners();
          return false;
        }
      }

      _user = _user.copyWith(
        avatarPath: avatarPath,
        updatedAt: DateTime.now(),
      );
      await _saveUserData();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = '保存头像失败: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> addWatchTime(int minutes) async {
    _stats = _stats.copyWith(
      totalWatchTimeMinutes: _stats.totalWatchTimeMinutes + minutes,
      updatedAt: DateTime.now(),
    );
    await _saveStats();
    notifyListeners();
  }

  Future<void> incrementRoomsJoined() async {
    _stats = _stats.copyWith(
      totalRoomsJoined: _stats.totalRoomsJoined + 1,
      updatedAt: DateTime.now(),
    );
    await _saveStats();
    notifyListeners();
  }

  Future<void> incrementVideosWatched() async {
    _stats = _stats.copyWith(
      totalVideosWatched: _stats.totalVideosWatched + 1,
      updatedAt: DateTime.now(),
    );
    await _saveStats();
    notifyListeners();
  }

  Future<void> addActivity(ActivityRecord activity) async {
    _activities.insert(0, activity);
    if (_activities.length > 50) {
      _activities = _activities.sublist(0, 50);
    }
    await _saveActivities();
    notifyListeners();
  }

  Future<void> logVideoWatch(String videoName, {int? duration}) async {
    await addActivity(ActivityRecord(
      id: ActivityRecord.generateId(),
      type: 'watch',
      title: '观看了视频',
      subtitle: videoName,
      timestamp: DateTime.now(),
      metadata: {'duration': duration},
    ));
    await incrementVideosWatched();
  }

  Future<void> logRoomJoin(String roomName, {bool isHost = false}) async {
    await addActivity(ActivityRecord(
      id: ActivityRecord.generateId(),
      type: 'join_room',
      title: isHost ? '创建了房间' : '加入了房间',
      subtitle: roomName,
      timestamp: DateTime.now(),
      metadata: {'isHost': isHost},
    ));
    await incrementRoomsJoined();
  }

  Future<void> _saveUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final json = _user.toJson();
    await prefs.setString(_keyUserData, jsonEncode(json));
  }

  Future<void> _saveStats() async {
    final prefs = await SharedPreferences.getInstance();
    final json = _stats.toJson();
    await prefs.setString(_keyStats, jsonEncode(json));
  }

  Future<void> _saveActivities() async {
    final prefs = await SharedPreferences.getInstance();
    final list = _activities.map((e) => e.toJson()).toList();
    await prefs.setString(_keyActivities, jsonEncode(list));
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
