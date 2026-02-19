class UserProfile {
  final String id;
  final String? nickname;
  final String? goal;
  final DateTime? streakStartDate;
  final int totalDaysCleared;
  final int bestStreak;
  final DateTime createdAt;

  UserProfile({
    required this.id,
    this.nickname,
    this.goal,
    this.streakStartDate,
    this.totalDaysCleared = 0,
    this.bestStreak = 0,
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
      totalDaysCleared: json['total_days_cleared'] ?? 0,
      bestStreak: json['best_streak'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nickname': nickname,
      'goal': goal,
      'streak_start_date': streakStartDate?.toIso8601String(),
      'total_days_cleared': totalDaysCleared,
      'best_streak': bestStreak,
    };
  }

  Duration get currentStreakDuration {
    if (streakStartDate == null) return Duration.zero;
    return DateTime.now().difference(streakStartDate!);
  }

  int get currentStreakDays => currentStreakDuration.inDays;
}

class Relapse {
  final String id;
  final String userId;
  final DateTime relapseDate;

  Relapse({required this.id, required this.userId, required this.relapseDate});

  factory Relapse.fromJson(Map<String, dynamic> json) {
    return Relapse(
      id: json['id'],
      userId: json['user_id'],
      relapseDate: DateTime.parse(json['relapse_date']),
    );
  }
}
