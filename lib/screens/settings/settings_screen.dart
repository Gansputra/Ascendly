import 'package:ascendly/core/theme.dart';
import 'package:ascendly/providers/app_provider.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader(context, 'Appearance'),
          _buildSettingsTile(
            'Dark Mode',
            'Toggle between light and dark themes',
            LucideIcons.moon,
            trailing: Switch(
              value: appProvider.themeMode == ThemeMode.dark,
              onChanged: (value) => appProvider.toggleTheme(),
              activeColor: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader(context, 'Preferences'),
          _buildSettingsTile(
            'Notifications',
            'Manage daily reminders',
            LucideIcons.bell,
            onTap: () {},
          ),
          _buildSettingsTile(
            'Privacy',
            'Control who sees your progress',
            LucideIcons.lock,
            onTap: () {},
          ),
          const SizedBox(height: 24),
          _buildSectionHeader(context, 'About'),
          _buildSettingsTile(
            'Version',
            '1.1.0 (Advanced)',
            LucideIcons.info,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5), 
          fontWeight: FontWeight.bold, 
          fontSize: 12, 
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildSettingsTile(String title, String subtitle, IconData icon, {Widget? trailing, VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryColor),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: trailing,
      onTap: onTap,
    );
  }
}
