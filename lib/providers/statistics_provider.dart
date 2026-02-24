import 'dart:async';
import 'package:flutter/material.dart';
import '../services/statistics_service.dart';

class StatisticsProvider extends ChangeNotifier {
  final StatisticsService _service;

  StatisticsModel get statistics => _service.statistics;
  Duration get totalWatchDuration => _service.totalWatchDuration;
  int get roomJoinCount => _service.roomJoinCount;
  int get videoWatchCount => _service.videoWatchCount;
  List<String> get recentActivities => _service.recentActivities;
  bool get isLoading => _service.isLoading;
  bool get isInitialized => _service.isInitialized;
  String? get error => _service.error;

  StatisticsProvider({StatisticsService? service})
      : _service = service ?? StatisticsService.instance {
    _service.addListener(_onServiceUpdate);
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      await _service.initialize();
    } catch (e) {
      debugPrint('StatisticsProvider initialize error: $e');
    }
  }

  void _onServiceUpdate() {
    notifyListeners();
  }

  Future<bool> addWatchDuration(Duration duration) async {
    return await _service.saveTotalWatchDuration(duration);
  }

  Future<bool> incrementRoomJoinCount() async {
    return await _service.incrementRoomJoinCount();
  }

  Future<bool> incrementVideoWatchCount() async {
    return await _service.incrementVideoWatchCount();
  }

  Future<bool> addRecentActivity(String activity) async {
    return await _service.addRecentActivity(activity);
  }

  Future<bool> logRoomJoin(String roomName, {bool isHost = false}) async {
    final activity = isHost
        ? '创建了房间 "$roomName"'
        : '加入了房间 "$roomName"';

    final results = await Future.wait([
      incrementRoomJoinCount(),
      addRecentActivity(activity),
    ]);

    return results.every((r) => r);
  }

  Future<bool> logVideoWatch(String videoName, {Duration? duration}) async {
    final activity = duration != null
        ? '观看了 "$videoName" (${_formatDuration(duration)})'
        : '观看了 "$videoName"';

    final results = await Future.wait([
      incrementVideoWatchCount(),
      if (duration != null) addWatchDuration(duration),
      addRecentActivity(activity),
    ]);

    return results.every((r) => r);
  }

  Future<bool> logWatchDuration(Duration duration) async {
    return await addWatchDuration(duration);
  }

  Future<StatisticsModel> getStatistics() async {
    return await _service.getStatistics();
  }

  Future<bool> clearStatistics() async {
    return await _service.clearStatistics();
  }

  void clearError() {
    _service.clearError();
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours > 0) {
      return '$hours小时${minutes > 0 ? '$minutes分钟' : ''}';
    }
    return '$minutes分钟';
  }

  @override
  void dispose() {
    _service.removeListener(_onServiceUpdate);
    super.dispose();
  }
}
