import 'package:ascendly/models/user_profile.dart';
import 'package:ascendly/models/social_models.dart';
import 'package:ascendly/models/achievement_model.dart';
import 'package:ascendly/models/quest_model.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DatabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  // Profiles
  Future<UserProfile?> getProfile(String userId) async {
    try {
      final response = await _client.from('profiles').select().eq('id', userId).single();
      return UserProfile.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  Future<void> upsertProfile(UserProfile profile) async {
    await _client.from('profiles').upsert(profile.toJson());
  }

  // Streak Management
  Future<void> resetStreak(String userId) async {
    final now = DateTime.now().toUtc();
    final profile = await getProfile(userId);
    if (profile == null) return;

    // Record relapse
    await _client.from('relapses').insert({
      'user_id': userId,
      'relapse_date': now.toIso8601String(),
    });

    // Update profile: Reset start date, update best streak, and increment total days cleared
    final currentStreak = profile.currentStreakDays;
    final newBestStreak = currentStreak > profile.bestStreak ? currentStreak : profile.bestStreak;
    final newTotalCleared = profile.totalDaysCleared + currentStreak;

    await _client.from('profiles').update({
      'streak_start_date': now.toIso8601String(),
      'best_streak': newBestStreak,
      'total_days_cleared': newTotalCleared,
    }).eq('id', userId);
  }

  Future<List<Relapse>> getRelapses(String userId) async {
    final response = await _client.from('relapses').select().eq('user_id', userId);
    return (response as List).map((r) => Relapse.fromJson(r)).toList();
  }

  // Social
  Stream<List<Message>> getChatStream(String userId, String friendId) {
    return _client
        .from('messages')
        .stream(primaryKey: ['id'])
        .order('created_at')
        .map((data) => data
            .map((m) => Message.fromJson(m))
            .where((m) =>
                (m.senderId == userId && m.receiverId == friendId) ||
                (m.senderId == friendId && m.receiverId == userId))
            .toList());
  }

  Future<void> sendMessage(String senderId, String receiverId, String content) async {
    await _client.from('messages').insert({
      'sender_id': senderId,
      'receiver_id': receiverId,
      'content': content,
    });
  }

  Future<List<Map<String, dynamic>>> getFriends(String userId) async {
    try {
      // Fetch where user is either user_one or user_two
      final res1 = await _client
          .from('friendships')
          .select('*, profiles:profiles!user_two_id(*)')
          .eq('user_one_id', userId);
          
      final res2 = await _client
          .from('friendships')
          .select('*, profiles:profiles!user_one_id(*)')
          .eq('user_two_id', userId);

      // Merge and normalize the format for SocialScreen
      List<Map<String, dynamic>> friends = [];
      
      for (var f in res1) {
        if (f['profiles'] != null) friends.add(f);
      }
      for (var f in res2) {
        if (f['profiles'] != null) friends.add(f);
      }
      
      return friends;
    } catch (e) {
      debugPrint('Error fetching friends: $e');
      return [];
    }
  }

  // Achievements
  Future<List<Achievement>> getAchievements() async {
    final response = await _client.from('achievements').select().order('condition_value');
    return (response as List).map((a) => Achievement.fromJson(a)).toList();
  }

  Future<List<UserAchievement>> getUserAchievements(String userId) async {
    final response = await _client
        .from('user_achievements')
        .select('*, achievements(*)')
        .eq('user_id', userId);
    return (response as List).map((ua) => UserAchievement.fromJson(ua)).toList();
  }

  Future<void> unlockAchievement(String userId, String achievementId) async {
    try {
      await _client.from('user_achievements').insert({
        'user_id': userId,
        'achievement_id': achievementId,
        'unlocked_at': DateTime.now().toUtc().toIso8601String(),
      });
    } catch (e) {
      // Achievement might already be unlocked (duplicate key)
      debugPrint('Achievement already unlocked or error: $e');
    }
  }

  Future<void> incrementEmergencyUse(String userId) async {
    final profile = await getProfile(userId);
    if (profile == null) return;
    
    await _client.from('profiles').update({
      'emergency_uses': (profile.toJson()['emergency_uses'] ?? 0) + 1,
    }).eq('id', userId);
  }

  Future<void> updateXPAndLevel(String userId, int newXP, int newLevel) async {
    await _client.from('profiles').update({
      'xp': newXP,
      'level': newLevel,
    }).eq('id', userId);
  }

  // Quests
  Future<List<Quest>> getQuests() async {
    final response = await _client.from('quests').select();
    return (response as List).map((q) => Quest.fromJson(q)).toList();
  }

  Future<List<UserQuest>> getUserQuests(String userId) async {
    final response = await _client.from('user_quests').select().eq('user_id', userId);
    return (response as List).map((uq) => UserQuest.fromJson(uq)).toList();
  }

  Future<void> completeQuest(String userId, String questId) async {
    await _client.from('user_quests').upsert({
      'user_id': userId,
      'quest_id': questId,
      'last_completed_at': DateTime.now().toUtc().toIso8601String(),
    });
  }
}
