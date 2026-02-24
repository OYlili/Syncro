import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/room_model.dart';
import '../services/lan_discovery_service.dart';

enum RoomStatus {
  idle,
  creating,
  hosting,
  joining,
  connected,
  error,
}

class ConnectionTestResult {
  final bool success;
  final String? error;
  final String? errorType;

  ConnectionTestResult({
    required this.success,
    this.error,
    this.errorType,
  });
}

class RoomProvider extends ChangeNotifier {
  final LanDiscoveryService _discoveryService;
  
  RoomStatus _status = RoomStatus.idle;
  RoomModel? _currentRoom;
  String? _videoPath;
  String? _error;
  bool _isScanning = false;
  bool _isDisposed = false;

  RoomProvider({LanDiscoveryService? discoveryService})
      : _discoveryService = discoveryService ?? LanDiscoveryService() {
    _discoveryService.addListener(_onDiscoveryUpdate);
  }

  RoomStatus get status => _status;
  RoomModel? get currentRoom => _currentRoom;
  String? get videoPath => _videoPath;
  String? get error => _error;
  bool get isScanning => _isScanning;
  List<RoomModel> get discoveredRooms => _discoveryService.discoveredRooms;
  bool get isHosting => _status == RoomStatus.hosting;
  bool get isConnected => _status == RoomStatus.connected;

  void _onDiscoveryUpdate() {
    if (_isDisposed) return;
    _isScanning = _discoveryService.isScanning;
    _error = _discoveryService.error;
    notifyListeners();
  }

  Future<String?> pickVideoFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        allowMultiple: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final paths = result.paths.whereType<String>().toList();
        if (paths.isNotEmpty) {
          final firstPath = paths.first;
          final videoFile = File(firstPath);
          if (await videoFile.exists()) {
            _videoPath = firstPath;
            notifyListeners();
            return firstPath;
          }
        }
      }
      return null;
    } catch (e) {
      _error = '选择视频文件失败: $e';
      notifyListeners();
      return null;
    }
  }

  Future<List<String>> pickVideoFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        allowMultiple: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final paths = result.paths.whereType<String>().toList();
        if (paths.isNotEmpty) {
          _videoPath = paths.first;
          notifyListeners();
          return paths;
        }
      }
      return [];
    } catch (e) {
      _error = '选择视频文件失败: $e';
      notifyListeners();
      return [];
    }
  }

  void setVideoPath(String? path) {
    _videoPath = path;
    notifyListeners();
  }

  Future<bool> createRoom({
    required String roomName,
    required int port,
  }) async {
    if (_status == RoomStatus.creating || _status == RoomStatus.hosting) {
      return false;
    }

    _status = RoomStatus.creating;
    _error = null;
    notifyListeners();

    try {
      await _discoveryService.startBroadcasting(
        roomName: roomName,
        port: port,
      );

      _status = RoomStatus.hosting;
      _currentRoom = RoomModel(
        id: 'local',
        name: roomName,
        hostName: '本机',
        ipAddress: 'localhost',
        port: port,
        discoveredAt: DateTime.now(),
        lastSeenAt: DateTime.now(),
      );
      notifyListeners();
      return true;
    } catch (e) {
      _error = '创建房间失败: $e';
      _status = RoomStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> joinRoom(RoomModel room) async {
    if (_status == RoomStatus.joining) {
      return false;
    }

    _status = RoomStatus.joining;
    _error = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 500));
      
      _status = RoomStatus.connected;
      _currentRoom = room;
      notifyListeners();
      return true;
    } catch (e) {
      _error = '加入房间失败: $e';
      _status = RoomStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> joinRoomByAddress({
    required String ipAddress,
    required int port,
  }) async {
    if (_status == RoomStatus.joining) {
      return false;
    }

    _status = RoomStatus.joining;
    _error = null;
    notifyListeners();

    try {
      _status = RoomStatus.connected;
      _currentRoom = RoomModel(
        id: RoomModel.generateId(ipAddress, port),
        name: '远程房间',
        hostName: '远程主机',
        ipAddress: ipAddress,
        port: port,
        discoveredAt: DateTime.now(),
        lastSeenAt: DateTime.now(),
      );
      notifyListeners();
      return true;
    } catch (e) {
      _error = '加入房间失败: $e';
      _status = RoomStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<ConnectionTestResult> testConnection({
    required String ipAddress,
    required int port,
  }) async {
    try {
      final socket = await Socket.connect(
        ipAddress,
        port,
        timeout: const Duration(seconds: 5),
      );
      
      await socket.close();
      
      try {
        final uri = Uri.parse('ws://$ipAddress:$port');
        final channel = WebSocketChannel.connect(uri);
        
        await channel.ready.timeout(const Duration(seconds: 5));
        
        channel.sink.close();
        
        return ConnectionTestResult(success: true);
      } on WebSocketException catch (e) {
        return ConnectionTestResult(
          success: false,
          error: 'WebSocket连接失败: ${e.message}',
          errorType: 'websocket_error',
        );
      } catch (e) {
        return ConnectionTestResult(
          success: false,
          error: 'WebSocket连接异常: $e',
          errorType: 'websocket_error',
        );
      }
    } on SocketException catch (e) {
      String errorMessage;
      String errorType;
      
      if (e.osError?.errorCode == 111 || e.osError?.errorCode == 61) {
        errorMessage = '目标主机拒绝连接，请确认对方已开启房间';
        errorType = 'connection_refused';
      } else if (e.osError?.errorCode == 113) {
        errorMessage = '网络不可达，请检查网络连接';
        errorType = 'network_unreachable';
      } else if (e.osError?.errorCode == 110) {
        errorMessage = '连接超时，请检查IP地址是否正确';
        errorType = 'timeout';
      } else if (e.message.contains('timed out')) {
        errorMessage = '连接超时，请检查IP地址和网络连接';
        errorType = 'timeout';
      } else {
        errorMessage = '网络连接失败: ${e.message}';
        errorType = 'socket_error';
      }
      
      return ConnectionTestResult(
        success: false,
        error: errorMessage,
        errorType: errorType,
      );
    } on TimeoutException {
      return ConnectionTestResult(
        success: false,
        error: '连接超时，请检查IP地址和网络连接',
        errorType: 'timeout',
      );
    } catch (e) {
      return ConnectionTestResult(
        success: false,
        error: '连接异常: $e',
        errorType: 'unknown_error',
      );
    }
  }

  Future<void> leaveRoom() async {
    if (_status == RoomStatus.hosting) {
      await _discoveryService.stopBroadcasting();
    }
    if (_discoveryService.isScanning) {
      await _discoveryService.stopScanning();
    }
    
    _status = RoomStatus.idle;
    _currentRoom = null;
    _videoPath = null;
    _error = null;
    notifyListeners();
  }

  Future<void> reset() async {
    await leaveRoom();
    _discoveryService.clearDiscoveredRooms();
  }

  Future<void> startScanning() async {
    await _discoveryService.startScanning();
  }

  Future<void> stopScanning() async {
    await _discoveryService.stopScanning();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  static String? validateIpAddress(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'IP地址不能为空';
    }
    
    final parts = value.trim().split('.');
    if (parts.length != 4) {
      return 'IP地址格式不正确';
    }
    
    for (final part in parts) {
      final num = int.tryParse(part);
      if (num == null || num < 0 || num > 255) {
        return 'IP地址格式不正确';
      }
    }
    
    return null;
  }

  static String? validatePort(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '端口号不能为空';
    }
    
    final port = int.tryParse(value.trim());
    if (port == null) {
      return '端口号必须是数字';
    }
    
    if (port < 1 || port > 65535) {
      return '端口号必须在1-65535之间';
    }
    
    return null;
  }

  static String? validateRoomName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '房间名称不能为空';
    }
    
    final trimmed = value.trim();
    if (trimmed.length > 32) {
      return '房间名称不能超过32个字符';
    }
    
    return null;
  }

  @override
  void dispose() {
    _isDisposed = true;
    _discoveryService.removeListener(_onDiscoveryUpdate);
    _discoveryService.dispose();
    super.dispose();
  }
}
