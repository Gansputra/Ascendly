import 'package:ascendly/models/user_profile.dart';
import 'package:ascendly/services/database_service.dart';
import 'package:flutter/material.dart';

class GamificationService {
  final _db = DatabaseService();

  // XP needed for next level formula: 50 * level
  int xpForNextLevel(int level) => level * 100;

  Future<void> addXP(String userId, int amount, {BuildContext? context}) async {
    final profile = await _db.getProfile(userId);
    if (profile == null) return;

    int currentXP = profile.xp + amount;
    int currentLevel = profile.level;

    // Check for level up
    while (currentXP >= xpForNextLevel(currentLevel)) {
      currentXP -= xpForNextLevel(currentLevel);
      currentLevel++;
      if (context != null && context.mounted) {
        _showLevelUpDialog(context, currentLevel);
      }
    }

    await _db.updateXPAndLevel(userId, currentXP, currentLevel);
  }

  void _showLevelUpDialog(BuildContext context, int newLevel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.keyboard_double_arrow_up, color: Colors.amber, size: 64),
            const SizedBox(height: 16),
            const Text(
              'LEVEL UP!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 2),
            ),
            const SizedBox(height: 8),
            Text(
              'You reached Level $newLevel',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            const Text(
              'Your willpower is growing stronger.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Keep Growing'),
            ),
          ],
        ),
      ),
    );
  }
}
