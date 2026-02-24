import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/room_model.dart';

class LanDiscoveryConfig {
  final int broadcastPort;
  final int broadcastIntervalMs;
  final int roomTimeoutSeconds;
  final String magicHeader;

  const LanDiscoveryConfig({
    this.broadcastPort = 37669,
    this.broadcastIntervalMs = 2000,
    this.roomTimeoutSeconds = 10,
    this.magicHeader = 'SYNCRO_DISCOVERY',
  });

  static const LanDiscoveryConfig defaultConfig = LanDiscoveryConfig();
}

class LanDiscoveryMessage {
  final String type;
  final String roomName;
  final String hostName;
  final String ipAddress;
  final int port;
  final int memberCount;
  final int timestamp;

  const LanDiscoveryMessage({
    required this.type,
    required this.roomName,
    required this.hostName,
    required this.ipAddress,
    required this.port,
    this.memberCount = 1,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'roomName': roomName,
      'hostName': hostName,
      'ipAddress': ipAddress,
      'port': port,
      'memberCount': memberCount,
      'timestamp': timestamp,
      'magic': 'SYNCRO_DISCOVERY',
    };
  }

  factory LanDiscoveryMessage.fromJson(Map<String, dynamic> json) {
    return LanDiscoveryMessage(
      type: json['type'] as String,
      roomName: json['roomName'] as String,
      hostName: json['hostName'] as String,
      ipAddress: json['ipAddress'] as String,
      port: json['port'] as int,
      memberCount: json['memberCount'] as int? ?? 1,
      timestamp: json['timestamp'] as int,
    );
  }

  String encode() => jsonEncode(toJson());

  static LanDiscoveryMessage? decode(String data) {
    try {
      final json = jsonDecode(data) as Map<String, dynamic>;
      if (json['magic'] != 'SYNCRO_DISCOVERY') return null;
      return LanDiscoveryMessage.fromJson(json);
    } catch (e) {
      return null;
    }
  }
}

class LanDiscoveryService extends ChangeNotifier {
  final LanDiscoveryConfig _config;
  
  final Map<String, RoomModel> _discoveredRooms = {};
  bool _isScanning = false;
  bool _isBroadcasting = false;
  String? _error;
  bool _isDisposed = false;
  
  RawDatagramSocket? _scanSocket;
  RawDatagramSocket? _broadcastSocket;
  Timer? _broadcastTimer;
  Timer? _cleanupTimer;
  
  static const _methodChannel = MethodChannel('com.syncro.app/multicast');

  LanDiscoveryService({LanDiscoveryConfig? config})
      : _config = config ?? LanDiscoveryConfig.defaultConfig;

  List<RoomModel> get discoveredRooms => _discoveredRooms.values
      .where((room) => !room.isExpired)
      .toList();
  
  bool get isScanning => _isScanning;
  bool get isBroadcasting => _isBroadcasting;
  String? get error => _error;

  Future<void> _acquireMulticastLock() async {
    if (!Platform.isAndroid) return;
    
    try {
      await _methodChannel.invokeMethod('acquireMulticastLock');
      debugPrint('✅ MulticastLock acquired');
    } catch (e) {
      debugPrint('⚠️ Failed to acquire MulticastLock: $e');
    }
  }

  Future<void> _releaseMulticastLock() async {
    if (!Platform.isAndroid) return;
    
    try {
      await _methodChannel.invokeMethod('releaseMulticastLock');
      debugPrint('✅ MulticastLock released');
    } catch (e) {
      debugPrint('⚠️ Failed to release MulticastLock: $e');
    }
  }

  Future<String> _getLocalIpAddress() async {
    try {
      for (final interface in await NetworkInterface.list()) {
        for (final addr in interface.addresses) {
          if (addr.type == InternetAddressType.IPv4 && !addr.isLoopback) {
            return addr.address;
          }
        }
      }
    } catch (e) {
      debugPrint('Error getting local IP: $e');
    }
    return '127.0.0.1';
  }

  Future<String> _getBroadcastAddress() async {
    try {
      final localIp = await _getLocalIpAddress();
      final parts = localIp.split('.');
      if (parts.length == 4) {
        parts[3] = '255';
        return parts.join('.');
      }
    } catch (e) {
      debugPrint('Error getting broadcast address: $e');
    }
    return '255.255.255.255';
  }

  Future<void> startScanning() async {
    if (_isScanning) return;

    _isScanning = true;
    _error = null;
    notifyListeners();

    try {
      // Android需要MulticastLock才能接收UDP广播
      await _acquireMulticastLock();
      
      _scanSocket = await RawDatagramSocket.bind(
        InternetAddress.anyIPv4, 
        _config.broadcastPort,
      );
      _scanSocket!.broadcastEnabled = true;
      
      _scanSocket!.listen((event) {
        if (event == RawSocketEvent.read) {
          final datagram = _scanSocket!.receive();
          if (datagram != null) {
            try {
              final data = String.fromCharCodes(datagram.data);
              final message = LanDiscoveryMessage.decode(data);
              if (message != null) {
                _handleDiscoveredRoom(message);
              }
            } catch (e) {
              // Ignore invalid packets
            }
          }
        }
      });

      _cleanupTimer = Timer.periodic(
        Duration(seconds: _config.roomTimeoutSeconds ~/ 2),
        (_) => _cleanupExpiredRooms(),
      );
      
      debugPrint('Started scanning for rooms on port ${_config.broadcastPort}');
    } catch (e) {
      _error = '启动扫描失败: $e';
      _isScanning = false;
      debugPrint('Error starting scan: $e');
      notifyListeners();
    }
  }

  Future<void> stopScanning() async {
    if (!_isScanning) return;

    _cleanupTimer?.cancel();
    _cleanupTimer = null;
    _scanSocket?.close();
    _scanSocket = null;
    _isScanning = false;
    
    // 释放MulticastLock
    await _releaseMulticastLock();
    
    notifyListeners();
  }

  Future<void> startBroadcasting({
    required String roomName,
    required int port,
  }) async {
    if (_isBroadcasting) return;

    _isBroadcasting = true;
    _error = null;
    notifyListeners();

    try {
      final localIp = await _getLocalIpAddress();
      final broadcastAddress = await _getBroadcastAddress();
      final hostName = Platform.localHostname;

      final message = LanDiscoveryMessage(
        type: 'ROOM_ANNOUNCE',
        roomName: roomName,
        hostName: hostName,
        ipAddress: localIp,
        port: port,
        memberCount: 1,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );

      _broadcastSocket = await RawDatagramSocket.bind(
        InternetAddress.anyIPv4, 
        0,
      );
      _broadcastSocket!.broadcastEnabled = true;

      final data = utf8.encode(message.encode());
      final address = InternetAddress(broadcastAddress);

      _broadcastTimer = Timer.periodic(
        Duration(milliseconds: _config.broadcastIntervalMs),
        (_) {
          _broadcastSocket?.send(data, address, _config.broadcastPort);
        },
      );
      
      debugPrint('Started broadcasting room "$roomName" to $broadcastAddress:${_config.broadcastPort}');
    } catch (e) {
      _error = '启动广播失败: $e';
      _isBroadcasting = false;
      debugPrint('Error starting broadcast: $e');
      notifyListeners();
    }
  }

  Future<void> stopBroadcasting() async {
    if (!_isBroadcasting) return;

    _broadcastTimer?.cancel();
    _broadcastTimer = null;
    _broadcastSocket?.close();
    _broadcastSocket = null;
    _isBroadcasting = false;
    notifyListeners();
  }

  void _handleDiscoveredRoom(LanDiscoveryMessage message) {
    if (_isDisposed) return;
    try {
      final roomId = RoomModel.generateId(message.ipAddress, message.port);
      final existingRoom = _discoveredRooms[roomId];
      final now = DateTime.now();

      // 检查是否需要通知UI更新
      bool shouldNotify = false;
      
      if (existingRoom != null) {
        // 房间已存在，更新 lastSeenAt
        final timeSinceLastUpdate = now.difference(existingRoom.lastSeenAt);
        if (timeSinceLastUpdate.inSeconds >= 3) {
          // 超过3秒，需要更新UI
          shouldNotify = true;
        }
        // 始终更新 lastSeenAt 以防止过期
        _discoveredRooms[roomId] = existingRoom.copyWith(lastSeenAt: now);
      } else {
        // 新房间
        final room = RoomModel(
          id: roomId,
          name: message.roomName,
          hostName: message.hostName,
          ipAddress: message.ipAddress,
          port: message.port,
          memberCount: message.memberCount,
          discoveredAt: now,
          lastSeenAt: now,
        );
        _discoveredRooms[roomId] = room;
        shouldNotify = true;
      }

      if (shouldNotify && !_isDisposed) {
        notifyListeners();
      }
    } catch (e) {
      // Ignore errors
    }
  }

  void _cleanupExpiredRooms() {
    if (_isDisposed) return;
    final before = _discoveredRooms.length;
    _discoveredRooms.removeWhere((_, room) => room.isExpired);
    if (_discoveredRooms.length != before) {
      notifyListeners();
    }
  }

  void clearDiscoveredRooms() {
    if (_isDisposed) return;
    _discoveredRooms.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    stopScanning();
    stopBroadcasting();
    _cleanupTimer?.cancel();
    super.dispose();
  }
}
