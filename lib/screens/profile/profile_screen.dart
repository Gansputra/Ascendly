import 'package:ascendly/core/theme.dart';
import 'package:ascendly/models/user_profile.dart';
import 'package:ascendly/screens/auth/login_screen.dart';
import 'package:ascendly/screens/profile/badges_screen.dart';
import 'package:ascendly/screens/profile/journal_history_screen.dart';
import 'package:ascendly/services/auth_service.dart';
import 'package:ascendly/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
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
                  const Center(
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: AppTheme.surfaceColor,
                      child: Icon(LucideIcons.user, size: 40, color: AppTheme.textSecondary),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    _profile?.nickname ?? 'Anonymous',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    _authService.currentUser?.email ?? '',
                    style: const TextStyle(color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 40),
                  _buildProfileTile(
                    'Current Goal',
                    _profile?.goal ?? 'Not set',
                    LucideIcons.target,
                  ),
                  const SizedBox(height: 12),
                  _buildProfileTile(
                    'Joined',
                    'Feb 2024', // Simplified for demo
                    LucideIcons.calendar,
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const BadgesScreen()));
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: _buildProfileTile(
                      'My Achievements',
                      'View your badges',
                      LucideIcons.medal,
                      trailing: const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
                    ),
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const JournalHistoryScreen()));
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: _buildProfileTile(
                      'My Mood History',
                      'Check your progress',
                      LucideIcons.heart,
                      trailing: const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
                    ),
                  ),
                  const SizedBox(height: 48),
                  ElevatedButton(
                    onPressed: _logout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.errorColor.withOpacity(0.1),
                      foregroundColor: AppTheme.errorColor,
                      elevation: 0,
                    ),
                    child: const Text('Logout'),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileTile(String title, String subtitle, IconData icon, {Widget? trailing}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryColor),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                Text(subtitle, style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }
}
