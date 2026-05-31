class ParticipantModel {
  final String uid;
  final String name;
  final String? avatarUrl;
  final bool isMuted;
  final bool isCameraOff;
  final bool isHost;
  final DateTime joinedAt;

  ParticipantModel({
    required this.uid,
    required this.name,
    this.avatarUrl,
    this.isMuted = false,
    this.isCameraOff = false,
    this.isHost = false,
    DateTime? joinedAt,
  }) : joinedAt = joinedAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'name': name,
        'avatarUrl': avatarUrl,
        'isMuted': isMuted,
        'isCameraOff': isCameraOff,
        'isHost': isHost,
        'joinedAt': joinedAt.toIso8601String(),
      };

  factory ParticipantModel.fromJson(Map<String, dynamic> json) {
    return ParticipantModel(
      uid: json['uid'] ?? '',
      name: json['name'] ?? 'Participant',
      avatarUrl: json['avatarUrl'],
      isMuted: json['isMuted'] ?? false,
      isCameraOff: json['isCameraOff'] ?? false,
      isHost: json['isHost'] ?? false,
      joinedAt: json['joinedAt'] != null
          ? DateTime.parse(json['joinedAt'])
          : DateTime.now(),
    );
  }

  ParticipantModel copyWith({
    String? uid,
    String? name,
    String? avatarUrl,
    bool? isMuted,
    bool? isCameraOff,
    bool? isHost,
    DateTime? joinedAt,
  }) {
    return ParticipantModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isMuted: isMuted ?? this.isMuted,
      isCameraOff: isCameraOff ?? this.isCameraOff,
      isHost: isHost ?? this.isHost,
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  @override
  String toString() => 'ParticipantModel(uid: $uid, name: $name)';
}
