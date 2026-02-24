class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String? senderAvatar;
  final String content;
  final DateTime timestamp;
  final bool isSystem;
  final bool isHost;
  final int danmakuColor;
  final int danmakuPosition;

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    this.senderAvatar,
    required this.content,
    required this.timestamp,
    this.isSystem = false,
    this.isHost = false,
    this.danmakuColor = 0xFFFFFFFF,
    this.danmakuPosition = 0,
  });

  factory ChatMessage.system(String content) {
    return ChatMessage(
      id: 'system_${DateTime.now().millisecondsSinceEpoch}',
      senderId: 'system',
      senderName: '系统',
      content: content,
      timestamp: DateTime.now(),
      isSystem: true,
    );
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String? ?? '',
      senderId: json['senderId'] as String? ?? '',
      senderName: json['senderName'] as String? ?? '',
      senderAvatar: json['senderAvatar'] as String?,
      content: json['content'] as String? ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int)
          : DateTime.now(),
      isSystem: json['isSystem'] as bool? ?? false,
      isHost: json['isHost'] as bool? ?? false,
      danmakuColor: json['danmakuColor'] as int? ?? 0xFFFFFFFF,
      danmakuPosition: json['danmakuPosition'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'senderName': senderName,
      'senderAvatar': senderAvatar,
      'content': content,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'isSystem': isSystem,
      'isHost': isHost,
      'danmakuColor': danmakuColor,
      'danmakuPosition': danmakuPosition,
    };
  }

  ChatMessage copyWith({
    String? id,
    String? senderId,
    String? senderName,
    String? senderAvatar,
    String? content,
    DateTime? timestamp,
    bool? isSystem,
    bool? isHost,
    int? danmakuColor,
    int? danmakuPosition,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderAvatar: senderAvatar ?? this.senderAvatar,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      isSystem: isSystem ?? this.isSystem,
      isHost: isHost ?? this.isHost,
      danmakuColor: danmakuColor ?? this.danmakuColor,
      danmakuPosition: danmakuPosition ?? this.danmakuPosition,
    );
  }

  static String generateId() {
    return '${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecond}';
  }
}
