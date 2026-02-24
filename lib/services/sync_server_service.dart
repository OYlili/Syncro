import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/sync_message.dart';

typedef MessageCallback = void Function(SyncMessage message, dynamic socket);
typedef ConnectionCallback = void Function(RoomUser user, dynamic socket);
typedef DisconnectionCallback = void Function(String userId);
typedef GetRoomStateCallback = SyncMessage Function();

class SyncServerService extends ChangeNotifier {
  final int port;
  HttpServer? _server;
  final Map<String, WebSocket> _connections = {};
  final Map<String, RoomUser> _users = {};
  
  bool _isRunning = false;
  String? _error;
  RoomUser? _hostUser;

  final MessageCallback? onMessage;
  final ConnectionCallback? onConnection;
  final DisconnectionCallback? onDisconnection;
  final GetRoomStateCallback? getRoomStateSnapshot;

  SyncServerService({
    required this.port,
    this.onMessage,
    this.onConnection,
    this.onDisconnection,
    this.getRoomStateSnapshot,
  });

  bool get isRunning => _isRunning;
  String? get error => _error;
  List<RoomUser> get users => _users.values.toList();
  int get connectionCount => _connections.length;
  RoomUser? get hostUser => _hostUser;

  Future<void> start({required String hostId, required String hostName, String? hostAvatar}) async {
    if (_isRunning) return;

    try {
      _server = await HttpServer.bind(InternetAddress.anyIPv4, port);
      _isRunning = true;
      _error = null;
      
      _hostUser = RoomUser(
        id: hostId,
        name: hostName,
        avatarPath: hostAvatar,
        isHost: true,
        joinedAt: DateTime.now(),
      );
      _users[hostId] = _hostUser!;
      
      notifyListeners();

      _server!.listen((HttpRequest request) async {
        if (WebSocketTransformer.isUpgradeRequest(request)) {
          final socket = await WebSocketTransformer.upgrade(request);
          _handleConnection(socket);
        } else {
          request.response.statusCode = HttpStatus.badRequest;
          request.response.close();
        }
      });
    } catch (e) {
      _error = '启动服务器失败: $e';
      _isRunning = false;
      notifyListeners();
    }
  }

  void _handleConnection(WebSocket socket) {
    String? userId;
    
    socket.listen(
      (data) {
        final message = SyncMessage.decode(data.toString());
        if (message == null) return;

        if (message.type == SyncMessageType.join) {
          userId = message.senderId;
          if (userId != null) {
            _connections[userId!] = socket;
            final user = RoomUser(
              id: userId!,
              name: message.senderName ?? '未知用户',
              avatarPath: message.avatarPath,
              isHost: false,
              joinedAt: DateTime.now(),
            );
            _users[userId!] = user;
            
            _broadcastUserList();
            _broadcast(message, excludeUserId: userId);
            
            if (getRoomStateSnapshot != null) {
              final snapshot = getRoomStateSnapshot!();
              sendToUser(userId!, snapshot);
            }
            
            onConnection?.call(user, socket);
            notifyListeners();
          }
        } else if (message.type == SyncMessageType.pong) {
          // Heartbeat response, ignore
        } else {
          onMessage?.call(message, socket);
          
          if (message.type == SyncMessageType.chat) {
            _broadcast(message);
          } else if (userId != null) {
            _broadcast(message, excludeUserId: userId);
          }
        }
      },
      onDone: () {
        if (userId != null) {
          _handleDisconnection(userId!);
        }
      },
      onError: (error) {
        if (userId != null) {
          _handleDisconnection(userId!);
        }
      },
    );
  }

  void _handleDisconnection(String userId) {
    final user = _users[userId];
    _connections.remove(userId);
    _users.remove(userId);
    
    if (user != null) {
      final leaveMessage = SyncMessage.leave(
        userId: userId,
        userName: user.name,
      );
      _broadcast(leaveMessage);
      
      _broadcastUserList();
      onDisconnection?.call(userId);
    }
    
    notifyListeners();
  }

  void _broadcastUserList() {
    final message = SyncMessage.userList(users);
    _broadcast(message);
  }

  void _broadcast(SyncMessage message, {String? excludeUserId}) {
    final encoded = message.encode();
    _connections.forEach((userId, socket) {
      if (userId != excludeUserId && socket.readyState == WebSocket.open) {
        socket.add(encoded);
      }
    });
  }

  void broadcastControl(SyncMessage message) {
    if (!_isRunning) return;
    _broadcast(message);
  }

  void sendToUser(String userId, SyncMessage message) {
    final socket = _connections[userId];
    if (socket != null && socket.readyState == WebSocket.open) {
      socket.add(message.encode());
    }
  }

  Future<void> stop() async {
    if (!_isRunning) return;

    for (final socket in _connections.values) {
      await socket.close();
    }
    _connections.clear();
    _users.clear();
    
    await _server?.close();
    _server = null;
    _isRunning = false;
    _hostUser = null;
    notifyListeners();
  }

  @override
  void dispose() {
    stop();
    super.dispose();
  }
}

class SyncClientService extends ChangeNotifier {
  final String host;
  final int port;
  WebSocket? _socket;
  
  bool _isConnected = false;
  String? _error;
  String? _userId;
  String? _userName;
  List<RoomUser> _users = [];
  
  final MessageCallback? onMessage;
  final VoidCallback? onConnected;
  final VoidCallback? onDisconnected;

  SyncClientService({
    required this.host,
    required this.port,
    this.onMessage,
    this.onConnected,
    this.onDisconnected,
  });

  bool get isConnected => _isConnected;
  String? get error => _error;
  List<RoomUser> get users => _users;
  RoomUser? get hostUser => _users.where((u) => u.isHost).firstOrNull;

  Future<bool> connect({
    required String userId,
    required String userName,
    String? avatarPath,
  }) async {
    if (_isConnected) return true;

    try {
      final uri = Uri.parse('ws://$host:$port');
      _socket = await WebSocket.connect(uri.toString());
      _isConnected = true;
      _error = null;
      _userId = userId;
      _userName = userName;
      
      notifyListeners();

      final joinMessage = SyncMessage.join(
        userId: userId,
        userName: userName,
        avatarPath: avatarPath,
      );
      _socket!.add(joinMessage.encode());

      _socket!.listen(
        (data) {
          final message = SyncMessage.decode(data.toString());
          if (message == null) return;

          if (message.type == SyncMessageType.userlist) {
            final usersData = message.data['users'] as List?;
            if (usersData != null) {
              _users = usersData
                  .map((u) => RoomUser.fromJson(u as Map<String, dynamic>))
                  .toList();
              notifyListeners();
            }
          } else {
            onMessage?.call(message, _socket!);
          }
        },
        onDone: () {
          _handleDisconnection();
        },
        onError: (error) {
          _error = '连接错误: $error';
          _handleDisconnection();
        },
      );

      onConnected?.call();
      return true;
    } catch (e) {
      _error = '连接失败: $e';
      _isConnected = false;
      notifyListeners();
      return false;
    }
  }

  void _handleDisconnection() {
    _isConnected = false;
    _users = [];
    notifyListeners();
    onDisconnected?.call();
  }

  void send(SyncMessage message) {
    if (_socket != null && _socket!.readyState == WebSocket.open) {
      _socket!.add(message.encode());
    }
  }

  void sendChat(String content, {int danmakuColor = 0xFFFFFFFF, int danmakuPosition = 0}) {
    if (_userId == null || _userName == null) return;
    final message = SyncMessage.chat(
      senderId: _userId!,
      senderName: _userName!,
      content: content,
      danmakuColor: danmakuColor,
      danmakuPosition: danmakuPosition,
    );
    send(message);
  }

  Future<void> disconnect() async {
    if (!_isConnected) return;

    if (_userId != null && _userName != null) {
      final leaveMessage = SyncMessage.leave(
        userId: _userId!,
        userName: _userName!,
      );
      send(leaveMessage);
    }

    await _socket?.close();
    _socket = null;
    _isConnected = false;
    _userId = null;
    _userName = null;
    _users = [];
    notifyListeners();
  }

  @override
  void dispose() {
    disconnect();
    super.dispose();
  }
}
