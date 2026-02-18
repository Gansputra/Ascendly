import 'package:ascendly/core/theme.dart';
import 'package:ascendly/services/auth_service.dart';
import 'package:ascendly/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class EmergencyButton extends StatelessWidget {
  const EmergencyButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Feeling Urges?',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: () => _showEmergencyDialog(context),
          borderRadius: BorderRadius.circular(50),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            decoration: BoxDecoration(
              color: AppTheme.errorColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(50),
              border: Border.all(color: AppTheme.errorColor, width: 2),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(LucideIcons.alertCircle, color: AppTheme.errorColor),
                SizedBox(width: 8),
                Text(
                  'Emergency',
                  style: TextStyle(
                    color: AppTheme.errorColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showEmergencyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Take a Breath'),
        content: const Text(
          'The urge is temporary. You are stronger than this moment. Take 5 deep breaths. If you have already relapsed, be honest and reset your streak. Every day is a new chance.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('I\'m staying strong'),
          ),
          TextButton(
            onPressed: () async {
              final auth = AuthService();
              final db = DatabaseService();
              await db.resetStreak(auth.currentUser!.id);
              if (context.mounted) {
                Navigator.pop(context);
                // Refresh logic would go here, maybe via provider
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Streak reset. Let\'s start again.')),
                );
              }
            },
            child: const Text(
              'Reset Streak',
              style: TextStyle(color: AppTheme.errorColor),
            ),
          ),
        ],
      ),
    );
  }
}
