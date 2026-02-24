class UserStats {
  final int totalWatchTimeMinutes;
  final int totalRoomsJoined;
  final int totalVideosWatched;
  final int favoriteCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserStats({
    this.totalWatchTimeMinutes = 0,
    this.totalRoomsJoined = 0,
    this.totalVideosWatched = 0,
    this.favoriteCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserStats.empty() {
    final now = DateTime.now();
    return UserStats(
      createdAt: now,
      updatedAt: now,
    );
  }

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      totalWatchTimeMinutes: json['totalWatchTimeMinutes'] as int? ?? 0,
      totalRoomsJoined: json['totalRoomsJoined'] as int? ?? 0,
      totalVideosWatched: json['totalVideosWatched'] as int? ?? 0,
      favoriteCount: json['favoriteCount'] as int? ?? 0,
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
      'totalWatchTimeMinutes': totalWatchTimeMinutes,
      'totalRoomsJoined': totalRoomsJoined,
      'totalVideosWatched': totalVideosWatched,
      'favoriteCount': favoriteCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  UserStats copyWith({
    int? totalWatchTimeMinutes,
    int? totalRoomsJoined,
    int? totalVideosWatched,
    int? favoriteCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserStats(
      totalWatchTimeMinutes: totalWatchTimeMinutes ?? this.totalWatchTimeMinutes,
      totalRoomsJoined: totalRoomsJoined ?? this.totalRoomsJoined,
      totalVideosWatched: totalVideosWatched ?? this.totalVideosWatched,
      favoriteCount: favoriteCount ?? this.favoriteCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get formattedWatchTime {
    final hours = totalWatchTimeMinutes ~/ 60;
    final minutes = totalWatchTimeMinutes % 60;
    if (hours > 0) {
      return '$hours 小时 ${minutes > 0 ? '$minutes 分钟' : ''}';
    }
    return '$minutes 分钟';
  }

  String get formattedWatchTimeShort {
    final hours = totalWatchTimeMinutes ~/ 60;
    if (hours > 0) {
      return '$hours 小时';
    }
    return '$totalWatchTimeMinutes 分钟';
  }
}

class ActivityRecord {
  final String id;
  final String type;
  final String title;
  final String? subtitle;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  const ActivityRecord({
    required this.id,
    required this.type,
    required this.title,
    this.subtitle,
    required this.timestamp,
    this.metadata,
  });

  factory ActivityRecord.fromJson(Map<String, dynamic> json) {
    return ActivityRecord(
      id: json['id'] as String? ?? '',
      type: json['type'] as String? ?? 'unknown',
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String?,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'subtitle': subtitle,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
    };
  }

  static String generateId() {
    return '${DateTime.now().millisecondsSinceEpoch}';
  }
}
