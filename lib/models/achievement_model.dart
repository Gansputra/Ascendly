class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon; // Icon name from Lucide/Material
  final String conditionType; // 'streak_days', 'total_cleared', 'emergency_use', 'social_activity'
  final int conditionValue;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.conditionType,
    required this.conditionValue,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      icon: json['icon'],
      conditionType: json['condition_type'],
      conditionValue: json['condition_value'],
    );
  }
}

class UserAchievement {
  final String userId;
  final String achievementId;
  final DateTime unlockedAt;
  final Achievement? achievement; // Joined data

  UserAchievement({
    required this.userId,
    required this.achievementId,
    required this.unlockedAt,
    this.achievement,
  });

  factory UserAchievement.fromJson(Map<String, dynamic> json) {
    return UserAchievement(
      userId: json['user_id'],
      achievementId: json['achievement_id'],
      unlockedAt: DateTime.parse(json['unlocked_at']),
      achievement: json['achievements'] != null 
          ? Achievement.fromJson(json['achievements']) 
          : null,
    );
  }
}
