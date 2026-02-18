import 'package:ascendly/core/theme.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:lucide_icons/lucide_icons.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Statistics')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Weekly Progress',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                          return Text(days[value.toInt()], style: const TextStyle(color: AppTheme.textSecondary));
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: [
                    BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 8, color: AppTheme.primaryColor, width: 16)]),
                    BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 10, color: AppTheme.primaryColor, width: 16)]),
                    BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 14, color: AppTheme.primaryColor, width: 16)]),
                    BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 15, color: AppTheme.secondaryColor, width: 16)]),
                    BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: 13, color: AppTheme.primaryColor, width: 16)]),
                    BarChartGroupData(x: 5, barRods: [BarChartRodData(toY: 10, color: AppTheme.primaryColor, width: 16)]),
                    BarChartGroupData(x: 6, barRods: [BarChartRodData(toY: 12, color: AppTheme.primaryColor, width: 16)]),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            _buildStatCard(
              'Total Days Cleared',
              '42 Days',
              LucideIcons.calendarCheck,
              AppTheme.successColor,
            ),
            const SizedBox(height: 16),
            _buildStatCard(
              'Best Streak',
              '14 Days',
              LucideIcons.award,
              AppTheme.primaryColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: AppTheme.textSecondary)),
              Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}
