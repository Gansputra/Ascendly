import 'dart:async';
import 'package:ascendly/core/theme.dart';
import 'package:ascendly/models/user_profile.dart';
import 'package:ascendly/services/auth_service.dart';
import 'package:ascendly/services/database_service.dart';
import 'package:ascendly/widgets/emergency_button.dart';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:ascendly/services/achievement_service.dart';
import 'package:ascendly/services/gamification_service.dart';
import 'package:ascendly/screens/settings/settings_screen.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _authService = AuthService();
  final _dbService = DatabaseService();
  UserProfile? _profile;
  bool _isLoading = true;
  late Timer _timer;
  Duration _currentDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_profile?.streakStartDate != null) {
        setState(() {
          _currentDuration = DateTime.now().toUtc().difference(_profile!.streakStartDate!.toUtc());
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final profile = await _dbService.getProfile(_authService.currentUser!.id);
    if (mounted) {
      setState(() {
        _profile = profile;
        _isLoading = false;
        if (profile?.streakStartDate != null) {
          _currentDuration = DateTime.now().toUtc().difference(profile!.streakStartDate!.toUtc());
        }
      });
      // Check achievements after loading profile
      AchievementService().checkAchievements(_authService.currentUser!.id, context: context);
    }
  }

  String _formatDuration(Duration d) {
    int days = d.inDays;
    int hours = d.inHours % 24;
    int minutes = d.inMinutes % 60;
    int seconds = d.inSeconds % 60;
    return "${days}d ${hours}h ${minutes}m ${seconds}s";
  }

  final List<String> _motivations = [
    "One day at a time, one step closer to your best self.",
    "Your future self will thank you for the hard work you put in today.",
    "The secret of change is to focus all of your energy, not on fighting the old, but on building the new.",
    "Discipline is choosing between what you want now and what you want most.",
    "You don't have to be perfect, you just have to be better than yesterday.",
    "Mastering others is strength. Mastering yourself is true power.",
    "Don't look back, you're not going that way."
  ];

  String get _dailyMotivation {
    final now = DateTime.now();
    final index = now.day % _motivations.length;
    return _motivations[index];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FadeInDown(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hi, ${_profile?.nickname ?? "Friend"}',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              Text(DateFormat('EEEE, d MMM').format(DateTime.now()), style: const TextStyle(color: AppTheme.textSecondary)),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.settings_outlined),
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SettingsScreen()));
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    FadeIn(
                      duration: const Duration(seconds: 1),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryColor.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'STAYING STRONG FOR',
                              style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, letterSpacing: 2),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _formatDuration(_currentDuration),
                              style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, fontFamily: 'Courier'),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'REAL-TIME PROGRESS',
                              style: TextStyle(color: Colors.white54, fontSize: 12, letterSpacing: 2),
                            ),
                            const SizedBox(height: 24),
                            // XP Progress Bar
                            if (_profile != null) ...[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Level ${_profile!.level}',
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    '${_profile!.xp} / ${GamificationService().xpForNextLevel(_profile!.level)} XP',
                                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: LinearProgressIndicator(
                                  value: _profile!.xp / GamificationService().xpForNextLevel(_profile!.level),
                                  backgroundColor: Colors.white.withOpacity(0.1),
                                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                  minHeight: 8,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    FadeInUp(
                      delay: const Duration(milliseconds: 200),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Daily Pulse', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                            const SizedBox(height: 12),
                            Text(
                              _dailyMotivation,
                              style: const TextStyle(fontSize: 16, height: 1.5, fontStyle: FontStyle.italic),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Center(child: EmergencyButton(onReset: _loadProfile)),
                  ],
                ),
              ),
            ),
    );
  }
}
