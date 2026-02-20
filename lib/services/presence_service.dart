import 'dart:async';
import 'package:ascendly/services/database_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PresenceService {
  static final PresenceService _instance = PresenceService._internal();
  factory PresenceService() => _instance;
  PresenceService._internal();

  final _supabase = Supabase.instance.client;
  final _dbService = DatabaseService();
  RealtimeChannel? _presenceChannel;
  Timer? _statusTimer;

  // Track online status
  void initialize(String userId) {
    if (_presenceChannel != null) return;

    _presenceChannel = _supabase.channel('online-status');

    _presenceChannel!.subscribe((status, error) async {
      if (status == RealtimeSubscribeStatus.subscribed) {
        await _presenceChannel!.track({
          'user_id': userId,
          'online_at': DateTime.now().toUtc().toIso8601String(),
        });
      }
    });

    // Periodically update last_seen in DB as well
    _statusTimer = Timer.periodic(const Duration(minutes: 2), (timer) {
      _dbService.updateLastSeen(userId);
    });
    _dbService.updateLastSeen(userId);
  }

  void dispose() {
    _statusTimer?.cancel();
    _presenceChannel?.unsubscribe();
    _presenceChannel = null;
  }

  // Typing Indicators
  RealtimeChannel getTypingChannel(String roomId) {
    return _supabase.channel('typing:$roomId');
  }

  void setTyping(String roomId, String userId, bool isTyping) {
    final channel = getTypingChannel(roomId);
    channel.sendBroadcastMessage(
      event: 'typing',
      payload: {'user_id': userId, 'is_typing': isTyping},
    );
  }

  static String formatLastSeen(DateTime? lastSeen) {
    if (lastSeen == null) return 'Offline';
    final now = DateTime.now().toUtc();
    final difference = now.difference(lastSeen.toUtc());

    if (difference.inMinutes < 2) return 'Online';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    if (difference.inDays < 30) return '${(difference.inDays / 7).floor()}w ago';
    if (difference.inDays < 365) return '${(difference.inDays / 30).floor()}mo ago';
    return '${(difference.inDays / 365).floor()}y ago';
  }
}
