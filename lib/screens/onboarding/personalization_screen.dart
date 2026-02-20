import 'package:ascendly/core/theme.dart';
import 'package:ascendly/models/user_profile.dart';
import 'package:ascendly/screens/main_wrapper.dart';
import 'package:ascendly/services/auth_service.dart';
import 'package:ascendly/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:lucide_icons/lucide_icons.dart';

class PersonalizationScreen extends StatefulWidget {
  const PersonalizationScreen({super.key});

  @override
  State<PersonalizationScreen> createState() => _PersonalizationScreenState();
}

class _PersonalizationScreenState extends State<PersonalizationScreen> {
  String? _selectedGoal;
  final _nicknameController = TextEditingController();
  final _dbService = DatabaseService();
  final _authService = AuthService();
  bool _isLoading = false;

  final List<Map<String, dynamic>> _goals = [
    {'id': 'gooning', 'label': 'No Gooning', 'icon': LucideIcons.brain},
    {'id': 'rokok', 'label': 'Stop Smoking', 'icon': LucideIcons.wind},
    {'id': 'gaming', 'label': 'Less Gaming', 'icon': LucideIcons.gamepad2},
  ];

  Future<void> _save() async {
    if (_selectedGoal == null || _nicknameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all fields')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final profile = UserProfile(
        id: _authService.currentUser!.id,
        nickname: _nicknameController.text,
        goal: _selectedGoal,
        streakStartDate: DateTime.now(),
        createdAt: DateTime.now(),
      );
      await _dbService.upsertProfile(profile);
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainWrapper()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving profile: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              FadeInDown(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Let\'s get to know you',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('What is your primary goal?'),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              FadeInUp(
                child: TextField(
                  controller: _nicknameController,
                  decoration: const InputDecoration(
                    labelText: 'Preferred Name',
                    hintText: 'e.g. Victor',
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: ListView.separated(
                  itemCount: _goals.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final goal = _goals[index];
                    final isSelected = _selectedGoal == goal['id'];
                    return FadeInRight(
                      delay: Duration(milliseconds: 100 * index),
                      child: Card(
                        margin: EdgeInsets.zero,
                        elevation: isSelected ? 4 : (Theme.of(context).brightness == Brightness.dark ? 0 : 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: isSelected ? AppTheme.primaryColor : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        color: isSelected 
                            ? AppTheme.primaryColor.withOpacity(0.1) 
                            : Theme.of(context).colorScheme.surface,
                        child: InkWell(
                          onTap: () => setState(() => _selectedGoal = goal['id']),
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Row(
                              children: [
                                Icon(
                                  goal['icon'],
                                  color: isSelected ? AppTheme.primaryColor : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  goal['label'],
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    color: isSelected ? AppTheme.primaryColor : Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                                const Spacer(),
                                if (isSelected)
                                  const Icon(LucideIcons.checkCircle2, color: AppTheme.primaryColor),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              FadeInUp(
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _save,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Continue'),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
