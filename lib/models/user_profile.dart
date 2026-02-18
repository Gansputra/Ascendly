class UserProfile {
  final String id;
  final String? nickname;
  final String? goal; // 'gooning', 'rokok', 'gaming'
  final DateTime? streakStartDate;
  final DateTime createdAt;

  UserProfile({
    required this.id,
    this.nickname,
    this.goal,
    this.streakStartDate,
    required this.createdAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      nickname: json['nickname'],
      goal: json['goal'],
      streakStartDate: json['streak_start_date'] != null
          ? DateTime.parse(json['streak_start_date'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nickname': nickname,
      'goal': goal,
      'streak_start_date': streakStartDate?.toIso8601String(),
    };
  }

  int get streakDays {
    if (streakStartDate == null) return 0;
    final now = DateTime.now();
    return now.difference(streakStartDate!).inDays;
  }
}
