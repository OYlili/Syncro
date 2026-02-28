class RoomModel {
  final String id;
  final String name;
  final String hostName;
  final String ipAddress;
  final int port;
  final int memberCount;
  final DateTime discoveredAt;
  final DateTime lastSeenAt;

  const RoomModel({
    required this.id,
    required this.name,
    required this.hostName,
    required this.ipAddress,
    required this.port,
    this.memberCount = 1,
    required this.discoveredAt,
    required this.lastSeenAt,
  });

  RoomModel copyWith({
    String? id,
    String? name,
    String? hostName,
    String? ipAddress,
    int? port,
    int? memberCount,
    DateTime? discoveredAt,
    DateTime? lastSeenAt,
  }) {
    return RoomModel(
      id: id ?? this.id,
      name: name ?? this.name,
      hostName: hostName ?? this.hostName,
      ipAddress: ipAddress ?? this.ipAddress,
      port: port ?? this.port,
      memberCount: memberCount ?? this.memberCount,
      discoveredAt: discoveredAt ?? this.discoveredAt,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
    );
  }

  bool get isExpired {
    final now = DateTime.now();
    final difference = now.difference(lastSeenAt);
    return difference.inSeconds > 10;
  }

  String get displayAddress => '$ipAddress:$port';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'hostName': hostName,
      'ipAddress': ipAddress,
      'port': port,
      'memberCount': memberCount,
      'discoveredAt': discoveredAt.toIso8601String(),
      'lastSeenAt': lastSeenAt.toIso8601String(),
    };
  }

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      id: json['id'] as String,
      name: json['name'] as String,
      hostName: json['hostName'] as String,
      ipAddress: json['ipAddress'] as String,
      port: json['port'] as int,
      memberCount: json['memberCount'] as int? ?? 1,
      discoveredAt: DateTime.parse(json['discoveredAt'] as String),
      lastSeenAt: DateTime.parse(json['lastSeenAt'] as String),
    );
  }

  static String generateId(String ipAddress, int port) {
    return '$ipAddress:$port';
  }
}
