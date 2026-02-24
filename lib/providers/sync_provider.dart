import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import '../models/sync_message.dart';
import '../models/chat_message.dart';
import '../models/playlist.dart';
import '../services/sync_server_service.dart';
import '../services/video_stream_server.dart';
import 'subtitle_provider.dart';
import 'audio_track_provider.dart';
import 'player_provider.dart';

enum SyncRole { host, client, none }

class SyncProvider extends ChangeNotifier {
  SyncRole _role = SyncRole.none;
  SyncServerService? _server;
  SyncClientService? _client;
  VideoStreamServer? _videoServer;
  
  Player? _player;
  PlayerProvider? _playerProvider;
  SubtitleProvider? _subtitleProvider;
  AudioTrackProvider? _audioTrackProvider;
  String? _userId;
  String? _userName;
  String? _userAvatar;
  String? _currentVideoUrl;
  String? _connectedHostIp;
  
  final List<ChatMessage> _chatMessages = [];
  List<RoomUser> _users = [];
  
  VideoPlaylist _playlist = const VideoPlaylist();
  final Map<int, String> _videoPaths = {};
  String? _externalSubtitlePath;
  String? _externalSubtitleUrl;
  
  bool _isConnected = false;
  String? _error;
  bool _isRemoteControl = false;
  
  double _currentSyncRate = 1.0;
  Timer? _syncRateDebounceTimer;
  DateTime? _lastSyncTime;
  static const int _syncDebounceMs = 500;

  SyncRole get role => _role;
  bool get isConnected => _isConnected;
  String? get error => _error;
  List<ChatMessage> get chatMessages => _chatMessages;
  List<RoomUser> get users => _users;
  int get userCount => _users.length;
  bool get isHost => _role == SyncRole.host;
  bool get isClient => _role == SyncRole.client;
  String? get currentVideoUrl => _currentVideoUrl;
  bool get isVideoServerRunning => _videoServer?.isRunning ?? false;
  String? get userId => _userId;
  VideoPlaylist get playlist => _playlist;
  int get currentPlaylistIndex => _playlist.currentIndex;
  String? get externalSubtitleUrl => _externalSubtitleUrl;
  String? get externalSubtitlePath => _externalSubtitlePath;

  void setPlayer(Player player) {
    _player = player;
  }

  void setProviders({
    PlayerProvider? playerProvider,
    SubtitleProvider? subtitleProvider,
    AudioTrackProvider? audioTrackProvider,
  }) {
    _playerProvider = playerProvider;
    _subtitleProvider = subtitleProvider;
    _audioTrackProvider = audioTrackProvider;
  }

  SyncMessage _getRoomStateSnapshot() {
    final playlistJson = _playlist.items.map((item) {
      return {
        'id': item.id,
        'name': item.name,
        'url': _currentVideoUrl,
      };
    }).toList();

    final subtitleSnapshot = _subtitleProvider?.toSnapshot() ?? {};
    final audioSnapshot = _audioTrackProvider?.toSnapshot() ?? {};

    return SyncMessage.roomStateSnapshot(
      playlist: playlistJson,
      currentIndex: _playlist.currentIndex,
      subtitleTracks: subtitleSnapshot['subtitleTracks'] as List<Map<String, dynamic>>? ?? [],
      currentSubtitleId: subtitleSnapshot['currentSubtitleId'] as String?,
      audioTracks: audioSnapshot['audioTracks'] as List<Map<String, dynamic>>? ?? [],
      currentAudioId: audioSnapshot['currentAudioId'] as String?,
      externalSubtitleUrl: _externalSubtitleUrl,
      position: _player?.state.position.inSeconds ?? 0,
      isPaused: !(_player?.state.playing ?? false),
    );
  }

  void hydrateFromSnapshot(Map<String, dynamic> snapshot) {
    final playlistJson = snapshot['playlist'] as List<dynamic>?;
    final currentIndex = snapshot['currentIndex'] as int?;

    if (playlistJson != null) {
      final items = playlistJson.map((json) {
        final map = json as Map<String, dynamic>;
        return PlaylistItem(
          id: map['id'] as int? ?? 0,
          name: map['name'] as String? ?? '未知视频',
          path: '',
          addedAt: DateTime.now(),
        );
      }).toList();
      _playlist = VideoPlaylist(
        items: items,
        currentIndex: currentIndex ?? -1,
      );
    }

    if (_subtitleProvider != null) {
      _subtitleProvider!.hydrateFromSnapshot(snapshot);
    }

    if (_audioTrackProvider != null) {
      _audioTrackProvider!.hydrateFromSnapshot(snapshot);
    }

    final externalUrl = snapshot['externalSubtitleUrl'] as String?;
    if (externalUrl != null) {
      _externalSubtitleUrl = externalUrl;
    }

    notifyListeners();
  }

  void broadcastPlaylistUpdate() {
    if (_role != SyncRole.host || _server == null) return;
    final playlistJson = _playlist.items.map((item) {
      return {
        'id': item.id,
        'name': item.name,
        'url': _currentVideoUrl,
      };
    }).toList();
    final message = SyncMessage.playlistUpdate(playlistJson, _playlist.currentIndex);
    _server!.broadcastControl(message);
  }

  void broadcastSubtitleExternalAdd(String httpUrl, String label) {
    if (_role != SyncRole.host || _server == null) return;
    final message = SyncMessage.subtitleExternalAdd(httpUrl, label);
    _server!.broadcastControl(message);
  }

  void broadcastSubtitleSelect(String trackId) {
    if (_role != SyncRole.host || _server == null) return;
    final message = SyncMessage.subtitleSelect(trackId);
    _server!.broadcastControl(message);
  }

  void broadcastAudioSelect(String trackId) {
    if (_role != SyncRole.host || _server == null) return;
    final message = SyncMessage.audioSelect(trackId);
    _server!.broadcastControl(message);
  }

  Future<void> startHosting({
    required int port,
    required String userId,
    required String userName,
    String? userAvatar,
  }) async {
    if (_role != SyncRole.none) return;
    
    _userId = userId;
    _userName = userName;
    _userAvatar = userAvatar;
    
    _server = SyncServerService(
      port: port,
      onMessage: _handleServerMessage,
      onConnection: _handleUserConnected,
      onDisconnection: _handleUserDisconnected,
      getRoomStateSnapshot: _getRoomStateSnapshot,
    );
    
    await _server!.start(
      hostId: userId,
      hostName: userName,
      hostAvatar: userAvatar,
    );
    
    _role = SyncRole.host;
    _isConnected = _server!.isRunning;
    _users = _server!.users;
    
    _addSystemMessage('房间已创建，等待其他用户加入...');
    notifyListeners();
  }

  Future<void> joinRoom({
    required String host,
    required int port,
    required String userId,
    required String userName,
    String? userAvatar,
  }) async {
    if (_role != SyncRole.none) return;
    
    _userId = userId;
    _userName = userName;
    _userAvatar = userAvatar;
    
    // 保存连接时使用的 host IP，用于替换视频流 URL
    _connectedHostIp = host;
    
    _client = SyncClientService(
      host: host,
      port: port,
      onMessage: _handleClientMessage,
      onConnected: () {
        _isConnected = true;
        _addSystemMessage('已连接到房间');
        notifyListeners();
      },
      onDisconnected: () {
        _isConnected = false;
        _addSystemMessage('已断开连接');
        notifyListeners();
      },
    );
    
    final success = await _client!.connect(
      userId: userId,
      userName: userName,
      avatarPath: userAvatar,
    );
    
    if (success) {
      _role = SyncRole.client;
      _isConnected = true;
    } else {
      _error = _client!.error ?? '连接失败';
    }
    
    notifyListeners();
  }

  void _handleServerMessage(SyncMessage message, dynamic socket) {
    switch (message.type) {
      case SyncMessageType.chat:
        _addChatMessage(
          senderId: message.senderId ?? '',
          senderName: message.senderName ?? '未知用户',
          content: message.content ?? '',
          avatarPath: message.avatarPath,
          isHost: message.isHost,
          danmakuColor: message.danmakuColor,
          danmakuPosition: message.danmakuPosition,
        );
        break;
      default:
        break;
    }
  }

  void _handleClientMessage(SyncMessage message, dynamic socket) {
    if (_player == null) {
      // 对于 videoUrl 消息，即使 player 为 null 也应该处理
      if (message.type == SyncMessageType.videoUrl) {
        _handleVideoUrl(message);
      }
      return;
    }
    
    _isRemoteControl = true;
    
    switch (message.type) {
      case SyncMessageType.play:
        if (message.positionMs != null) {
          handleSyncInstruction(
            Duration(milliseconds: message.positionMs!),
            true,
          );
        } else {
          _player!.play();
        }
        _addSystemMessage('房主开始播放');
        break;
        
      case SyncMessageType.pause:
        if (message.positionMs != null) {
          handleSyncInstruction(
            Duration(milliseconds: message.positionMs!),
            false,
          );
        } else {
          _player!.pause();
        }
        _addSystemMessage('房主暂停播放');
        break;
        
      case SyncMessageType.seek:
        if (message.positionMs != null) {
          _player!.seek(Duration(milliseconds: message.positionMs!));
        }
        break;
        
      case SyncMessageType.speed:
        if (message.speed != null) {
          _player!.setRate(message.speed!);
        }
        break;
        
      case SyncMessageType.volume:
        if (message.volume != null) {
          _player!.setVolume(message.volume!);
        }
        break;
        
      case SyncMessageType.sync:
        _handleFullSync(message);
        break;
        
      case SyncMessageType.chat:
        _addChatMessage(
          senderId: message.senderId ?? '',
          senderName: message.senderName ?? '未知用户',
          content: message.content ?? '',
          avatarPath: message.avatarPath,
          isHost: message.isHost,
          danmakuColor: message.danmakuColor,
          danmakuPosition: message.danmakuPosition,
        );
        break;
        
      case SyncMessageType.join:
        _addSystemMessage('${message.senderName} 加入了房间');
        break;
        
      case SyncMessageType.leave:
        _addSystemMessage('${message.senderName} 离开了房间');
        break;
        
      case SyncMessageType.userlist:
        final usersData = message.data['users'] as List?;
        if (usersData != null) {
          _users = usersData
              .map((u) => RoomUser.fromJson(u as Map<String, dynamic>))
              .toList();
          notifyListeners();
        }
        break;
        
      case SyncMessageType.videoUrl:
        _handleVideoUrl(message);
        break;
        
      case SyncMessageType.playlist:
        _handlePlaylistMessage(message);
        break;
        
      case SyncMessageType.switchEpisode:
        _handleSwitchEpisodeMessage(message);
        break;
        
      case SyncMessageType.loadExtSub:
        _handleLoadExtSubMessage(message);
        break;
        
      case SyncMessageType.clearExtSub:
        _handleClearExtSubMessage(message);
        break;
        
      case SyncMessageType.playlistSync:
        _handlePlaylistSyncMessage(message);
        break;
        
      case SyncMessageType.roomStateSnapshot:
        _handleRoomStateSnapshot(message);
        break;
        
      case SyncMessageType.playlistUpdate:
        _handlePlaylistUpdateMessage(message);
        break;
        
      case SyncMessageType.subtitleExternalAdd:
        _handleSubtitleExternalAdd(message);
        break;
        
      case SyncMessageType.subtitleSelect:
        _handleSubtitleSelect(message);
        break;
        
      case SyncMessageType.audioSelect:
        _handleAudioSelect(message);
        break;
        
      default:
        break;
    }
    
    Future.delayed(const Duration(milliseconds: 100), () {
      _isRemoteControl = false;
    });
  }

  void _syncPositionWithCorrection(int targetPositionMs) {
    if (_player == null) return;
    
    final currentPositionMs = _player!.state.position.inMilliseconds;
    final difference = (currentPositionMs - targetPositionMs).abs();
    
    if (difference > 2000) {
      _player!.seek(Duration(milliseconds: targetPositionMs));
      debugPrint('进度纠偏: 差距 ${difference}ms，已同步到 ${targetPositionMs}ms');
    }
  }

  void handleSyncInstruction(Duration hostPosition, bool isHostPlaying) {
    if (_player == null) return;
    
    final localPosition = _player!.state.position;
    final deltaMs = hostPosition.inMilliseconds - localPosition.inMilliseconds;
    final deltaAbs = deltaMs.abs();
    
    if (!isHostPlaying) {
      _currentSyncRate = 1.0;
      _player!.pause();
      if (deltaAbs > 500) {
        _player!.seek(hostPosition);
        debugPrint('⏸️ 房主暂停，同步位置: ${hostPosition.inSeconds}s');
      }
      return;
    }
    
    if (!_player!.state.playing) {
      _player!.play();
    }
    
    if (deltaAbs > 3000) {
      _player!.seek(hostPosition);
      _currentSyncRate = 1.0;
      _player!.setRate(1.0);
      debugPrint('⚡ 强制跳跃: 差距 ${deltaMs}ms');
      return;
    }
    
    double targetRate = 1.0;
    String action = '';
    
    if (deltaMs >= 500 && deltaMs < 3000) {
      targetRate = 1.1;
      action = '追赶房主';
    } else if (deltaMs <= -500) {
      targetRate = 0.9;
      action = '等候房主';
    } else {
      targetRate = 1.0;
      action = '已对齐';
    }
    
    if (targetRate != _currentSyncRate) {
      final now = DateTime.now();
      final shouldUpdate = _lastSyncTime == null || 
          now.difference(_lastSyncTime!).inMilliseconds > _syncDebounceMs;
      
      if (shouldUpdate) {
        _syncRateDebounceTimer?.cancel();
        _syncRateDebounceTimer = Timer(const Duration(milliseconds: 300), () {
          if (_player != null && targetRate != _currentSyncRate) {
            _player!.setRate(targetRate);
            _currentSyncRate = targetRate;
            _lastSyncTime = DateTime.now();
            debugPrint('🔄 $action: 速率 $targetRate, delta ${deltaMs}ms');
          }
        });
      }
    } else if (targetRate == 1.0 && _currentSyncRate != 1.0) {
      _player!.setRate(1.0);
      _currentSyncRate = 1.0;
      debugPrint('✅ 恢复正常速率: delta ${deltaMs}ms');
    }
  }

  void _handleFullSync(SyncMessage message) {
    if (_player == null) return;
    
    final positionMs = message.positionMs;
    final isPlaying = message.isPlaying;
    final volume = message.volume;
    
    if (positionMs != null && isPlaying != null) {
      handleSyncInstruction(
        Duration(milliseconds: positionMs),
        isPlaying,
      );
    } else {
      if (positionMs != null) {
        _syncPositionWithCorrection(positionMs);
      }
      if (isPlaying == true) {
        _player!.play();
      } else {
        _player!.pause();
      }
    }
    
    if (volume != null) {
      _player!.setVolume(volume);
    }
  }

  void _handleVideoUrl(SyncMessage message) {
    final originalUrl = message.videoUrl;
    final videoName = message.videoName;
    
    if (originalUrl != null) {
      // 客户端需要替换 URL 中的 IP 为连接时使用的 IP
      String finalUrl = originalUrl;
      
      if (_role == SyncRole.client && _connectedHostIp != null) {
        finalUrl = _replaceVideoUrlHost(originalUrl, _connectedHostIp!);
        if (finalUrl != originalUrl) {
          debugPrint('🔄 Video URL replaced: $originalUrl -> $finalUrl');
        }
      }
      
      _currentVideoUrl = finalUrl;
      _addSystemMessage('房主分享了视频${videoName != null ? ": $videoName" : ""}');
      notifyListeners();
    }
  }
  
  /// 替换视频流 URL 中的 Host IP
  /// 用于支持 VPN/ZeroTier 等虚拟局域网环境
  String _replaceVideoUrlHost(String originalUrl, String newHostIp) {
    try {
      final uri = Uri.parse(originalUrl);
      
      // 构建新的 URL，保留原有的端口和路径
      final newUri = Uri(
        scheme: uri.scheme,
        host: newHostIp,
        port: uri.port,
        path: uri.path,
        query: uri.query,
        fragment: uri.fragment,
      );
      
      return newUri.toString();
    } catch (e) {
      debugPrint('❌ Error replacing video URL host: $e');
      return originalUrl; // 解析失败时返回原始 URL
    }
  }

  void _handleUserConnected(RoomUser user, dynamic socket) {
    _users = _server?.users ?? [];
    _addSystemMessage('${user.name} 加入了房间');
    
    if (_currentVideoUrl != null) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (_server != null && _currentVideoUrl != null) {
          final message = SyncMessage.videoUrl(_currentVideoUrl!, videoName: null);
          _server!.broadcastControl(message);
        }
      });
    }
    
    notifyListeners();
  }

  void _handleUserDisconnected(String userId) {
    _users = _server?.users ?? [];
    notifyListeners();
  }

  void broadcastPlay({int? positionMs}) {
    if (_role != SyncRole.host || _server == null) return;
    if (_isRemoteControl) return;
    
    final message = SyncMessage.play(positionMs: positionMs);
    _server!.broadcastControl(message);
  }

  void broadcastPause({int? positionMs}) {
    if (_role != SyncRole.host || _server == null) return;
    if (_isRemoteControl) return;
    
    final message = SyncMessage.pause(positionMs: positionMs);
    _server!.broadcastControl(message);
  }

  void broadcastSeek(int positionMs) {
    if (_role != SyncRole.host || _server == null) return;
    if (_isRemoteControl) return;
    
    final message = SyncMessage.seek(positionMs);
    _server!.broadcastControl(message);
  }

  void broadcastSpeed(double speed) {
    if (_role != SyncRole.host || _server == null) return;
    if (_isRemoteControl) return;
    
    final message = SyncMessage.speed(speed);
    _server!.broadcastControl(message);
  }

  void broadcastVolume(double volume) {
    if (_role != SyncRole.host || _server == null) return;
    if (_isRemoteControl) return;
    
    final message = SyncMessage.volume(volume);
    _server!.broadcastControl(message);
  }

  Future<bool> startVideoStream(String videoPath, {String? videoName}) async {
    if (_role != SyncRole.host) return false;
    
    _videoServer ??= VideoStreamServer();
    
    final success = await _videoServer!.start(videoPath);
    if (success) {
      _currentVideoUrl = _videoServer!.videoUrl;
      broadcastVideoUrl(videoName);
      _addSystemMessage('视频流服务已启动');
      notifyListeners();
    }
    return success;
  }

  Future<void> stopVideoStream() async {
    if (_videoServer != null) {
      await _videoServer!.stop();
      _currentVideoUrl = null;
      notifyListeners();
    }
  }

  void broadcastVideoUrl(String? videoName) {
    if (_role != SyncRole.host || _server == null) return;
    if (_currentVideoUrl == null) return;
    
    final message = SyncMessage.videoUrl(_currentVideoUrl!, videoName: videoName);
    _server!.broadcastControl(message);
  }

  void sendChat(String content, {int? danmakuColor, int? danmakuPosition}) {
    if (content.trim().isEmpty) return;
    
    final color = danmakuColor ?? 0xFFFFFFFF;
    final position = danmakuPosition ?? 0;
    
    if (_role == SyncRole.host && _server != null) {
      final message = SyncMessage.chat(
        senderId: _userId!,
        senderName: _userName!,
        content: content,
        avatarPath: _userAvatar,
        isHost: true,
        danmakuColor: color,
        danmakuPosition: position,
      );
      _server!.broadcastControl(message);
      _addChatMessage(
        senderId: _userId!,
        senderName: _userName!,
        content: content,
        avatarPath: _userAvatar,
        isHost: true,
        danmakuColor: color,
        danmakuPosition: position,
      );
    } else if (_role == SyncRole.client && _client != null) {
      _client!.sendChat(content, danmakuColor: color, danmakuPosition: position);
    }
  }

  Future<bool> setPlaylist(List<String> videoPaths) async {
    if (_role != SyncRole.host) return false;
    
    final items = <PlaylistItem>[];
    final fileNames = <String>[];
    _videoPaths.clear();
    
    for (int i = 0; i < videoPaths.length; i++) {
      final path = videoPaths[i];
      final name = path.split(Platform.pathSeparator).last;
      final item = PlaylistItem(
        id: i,
        name: name,
        path: path,
        addedAt: DateTime.now(),
      );
      items.add(item);
      fileNames.add(name);
      _videoPaths[i] = path;
    }
    
    _playlist = VideoPlaylist(items: items, currentIndex: items.isEmpty ? -1 : 0);
    
    _videoServer ??= VideoStreamServer();
    if (!_videoServer!.isRunning) {
      await _videoServer!.startServerOnly();
    }
    
    if (items.isNotEmpty) {
      final firstVideoPath = _videoPaths[0];
      if (firstVideoPath != null && firstVideoPath.isNotEmpty) {
        _videoServer!.switchVideo(firstVideoPath);
        _currentVideoUrl = _videoServer!.videoUrl;
        
        if (_player != null && _currentVideoUrl != null) {
          await _player!.open(Media(_currentVideoUrl!));
        }
      }
    }
    
    if (_server != null) {
      final message = SyncMessage.playlist(_playlist.toSyncJson(), currentIndex: _playlist.currentIndex);
      _server!.broadcastControl(message);
      
      final syncMessage = SyncMessage.playlistSync(fileNames);
      _server!.broadcastControl(syncMessage);
      
      broadcastPlaylistUpdate();
    }
    
    _addSystemMessage('播放列表已更新 (${items.length} 个视频)');
    notifyListeners();
    return true;
  }

  Future<bool> switchToEpisode(int index) async {
    if (_role != SyncRole.host) return false;
    if (index < 0 || index >= _playlist.items.length) return false;
    
    final videoPath = _videoPaths[index];
    if (videoPath == null || videoPath.isEmpty) return false;
    
    _playlist = _playlist.copyWith(currentIndex: index);
    
    if (_videoServer != null) {
      _videoServer!.switchVideo(videoPath);
      _currentVideoUrl = _videoServer!.videoUrl;
    }
    
    if (_player != null && _currentVideoUrl != null) {
      await _player!.open(Media(_currentVideoUrl!));
    }
    
    if (_server != null) {
      final item = _playlist.items[index];
      final message = SyncMessage.switchEpisode(index, videoName: item.name);
      _server!.broadcastControl(message);
    }
    
    _addSystemMessage('切换到: ${_playlist.items[index].name}');
    notifyListeners();
    return true;
  }

  void _handlePlaylistMessage(SyncMessage message) {
    final items = message.playlistItems;
    final currentIndex = message.playlistIndex ?? -1;
    
    if (items != null) {
      _playlist = VideoPlaylist.fromSyncJson(items, currentIndex: currentIndex);
      _addSystemMessage('收到播放列表 (${_playlist.items.length} 个视频)');
      
      if (_currentVideoUrl != null && _player != null && currentIndex >= 0) {
        _player!.open(Media(_currentVideoUrl!));
        
        Future.delayed(const Duration(seconds: 2), () {
          debugPrint('📝 Subtitle tracks after delay: ${_player!.state.tracks.subtitle}');
        });
      }
      
      notifyListeners();
    }
  }

  void _handleSwitchEpisodeMessage(SyncMessage message) {
    final index = message.episodeIndex;
    final videoName = message.videoName;
    
    if (index != null) {
      _playlist = _playlist.copyWith(currentIndex: index);
      _addSystemMessage('切换到: ${videoName ?? "视频 $index"}');
      
      if (_currentVideoUrl != null && _player != null) {
        _player!.open(Media(_currentVideoUrl!));
        
        Future.delayed(const Duration(seconds: 2), () {
          debugPrint('📝 Subtitle tracks after delay: ${_player!.state.tracks.subtitle}');
        });
      }
      
      notifyListeners();
    }
  }

  Future<bool> loadExternalSubtitle(String subtitlePath) async {
    if (_role != SyncRole.host) return false;
    
    final file = File(subtitlePath);
    if (!await file.exists()) {
      debugPrint('❌ Subtitle file does not exist: $subtitlePath');
      return false;
    }
    
    _externalSubtitlePath = subtitlePath;
    
    if (_videoServer != null) {
      _videoServer!.setSubtitle(subtitlePath);
      _externalSubtitleUrl = _videoServer!.subtitleUrl;
    }
    
    if (_externalSubtitleUrl != null && _player != null) {
      await _player!.setSubtitleTrack(SubtitleTrack.uri(_externalSubtitleUrl!));
      if (_subtitleProvider != null) {
        _subtitleProvider!.setExternalSubtitleUrl(_externalSubtitleUrl!);
      }
    }
    
    if (_server != null && _externalSubtitleUrl != null) {
      final subtitleName = subtitlePath.split(Platform.pathSeparator).last;
      final message = SyncMessage.loadExtSub(_externalSubtitleUrl!, subtitleName: subtitleName);
      _server!.broadcastControl(message);
      
      broadcastSubtitleExternalAdd(_externalSubtitleUrl!, subtitleName);
    }
    
    _addSystemMessage('已加载外挂字幕');
    notifyListeners();
    return true;
  }

  Future<void> clearExternalSubtitle() async {
    if (_role != SyncRole.host) return;
    
    _externalSubtitlePath = null;
    _externalSubtitleUrl = null;
    
    if (_videoServer != null) {
      _videoServer!.setSubtitle(null);
    }
    
    if (_server != null) {
      final message = SyncMessage.clearExtSub();
      _server!.broadcastControl(message);
    }
    
    _addSystemMessage('已清除外挂字幕');
    notifyListeners();
  }

  void _handleLoadExtSubMessage(SyncMessage message) {
    final url = message.subtitleUrl;
    final name = message.subtitleName;
    
    if (url != null && _player != null) {
      _externalSubtitleUrl = url;
      _player!.setSubtitleTrack(SubtitleTrack.uri(url));
      _addSystemMessage('已加载外挂字幕: ${name ?? "字幕"}');
      notifyListeners();
    }
  }

  void _handleClearExtSubMessage(SyncMessage message) {
    _externalSubtitleUrl = null;
    if (_player != null) {
      _player!.setSubtitleTrack(SubtitleTrack.no());
    }
    _addSystemMessage('已清除外挂字幕');
    notifyListeners();
  }

  void _handlePlaylistSyncMessage(SyncMessage message) {
    final fileNamesRaw = message.playlistSyncFileNames;
    if (fileNamesRaw != null) {
      final fileNames = fileNamesRaw.map((e) => e as String).toList();
      
      final items = <PlaylistItem>[];
      for (int i = 0; i < fileNames.length; i++) {
        final name = fileNames[i];
        final item = PlaylistItem(
          id: i,
          name: name,
          path: '',
          addedAt: DateTime.now(),
        );
        items.add(item);
      }
      
      _playlist = VideoPlaylist(items: items, currentIndex: items.isEmpty ? -1 : 0);
      _addSystemMessage('收到播放列表同步 (${items.length} 个视频)');
      notifyListeners();
    }
  }

  void _handleRoomStateSnapshot(SyncMessage message) {
    final snapshot = message.data;
    hydrateFromSnapshot(snapshot);
    
    final position = message.snapshotPosition;
    final isPaused = message.snapshotIsPaused;
    
    if (position != null && _player != null) {
      _player!.seek(Duration(seconds: position));
    }
    
    if (isPaused != null && _player != null) {
      if (isPaused) {
        _player!.pause();
      } else {
        _player!.play();
      }
    }
    
    _addSystemMessage('已同步房间状态');
  }

  void _handlePlaylistUpdateMessage(SyncMessage message) {
    final playlistData = message.data['playlist'] as List<dynamic>?;
    final currentIndex = message.data['currentIndex'] as int?;
    
    if (playlistData != null) {
      final items = playlistData.map((json) {
        final map = json as Map<String, dynamic>;
        return PlaylistItem(
          id: map['id'] as int? ?? 0,
          name: map['name'] as String? ?? '未知视频',
          path: '',
          addedAt: DateTime.now(),
        );
      }).toList();
      
      _playlist = VideoPlaylist(
        items: items,
        currentIndex: currentIndex ?? -1,
      );
      _addSystemMessage('播放列表已更新 (${items.length} 个视频)');
      notifyListeners();
    }
  }

  void _handleSubtitleExternalAdd(SyncMessage message) {
    final httpUrl = message.subExternalHttpUrl;
    final label = message.subExternalLabel;
    
    if (httpUrl != null && _player != null) {
      _externalSubtitleUrl = httpUrl;
      if (_subtitleProvider != null) {
        _subtitleProvider!.setExternalSubtitleUrl(httpUrl);
      }
      _player!.setSubtitleTrack(SubtitleTrack.uri(httpUrl));
      _addSystemMessage('已加载外挂字幕: ${label ?? "字幕"}');
      notifyListeners();
    }
  }

  void _handleSubtitleSelect(SyncMessage message) {
    final trackId = message.selectTrackId;
    
    if (trackId != null && _subtitleProvider != null) {
      _subtitleProvider!.selectTrack(trackId);
      _addSystemMessage('字幕已切换');
    }
  }

  void _handleAudioSelect(SyncMessage message) {
    final trackId = message.selectTrackId;
    
    if (trackId != null && _audioTrackProvider != null) {
      _audioTrackProvider!.selectTrack(trackId);
      _addSystemMessage('音轨已切换');
    }
  }

  void _addChatMessage({
    required String senderId,
    required String senderName,
    required String content,
    String? avatarPath,
    bool isHost = false,
    int danmakuColor = 0xFFFFFFFF,
    int danmakuPosition = 0,
  }) {
    final message = ChatMessage(
      id: ChatMessage.generateId(),
      senderId: senderId,
      senderName: senderName,
      senderAvatar: avatarPath,
      content: content,
      timestamp: DateTime.now(),
      isHost: isHost,
      danmakuColor: danmakuColor,
      danmakuPosition: danmakuPosition,
    );
    _chatMessages.add(message);
    notifyListeners();
  }

  void _addSystemMessage(String content) {
    final message = ChatMessage.system(content);
    _chatMessages.add(message);
    notifyListeners();
  }

  void requestSync() {
    if (_role == SyncRole.client && _client != null) {
      _client!.send(SyncMessage.ping());
    }
  }

  Future<void> leaveRoom() async {
    if (_role == SyncRole.host && _server != null) {
      await _server!.stop();
      _server = null;
    } else if (_role == SyncRole.client && _client != null) {
      await _client!.disconnect();
      _client = null;
    }
    
    if (_videoServer != null) {
      await _videoServer!.stop();
      _videoServer = null;
    }
    
    _role = SyncRole.none;
    _isConnected = false;
    _users = [];
    _chatMessages.clear();
    _currentVideoUrl = null;
    _connectedHostIp = null; // 清除连接IP
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _syncRateDebounceTimer?.cancel();
    
    if (_role == SyncRole.host && _server != null) {
      _server!.stop().catchError((_) {});
      _server = null;
    } else if (_role == SyncRole.client && _client != null) {
      _client!.disconnect().catchError((_) {});
      _client = null;
    }
    
    if (_videoServer != null) {
      _videoServer!.stop().catchError((_) {});
      _videoServer = null;
    }
    
    _role = SyncRole.none;
    _isConnected = false;
    _users = [];
    _chatMessages.clear();
    _currentVideoUrl = null;
    _connectedHostIp = null;
    
    super.dispose();
  }
}
