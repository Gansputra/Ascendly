class Quest {
  final String id;
  final String title;
  final String description;
  final int xpReward;
  final String questType;

  Quest({
    required this.id,
    required this.title,
    required this.description,
    required this.xpReward,
    required this.questType,
  });

  factory Quest.fromJson(Map<String, dynamic> json) {
    return Quest(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      xpReward: json['xp_reward'],
      questType: json['quest_type'],
    );
  }
}

class UserQuest {
  final String userId;
  final String questId;
  final DateTime lastCompletedAt;

  UserQuest({
    required this.userId,
    required this.questId,
    required this.lastCompletedAt,
  });

  factory UserQuest.fromJson(Map<String, dynamic> json) {
    return UserQuest(
      userId: json['user_id'],
      questId: json['quest_id'],
      lastCompletedAt: DateTime.parse(json['last_completed_at']),
    );
  }

  bool get isCompletedToday {
    final now = DateTime.now();
    return lastCompletedAt.year == now.year &&
           lastCompletedAt.month == now.month &&
           lastCompletedAt.day == now.day;
  }
}
