import 'dart:async';
import 'package:ascendly/core/theme.dart';
import 'package:ascendly/models/user_profile.dart';
import 'package:ascendly/services/auth_service.dart';
import 'package:ascendly/services/database_service.dart';
import 'package:ascendly/widgets/emergency_button.dart';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:ascendly/models/quest_model.dart';
import 'package:ascendly/models/journal_model.dart';
import 'package:ascendly/services/achievement_service.dart';
import 'package:ascendly/services/gamification_service.dart';
import 'package:ascendly/services/database_service.dart';
import 'package:ascendly/screens/settings/settings_screen.dart';
import 'package:intl/intl.dart';
import 'package:ascendly/widgets/skeleton.dart';
import 'package:ascendly/widgets/streak_gauge.dart';
import 'package:ascendly/screens/onboarding/personalization_screen.dart';
import 'package:ascendly/services/home_widget_service.dart';
import 'package:lucide_icons/lucide_icons.dart';



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
  bool _hasJournalToday = false;

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
    final hasJournal = await _dbService.hasJournalToday(_authService.currentUser!.id);
    
    if (mounted) {
      if (profile == null || profile.goal == null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const PersonalizationScreen()),
        );
        return;
      }
      setState(() {
        _profile = profile;
        _isLoading = false;
        _hasJournalToday = hasJournal;
        if (profile?.streakStartDate != null) {
          _currentDuration = DateTime.now().toUtc().difference(profile!.streakStartDate!.toUtc());
        }
      });
      // Check achievements after loading profile
      AchievementService().checkAchievements(_authService.currentUser!.id, context: context);
      // Complete daily login quest
      GamificationService().completeQuest(_authService.currentUser!.id, 'daily_login', context: context);
      
      // Update Home Widget
      HomeWidgetService.updateStreak(profile.streakStartDate);
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
          ? const DashboardSkeleton()
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
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SettingsScreen()));
                            },
                            child: CircleAvatar(
                              radius: 20,
                              backgroundColor: AppTheme.surfaceColor,
                              backgroundImage: _profile?.avatarUrl != null ? NetworkImage(_profile!.avatarUrl!) : null,
                              child: _profile?.avatarUrl == null
                                  ? Icon(LucideIcons.user, size: 20, color: AppTheme.textSecondary)
                                  : null,

                            ),
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
                              'STAYING STRONG',
                              style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, letterSpacing: 3, fontSize: 12),
                            ),
                            const SizedBox(height: 32),
                            StreakGauge(
                              duration: _currentDuration,
                              size: 280,
                            ),
                            const SizedBox(height: 32),
                            Text(
                              _formatDuration(_currentDuration),
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                                fontFamily: 'monospace',
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'TOTAL PROGRESS',
                              style: TextStyle(color: Colors.white54, fontSize: 10, letterSpacing: 2),
                            ),
                            const SizedBox(height: 24),
                            // XP Progress Bar
                            if (_profile != null) ...[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Level ${_profile!.level}',
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        GamificationService().getLevelTitle(_profile!.level),
                                        style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10, letterSpacing: 1),
                                      ),
                                    ],
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
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton.icon(
                                    onPressed: _showQuestsHub,
                                    icon: const Icon(Icons.auto_awesome, size: 16, color: Colors.white70),
                                    label: const Text('DAILY QUESTS', style: TextStyle(color: Colors.white70, fontSize: 10, letterSpacing: 1)),
                                    style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                                  ),
                                ],
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
                    const SizedBox(height: 32),
                    FadeInUp(
                      delay: const Duration(milliseconds: 300),
                      child: GestureDetector(
                        onTap: _hasJournalToday ? null : _showJournalModal,
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: _hasJournalToday 
                              ? LinearGradient(colors: [Colors.green.withOpacity(0.2), Colors.green.withOpacity(0.05)])
                              : LinearGradient(colors: [AppTheme.primaryColor.withOpacity(0.2), AppTheme.primaryColor.withOpacity(0.05)]),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: _hasJournalToday ? Colors.green.withOpacity(0.3) : AppTheme.primaryColor.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: _hasJournalToday ? Colors.green.withOpacity(0.2) : AppTheme.primaryColor.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _hasJournalToday ? Icons.check_circle : Icons.edit_note,
                                  color: _hasJournalToday ? Colors.green : AppTheme.primaryColor,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _hasJournalToday ? 'Check-in Complete' : 'Daily Check-in',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                    Text(
                                      _hasJournalToday ? 'Come back tomorrow!' : 'How are you feeling today?',
                                      style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              if (!_hasJournalToday)
                                const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white24),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Center(child: EmergencyButton(onReset: _loadProfile)),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
    );
  }

  void _showJournalModal() {
    String selectedMood = 'happy';
    final noteController = TextEditingController();
    final moods = [
      {'id': 'happy', 'emoji': '😊', 'label': 'Happy'},
      {'id': 'strong', 'emoji': '💪', 'label': 'Strong'},
      {'id': 'anxious', 'emoji': '😨', 'label': 'Anxious'},
      {'id': 'sad', 'emoji': '😔', 'label': 'Sad'},
      {'id': 'struggling', 'emoji': '😫', 'label': 'Struggling'},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surfaceColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 32,
            left: 32,
            right: 32,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('How are you feeling?', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: moods.map((m) {
                  final isSelected = selectedMood == m['id'];
                  return GestureDetector(
                    onTap: () => setModalState(() => selectedMood = m['id']!),
                    child: Column(
                      children: [
                        Opacity(
                          opacity: isSelected ? 1 : 0.4,
                          child: Text(m['emoji']!, style: const TextStyle(fontSize: 32)),
                        ),
                        const SizedBox(height: 4),
                        Text(m['label']!, style: TextStyle(fontSize: 10, color: isSelected ? Colors.white : Colors.white24)),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: noteController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Any thoughts or notes for today?',
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.05),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final journal = Journal(
                      userId: _authService.currentUser!.id,
                      mood: selectedMood,
                      note: noteController.text,
                      createdAt: DateTime.now(),
                    );
                    await _dbService.addJournalEntry(journal);
                    if (context.mounted) {
                      Navigator.pop(context);
                      _loadProfile();
                      GamificationService().completeQuest(_authService.currentUser!.id, 'daily_journal', context: context);
                    }
                  },
                  child: const Text('Save Check-in'),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  void _showQuestsHub() async {
    final quests = await _dbService.getQuests();
    final userQuests = await _dbService.getUserQuests(_authService.currentUser!.id);

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Daily Quests', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const Text('Complete tasks daily to earn bonus XP', style: TextStyle(color: AppTheme.textSecondary)),
              const SizedBox(height: 24),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      ...quests.map((q) {
                        final isDone = userQuests.any((uq) => uq.questId == q.id && uq.isCompletedToday);
                        return _buildQuestItem(q, isDone);
                      }),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuestItem(Quest quest, bool isDone) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDone ? Colors.green.withOpacity(0.3) : Colors.transparent),
      ),
      child: Row(
        children: [
          Icon(isDone ? Icons.check_circle : Icons.circle_outlined, color: isDone ? Colors.green : Colors.grey),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(quest.title, style: TextStyle(fontWeight: FontWeight.bold, decoration: isDone ? TextDecoration.lineThrough : null)),
                Text(quest.description, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
              ],
            ),
          ),
          Text('+${quest.xpReward} XP', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
