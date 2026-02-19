import 'package:ascendly/core/theme.dart';
import 'package:ascendly/models/user_profile.dart';
import 'package:ascendly/services/auth_service.dart';
import 'package:ascendly/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:animate_do/animate_do.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  final _dbService = DatabaseService();
  final _authService = AuthService();
  UserProfile? _profile;
  List<Relapse> _relapses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final uid = _authService.currentUser!.id;
      final profile = await _dbService.getProfile(uid);
      final relapses = await _dbService.getRelapses(uid);
      if (mounted) {
        setState(() {
          _profile = profile;
          _relapses = relapses;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('StatsScreen: Error loading data: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load stats. Ensure database tables exist.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Insight Hub')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummarySection(),
                  const SizedBox(height: 32),
                  const Text('Recovery Calendar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _buildCalendar(),
                  const SizedBox(height: 32),
                  const Text('Weekly Trend', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _buildSimpleChart(),
                ],
              ),
            ),
    );
  }

  Widget _buildSummarySection() {
    return FadeInLeft(
      child: Row(
        children: [
          _buildStatCard('Total Days', '${_profile?.totalDaysCleared ?? 0}', Icons.check_circle_outline),
          const SizedBox(width: 16),
          _buildStatCard('Best Streak', '${_profile?.bestStreak ?? 0}', Icons.military_tech_outlined),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppTheme.primaryColor),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendar() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: TableCalendar(
        firstDay: DateTime.utc(2023, 01, 01),
        lastDay: DateTime.now(),
        focusedDay: DateTime.now(),
        calendarStyle: CalendarStyle(
          markerDecoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
          todayDecoration: BoxDecoration(color: AppTheme.primaryColor.withOpacity(0.5), shape: BoxShape.circle),
        ),
        eventLoader: (day) {
          return _relapses.where((r) => isSameDay(r.relapseDate, day)).toList();
        },
      ),
    );
  }

  Widget _buildSimpleChart() {
    // Generate data for the last 7 days
    final now = DateTime.now();
    final last7Days = List.generate(7, (index) {
      return DateTime(now.year, now.month, now.day).subtract(Duration(days: 6 - index));
    });

    return Container(
      height: 200,
      padding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 1,
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final date = last7Days[value.toInt()];
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      DateFormat('E').format(date)[0],
                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10),
                    ),
                  );
                },
              ),
            ),
          ),
          gridData: FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(7, (index) {
            final date = last7Days[index];
            final hasRelapsed = _relapses.any((r) => isSameDay(r.relapseDate, date));
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: hasRelapsed ? 0.2 : 1,
                  color: hasRelapsed ? AppTheme.errorColor : AppTheme.primaryColor,
                  width: 12,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
