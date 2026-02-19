import 'package:ascendly/models/achievement_model.dart';
import 'package:ascendly/models/user_profile.dart';
import 'package:ascendly/services/database_service.dart';
import 'package:flutter/material.dart';

class AchievementService {
  final _db = DatabaseService();

  Future<void> checkAchievements(String userId, {BuildContext? context}) async {
    final profile = await _db.getProfile(userId);
    if (profile == null) return;

    final masterAchievements = await _db.getAchievements();
    final unlocked = await _db.getUserAchievements(userId);
    final unlockedIds = unlocked.map((ua) => ua.achievementId).toSet();

    for (final achievement in masterAchievements) {
      if (unlockedIds.contains(achievement.id)) continue;

      bool shouldUnlock = false;

      switch (achievement.conditionType) {
        case 'streak_days':
          if (profile.currentStreakDays >= achievement.conditionValue) {
            shouldUnlock = true;
          }
          break;
        case 'best_streak':
          if (profile.bestStreak >= achievement.conditionValue) {
            shouldUnlock = true;
          }
          break;
        case 'total_cleared':
          if (profile.totalDaysCleared >= achievement.conditionValue) {
            shouldUnlock = true;
          }
          break;
        case 'emergency_use':
          if (profile.emergencyUses >= achievement.conditionValue) {
            shouldUnlock = true;
          }
          break;
        case 'social_friends':
          final friends = await _db.getFriends(userId);
          if (friends.length >= achievement.conditionValue) {
            shouldUnlock = true;
          }
          break;
      }

      if (shouldUnlock) {
        await _db.unlockAchievement(userId, achievement.id);
        if (context != null && context.mounted) {
          _showUnlockNotification(context, achievement);
        }
      }
    }
  }

  void _showUnlockNotification(BuildContext context, Achievement achievement) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.stars, color: Colors.amber),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('BADGE UNLOCKED!', 
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  Text(achievement.title, 
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.black87,
        duration: const Duration(seconds: 4),
      ),
    );
  }
}
