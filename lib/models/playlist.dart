class PlaylistItem {
  final int id;
  final String name;
  final String path;
  final int duration;
  final DateTime addedAt;

  const PlaylistItem({
    required this.id,
    required this.name,
    required this.path,
    this.duration = 0,
    required this.addedAt,
  });

  factory PlaylistItem.fromJson(Map<String, dynamic> json) {
    return PlaylistItem(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '未知视频',
      path: json['path'] as String? ?? '',
      duration: json['duration'] as int? ?? 0,
      addedAt: json['addedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['addedAt'] as int)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'path': path,
      'duration': duration,
      'addedAt': addedAt.millisecondsSinceEpoch,
    };
  }

  Map<String, dynamic> toSyncJson() {
    return {
      'id': id,
      'name': name,
      'duration': duration,
    };
  }

  PlaylistItem copyWith({
    int? id,
    String? name,
    String? path,
    int? duration,
    DateTime? addedAt,
  }) {
    return PlaylistItem(
      id: id ?? this.id,
      name: name ?? this.name,
      path: path ?? this.path,
      duration: duration ?? this.duration,
      addedAt: addedAt ?? this.addedAt,
    );
  }
}

class VideoPlaylist {
  final List<PlaylistItem> items;
  final int currentIndex;
  final int? playingId;

  const VideoPlaylist({
    this.items = const [],
    this.currentIndex = -1,
    this.playingId,
  });

  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;
  int get length => items.length;
  PlaylistItem? get current => currentIndex >= 0 && currentIndex < items.length 
      ? items[currentIndex] 
      : null;
  PlaylistItem? get next => currentIndex + 1 < items.length 
      ? items[currentIndex + 1] 
      : null;
  PlaylistItem? get previous => currentIndex - 1 >= 0 
      ? items[currentIndex - 1] 
      : null;

  VideoPlaylist copyWith({
    List<PlaylistItem>? items,
    int? currentIndex,
    int? playingId,
  }) {
    return VideoPlaylist(
      items: items ?? this.items,
      currentIndex: currentIndex ?? this.currentIndex,
      playingId: playingId ?? this.playingId,
    );
  }

  List<Map<String, dynamic>> toSyncJson() {
    return items.map((item) => item.toSyncJson()).toList();
  }

  factory VideoPlaylist.fromSyncJson(List<dynamic> json, {int currentIndex = -1}) {
    final items = json.map((e) {
      final map = e as Map<String, dynamic>;
      return PlaylistItem(
        id: map['id'] as int? ?? 0,
        name: map['name'] as String? ?? '未知视频',
        path: '',
        duration: map['duration'] as int? ?? 0,
        addedAt: DateTime.now(),
      );
    }).toList();
    
    return VideoPlaylist(items: items, currentIndex: currentIndex);
  }
}
