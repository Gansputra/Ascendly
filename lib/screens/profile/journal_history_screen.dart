import 'package:ascendly/core/theme.dart';
import 'package:ascendly/models/journal_model.dart';
import 'package:ascendly/services/auth_service.dart';
import 'package:ascendly/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:animate_do/animate_do.dart';
import 'package:ascendly/widgets/skeleton.dart';

class JournalHistoryScreen extends StatefulWidget {
  const JournalHistoryScreen({super.key});

  @override
  State<JournalHistoryScreen> createState() => _JournalHistoryScreenState();
}

class _JournalHistoryScreenState extends State<JournalHistoryScreen> {
  final _dbService = DatabaseService();
  final _authService = AuthService();
  List<Journal> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final history = await _dbService.getJournalHistory(_authService.currentUser!.id);
    setState(() {
      _history = history;
      _isLoading = false;
    });
  }

  String _getMoodEmoji(String mood) {
    switch (mood) {
      case 'happy': return '😊';
      case 'strong': return '💪';
      case 'anxious': return '😨';
      case 'sad': return '😔';
      case 'struggling': return '😫';
      default: return '😐';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mood History'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const ListSkeleton()
          : _history.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: _history.length,
                  itemBuilder: (context, index) {
                    final item = _history[index];
                    return FadeInLeft(
                      delay: Duration(milliseconds: index * 50),
                      child: _buildHistoryCard(item),
                    );
                  },
                ),
    );
  }

  Widget _buildEmptyState() {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 64, color: colorScheme.onSurface.withOpacity(0.1)),
          const SizedBox(height: 16),
          Text('No journals yet', style: TextStyle(color: colorScheme.onSurface.withOpacity(0.5))),
          const SizedBox(height: 8),
          Text('Start checking in on the dashboard!', style: TextStyle(color: colorScheme.onSurface.withOpacity(0.3), fontSize: 12)),
        ],
      ),
    );
  }


  Widget _buildHistoryCard(Journal journal) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.onSurface.withOpacity(0.05)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_getMoodEmoji(journal.mood), style: const TextStyle(fontSize: 32)),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      journal.mood.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10, 
                        fontWeight: FontWeight.bold, 
                        letterSpacing: 2, 
                        color: colorScheme.onSurface.withOpacity(0.5)
                      ),
                    ),
                    Text(
                      DateFormat('MMM dd, yyyy').format(journal.createdAt),
                      style: TextStyle(fontSize: 10, color: colorScheme.onSurface.withOpacity(0.3)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (journal.note != null && journal.note!.isNotEmpty)
                  Text(
                    journal.note!,
                    style: TextStyle(
                      fontSize: 14, 
                      height: 1.5,
                      color: colorScheme.onSurface,
                    ),
                  )
                else
                  Text(
                    'No additional notes.',
                    style: TextStyle(
                      fontSize: 14, 
                      fontStyle: FontStyle.italic, 
                      color: colorScheme.onSurface.withOpacity(0.3)
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

}
