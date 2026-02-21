import 'package:ascendly/core/theme.dart';
import 'package:ascendly/models/user_profile.dart';
import 'package:ascendly/screens/auth/login_screen.dart';
import 'package:ascendly/screens/profile/badges_screen.dart';
import 'package:ascendly/screens/profile/journal_history_screen.dart';
import 'package:ascendly/services/auth_service.dart';
import 'package:ascendly/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';
import 'package:ascendly/widgets/skeleton.dart';



class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _authService = AuthService();
  final _dbService = DatabaseService();
  UserProfile? _profile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await _dbService.getProfile(_authService.currentUser!.id);
    if (mounted) {
      setState(() {
        _profile = profile;
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    await _authService.signOut();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: _isLoading
          ? const ProfileSkeleton()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Center(

                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      child: Icon(LucideIcons.user, size: 40, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),

                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    _profile?.nickname ?? 'Anonymous',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _authService.currentUser?.email ?? '',
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
                  ),
                  const SizedBox(height: 32),
                  // Focus Card for Goal
                  FadeIn(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryColor.withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(LucideIcons.target, color: Colors.white, size: 24),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'MY ULTIMATE GOAL',
                                  style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Stop ${_profile?.goal ?? 'Finding my way...'}',
                                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                ),

                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Staggered Menu Items
                  FadeInUp(
                    delay: const Duration(milliseconds: 100),
                    child: _buildProfileTile(
                      'Joined',
                      DateFormat('MMMM yyyy').format(_profile?.createdAt ?? DateTime.now()),
                      LucideIcons.calendar,
                    ),
                  ),
                  const SizedBox(height: 16),
                  FadeInUp(
                    delay: const Duration(milliseconds: 200),
                    child: _buildProfileTile(
                      'My Achievements',
                      'View your earned badges',
                      LucideIcons.medal,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BadgesScreen())),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.white24),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FadeInUp(
                    delay: const Duration(milliseconds: 300),
                    child: _buildProfileTile(
                      'My Mood History',
                      'Check your journaling progress',
                      LucideIcons.heart,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const JournalHistoryScreen())),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.white24),
                    ),
                  ),

                  const SizedBox(height: 48),
                  FadeInUp(
                    delay: const Duration(milliseconds: 400),
                    child: ElevatedButton(
                      onPressed: _logout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.errorColor.withOpacity(0.1),
                        foregroundColor: AppTheme.errorColor,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: const Text('Logout Account'),
                    ),
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileTile(String title, String subtitle, IconData icon, {VoidCallback? onTap, Widget? trailing}) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          decoration: BoxDecoration(
            color: isDark ? colorScheme.surface : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: colorScheme.onSurface.withOpacity(0.05)),
            boxShadow: isDark ? null : [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: AppTheme.primaryColor, size: 20),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title.toUpperCase(),
                      style: TextStyle(
                        color: colorScheme.onSurface.withOpacity(0.5), 
                        fontSize: 10, 
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle, 
                      style: TextStyle(
                        fontWeight: FontWeight.bold, 
                        color: colorScheme.onSurface,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
        ),
      ),
    );
  }

}
