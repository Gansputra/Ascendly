import 'package:ascendly/core/theme.dart';
import 'package:ascendly/models/achievement_model.dart';
import 'package:ascendly/services/auth_service.dart';
import 'package:ascendly/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:lucide_icons/lucide_icons.dart';

class BadgesScreen extends StatefulWidget {
  const BadgesScreen({super.key});

  @override
  State<BadgesScreen> createState() => _BadgesScreenState();
}

class _BadgesScreenState extends State<BadgesScreen> {
  final _db = DatabaseService();
  final _auth = AuthService();
  List<Achievement> _allAchievements = [];
  Set<String> _unlockedIds = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final all = await _db.getAchievements();
      final user = await _db.getUserAchievements(_auth.currentUser!.id);
      if (mounted) {
        setState(() {
          _allAchievements = all;
          _unlockedIds = user.map((ua) => ua.achievementId).toSet();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Achievements'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _allAchievements.isEmpty
              ? _buildEmptyState()
              : GridView.builder(
                  padding: const EdgeInsets.all(24),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 24,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: _allAchievements.length,
                  itemBuilder: (context, index) {
                    final achievement = _allAchievements[index];
                    final isUnlocked = _unlockedIds.contains(achievement.id);
                    return _buildBadgeItem(achievement, isUnlocked, index);
                  },
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.database, size: 64, color: AppTheme.textSecondary.withOpacity(0.2)),
            const SizedBox(height: 16),
            const Text(
              'No Achievements Defined',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Make sure to run the SQL seed script in your Supabase dashboard to populate achievements.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadData,
              child: const Text('Retry Loading'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadgeItem(Achievement achievement, bool isUnlocked, int index) {
    return FadeInUp(
      delay: Duration(milliseconds: index * 50),
      child: GestureDetector(
        onTap: () => _showBadgeDetails(achievement, isUnlocked),
        child: Column(
          children: [
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Circle Background
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: isUnlocked 
                          ? Border.all(color: Colors.white.withOpacity(0.2), width: 1)
                          : Border.all(color: Colors.white.withOpacity(0.05), width: 1),
                      gradient: isUnlocked
                          ? LinearGradient(
                              colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      color: isUnlocked ? null : Colors.white.withOpacity(0.05),
                    ),
                  ),
                  // Icon
                  Opacity(
                    opacity: isUnlocked ? 1.0 : 0.6,
                    child: Icon(
                      _getIconData(achievement.icon),
                      size: 28,
                      color: isUnlocked ? Colors.white : Colors.grey[600],
                    ),
                  ),
                  // Lock Overlay
                  if (!isUnlocked)
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.lock, size: 8, color: Colors.white70),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            // Title Text
            Text(
              achievement.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isUnlocked ? FontWeight.bold : FontWeight.w500,
                color: isUnlocked ? Colors.white : Colors.white.withOpacity(0.5),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _showBadgeDetails(Achievement achievement, bool isUnlocked) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getIconData(achievement.icon),
                size: 64,
                color: isUnlocked ? AppTheme.primaryColor : Colors.grey,
              ),
              const SizedBox(height: 16),
              Text(
                achievement.title,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                achievement.description,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 24),
              if (!isUnlocked)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Requirement: ${achievement.conditionValue} ${achievement.conditionType.replaceAll('_', ' ')}',
                    style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'medal': return LucideIcons.medal;
      case 'flame': return LucideIcons.flame;
      case 'shield': return LucideIcons.shield;
      case 'cup': return LucideIcons.trophy;
      case 'users': return LucideIcons.users;
      case 'bolt': return LucideIcons.zap;
      case 'star': return LucideIcons.star;
      case 'heart': return LucideIcons.heart;
      default: return LucideIcons.award;
    }
  }
}
