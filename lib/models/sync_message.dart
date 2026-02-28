import 'dart:convert';

enum SyncMessageType {
  play,
  pause,
  seek,
  speed,
  volume,
  chat,
  join,
  leave,
  userlist,
  sync,
  ping,
  pong,
  videoUrl,
  playlist,
  switchEpisode,
  loadExtSub,
  clearExtSub,
  playlistSync,
  roomStateSnapshot,
  playlistUpdate,
  subtitleExternalAdd,
  subtitleSelect,
  audioSelect,
}

class SyncMessage {
  final SyncMessageType type;
  final Map<String, dynamic> data;
  final int timestamp;
  final String? senderId;
  final String? senderName;

  const SyncMessage({
    required this.type,
    required this.data,
    required this.timestamp,
    this.senderId,
    this.senderName,
  });

  factory SyncMessage.play({int? positionMs}) {
    return SyncMessage(
      type: SyncMessageType.play,
      data: {'positionMs': positionMs},
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
  }

  factory SyncMessage.pause({int? positionMs}) {
    return SyncMessage(
      type: SyncMessageType.pause,
      data: {'positionMs': positionMs},
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
  }

  factory SyncMessage.seek(int positionMs) {
    return SyncMessage(
      type: SyncMessageType.seek,
      data: {'positionMs': positionMs},
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
  }

  factory SyncMessage.speed(double speed) {
    return SyncMessage(
      type: SyncMessageType.speed,
      data: {'speed': speed},
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
  }

  factory SyncMessage.volume(double volume) {
    return SyncMessage(
      type: SyncMessageType.volume,
      data: {'volume': volume},
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
  }

  factory SyncMessage.chat({
    required String senderId,
    required String senderName,
    required String content,
    String? avatarPath,
    bool isHost = false,
    int danmakuColor = 0xFFFFFFFF,
    int danmakuPosition = 0,
  }) {
    return SyncMessage(
      type: SyncMessageType.chat,
      data: {
        'content': content,
        'avatarPath': avatarPath,
        'isHost': isHost,
        'danmakuColor': danmakuColor,
        'danmakuPosition': danmakuPosition,
      },
      timestamp: DateTime.now().millisecondsSinceEpoch,
      senderId: senderId,
      senderName: senderName,
    );
  }

  factory SyncMessage.join({
    required String userId,
    required String userName,
    String? avatarPath,
  }) {
    return SyncMessage(
      type: SyncMessageType.join,
      data: {
        'userName': userName,
        'avatarPath': avatarPath,
      },
      timestamp: DateTime.now().millisecondsSinceEpoch,
      senderId: userId,
      senderName: userName,
    );
  }

  factory SyncMessage.leave({
    required String userId,
    required String userName,
  }) {
    return SyncMessage(
      type: SyncMessageType.leave,
      data: {
        'userName': userName,
      },
      timestamp: DateTime.now().millisecondsSinceEpoch,
      senderId: userId,
      senderName: userName,
    );
  }

  factory SyncMessage.userList(List<RoomUser> users) {
    return SyncMessage(
      type: SyncMessageType.userlist,
      data: {
        'users': users.map((u) => u.toJson()).toList(),
      },
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
  }

  factory SyncMessage.sync({
    required int positionMs,
    required bool isPlaying,
    required double speed,
    required double volume,
  }) {
    return SyncMessage(
      type: SyncMessageType.sync,
      data: {
        'positionMs': positionMs,
        'isPlaying': isPlaying,
        'speed': speed,
        'volume': volume,
      },
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
  }

  factory SyncMessage.ping() {
    return SyncMessage(
      type: SyncMessageType.ping,
      data: {},
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
  }

  factory SyncMessage.pong() {
    return SyncMessage(
      type: SyncMessageType.pong,
      data: {},
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
  }

  factory SyncMessage.videoUrl(String url, {String? videoName}) {
    return SyncMessage(
      type: SyncMessageType.videoUrl,
      data: {
        'url': url,
        'videoName': videoName,
      },
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
  }

  factory SyncMessage.playlist(List<Map<String, dynamic>> items, {int currentIndex = -1}) {
    return SyncMessage(
      type: SyncMessageType.playlist,
      data: {
        'items': items,
        'currentIndex': currentIndex,
      },
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
  }

  factory SyncMessage.switchEpisode(int index, {String? videoName}) {
    return SyncMessage(
      type: SyncMessageType.switchEpisode,
      data: {
        'index': index,
        'videoName': videoName,
      },
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
  }

  factory SyncMessage.loadExtSub(String url, {String? subtitleName}) {
    return SyncMessage(
      type: SyncMessageType.loadExtSub,
      data: {
        'url': url,
        'subtitleName': subtitleName,
      },
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
  }

  factory SyncMessage.clearExtSub() {
    return SyncMessage(
      type: SyncMessageType.clearExtSub,
      data: {},
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
  }

  factory SyncMessage.playlistSync(List<String> fileNames) {
    return SyncMessage(
      type: SyncMessageType.playlistSync,
      data: {'fileNames': fileNames},
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
  }

  factory SyncMessage.roomStateSnapshot({
    required List<Map<String, dynamic>> playlist,
    required int currentIndex,
    required List<Map<String, dynamic>> subtitleTracks,
    required String? currentSubtitleId,
    required List<Map<String, dynamic>> audioTracks,
    required String? currentAudioId,
    required String? externalSubtitleUrl,
    required int position,
    required bool isPaused,
  }) {
    return SyncMessage(
      type: SyncMessageType.roomStateSnapshot,
      data: {
        'playlist': playlist,
        'currentIndex': currentIndex,
        'subtitleTracks': subtitleTracks,
        'currentSubtitleId': currentSubtitleId,
        'audioTracks': audioTracks,
        'currentAudioId': currentAudioId,
        'externalSubtitleUrl': externalSubtitleUrl,
        'position': position,
        'isPaused': isPaused,
      },
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
  }

  factory SyncMessage.playlistUpdate(List<Map<String, dynamic>> playlist, int currentIndex) {
    return SyncMessage(
      type: SyncMessageType.playlistUpdate,
      data: {
        'playlist': playlist,
        'currentIndex': currentIndex,
      },
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
  }

  factory SyncMessage.subtitleExternalAdd(String httpUrl, String label) {
    return SyncMessage(
      type: SyncMessageType.subtitleExternalAdd,
      data: {
        'httpUrl': httpUrl,
        'label': label,
      },
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
  }

  factory SyncMessage.subtitleSelect(String trackId) {
    return SyncMessage(
      type: SyncMessageType.subtitleSelect,
      data: {'trackId': trackId},
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
  }

  factory SyncMessage.audioSelect(String trackId) {
    return SyncMessage(
      type: SyncMessageType.audioSelect,
      data: {'trackId': trackId},
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
  }

  factory SyncMessage.fromJson(Map<String, dynamic> json) {
    return SyncMessage(
      type: SyncMessageType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => SyncMessageType.ping,
      ),
      data: json['data'] as Map<String, dynamic>? ?? {},
      timestamp: json['timestamp'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      senderId: json['senderId'] as String?,
      senderName: json['senderName'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'data': data,
      'timestamp': timestamp,
      'senderId': senderId,
      'senderName': senderName,
    };
  }

  String encode() => jsonEncode(toJson());

  static SyncMessage? decode(String data) {
    try {
      final json = jsonDecode(data) as Map<String, dynamic>;
      return SyncMessage.fromJson(json);
    } catch (e) {
      return null;
    }
  }

  int? get positionMs => data['positionMs'] as int?;
  double? get speed => data['speed'] as double?;
  double? get volume => data['volume'] as double?;
  bool? get isPlaying => data['isPlaying'] as bool?;
  String? get content => data['content'] as String?;
  String? get avatarPath => data['avatarPath'] as String?;
  String? get userName => data['userName'] as String?;
  String? get videoUrl => data['url'] as String?;
  String? get videoName => data['videoName'] as String?;
  bool get isHost => data['isHost'] as bool? ?? false;
  List<dynamic>? get playlistItems => data['items'] as List<dynamic>?;
  int? get playlistIndex => data['currentIndex'] as int?;
  int? get episodeIndex => data['index'] as int?;
  String? get subtitleUrl => data['url'] as String?;
  String? get subtitleName => data['subtitleName'] as String?;
  List<dynamic>? get playlistSyncFileNames => data['fileNames'] as List<dynamic>?;
  int get danmakuColor => data['danmakuColor'] as int? ?? 0xFFFFFFFF;
  int get danmakuPosition => data['danmakuPosition'] as int? ?? 0;
  List<dynamic>? get snapshotPlaylist => data['playlist'] as List<dynamic>?;
  int? get snapshotCurrentIndex => data['currentIndex'] as int?;
  List<dynamic>? get snapshotSubtitleTracks => data['subtitleTracks'] as List<dynamic>?;
  String? get snapshotCurrentSubtitleId => data['currentSubtitleId'] as String?;
  List<dynamic>? get snapshotAudioTracks => data['audioTracks'] as List<dynamic>?;
  String? get snapshotCurrentAudioId => data['currentAudioId'] as String?;
  String? get snapshotExternalSubtitleUrl => data['externalSubtitleUrl'] as String?;
  int? get snapshotPosition => data['position'] as int?;
  bool? get snapshotIsPaused => data['isPaused'] as bool?;
  String? get selectTrackId => data['trackId'] as String?;
  String? get subExternalHttpUrl => data['httpUrl'] as String?;
  String? get subExternalLabel => data['label'] as String?;
}

class RoomUser {
  final String id;
  final String name;
  final String? avatarPath;
  final bool isHost;
  final DateTime joinedAt;

  const RoomUser({
    required this.id,
    required this.name,
    this.avatarPath,
    this.isHost = false,
    required this.joinedAt,
  });

  factory RoomUser.fromJson(Map<String, dynamic> json) {
    return RoomUser(
      id: json['id'] as String,
      name: json['name'] as String,
      avatarPath: json['avatarPath'] as String?,
      isHost: json['isHost'] as bool? ?? false,
      joinedAt: json['joinedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['joinedAt'] as int)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatarPath': avatarPath,
      'isHost': isHost,
      'joinedAt': joinedAt.millisecondsSinceEpoch,
    };
  }

  RoomUser copyWith({
    String? id,
    String? name,
    String? avatarPath,
    bool? isHost,
    DateTime? joinedAt,
  }) {
    return RoomUser(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarPath: avatarPath ?? this.avatarPath,
      isHost: isHost ?? this.isHost,
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }
}
