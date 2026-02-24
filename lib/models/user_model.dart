class UserModel {
  final String nickname;
  final String? avatarPath;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserModel({
    this.nickname = '用户',
    this.avatarPath,
    required this.createdAt,
    required this.updatedAt,
  });

  UserModel copyWith({
    String? nickname,
    String? avatarPath,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      nickname: nickname ?? this.nickname,
      avatarPath: avatarPath ?? this.avatarPath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nickname': nickname,
      'avatarPath': avatarPath,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      nickname: json['nickname'] as String? ?? '用户',
      avatarPath: json['avatarPath'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
    );
  }

  static const int maxNicknameLength = 16;
  static const int minNicknameLength = 1;

  static String? validateNickname(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '昵称不能为空';
    }
    final trimmed = value.trim();
    if (trimmed.length < minNicknameLength) {
      return '昵称至少需要$minNicknameLength个字符';
    }
    if (trimmed.length > maxNicknameLength) {
      return '昵称不能超过$maxNicknameLength个字符';
    }
    final invalidChars = RegExp(r'[<>:"/\\|?*\x00-\x1F]');
    if (invalidChars.hasMatch(trimmed)) {
      return '昵称包含非法字符';
    }
    return null;
  }

  static String sanitizeNickname(String input) {
    final invalidChars = RegExp(r'[<>:"/\\|?*\x00-\x1F]');
    String sanitized = input.replaceAll(invalidChars, '');
    if (sanitized.length > maxNicknameLength) {
      sanitized = sanitized.substring(0, maxNicknameLength);
    }
    return sanitized.trim();
  }
}
