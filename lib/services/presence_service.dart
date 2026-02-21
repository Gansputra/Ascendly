import 'dart:async';
import 'package:ascendly/services/database_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class PresenceService {
  static final PresenceService _instance = PresenceService._internal();
  factory PresenceService() => _instance;
  PresenceService._internal();

  final _supabase = Supabase.instance.client;
  final _dbService = DatabaseService();
  RealtimeChannel? _presenceChannel;
  Timer? _statusTimer;
  
  // Real-time synchronization
  final _onlineUsersController = StreamController<Set<String>>.broadcast();
  Stream<Set<String>> get onlineUsersStream => _onlineUsersController.stream;
  Set<String> _onlineUserIds = {};
  Set<String> get onlineUserIds => _onlineUserIds;

  // Track online status
  void initialize(String userId) {
    if (_presenceChannel != null) return;

    _presenceChannel = _supabase.channel('online-status', opts: RealtimeChannelConfig(
      presence: PresenceOpts(key: userId),
    ));


    _presenceChannel!.onPresenceSync((payload) => _syncPresence());
    _presenceChannel!.onPresenceJoin((payload) => _syncPresence());
    _presenceChannel!.onPresenceLeave((payload) => _syncPresence());

    _presenceChannel!.subscribe((status, error) async {
      if (status == RealtimeSubscribeStatus.subscribed) {
        await _presenceChannel!.track({
          'user_id': userId,
          'online_at': DateTime.now().toUtc().toIso8601String(),
        });
      }
    });



    // Periodically update last_seen in DB
    _statusTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _dbService.updateLastSeen(userId);
    });
    _dbService.updateLastSeen(userId);
  }

  void _syncPresence() {
    final Set<String> onlineIds = {};
    try {
      final dynamic rawState = _presenceChannel!.presenceState();
      
      if (rawState is Map) {

        rawState.forEach((key, value) {
          // If key is a UUID, add it
          if (key.length > 30) onlineIds.add(key); // Likely a UUID
          
          if (value is List) {
            for (final presence in value) {
              if (presence is Presence && presence.payload['user_id'] != null) {
                onlineIds.add(presence.payload['user_id'].toString());
              } else if (presence is Map && presence['payload']?['user_id'] != null) {
                onlineIds.add(presence['payload']['user_id'].toString());
              }
            }
          }
        });
      }

    } catch (e) {
      debugPrint('PresenceService: Sync Error: $e');
    }

    _onlineUserIds = onlineIds;
    _onlineUsersController.add(onlineIds);
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

  static String formatLastSeen(DateTime? lastSeen, {bool isOnline = false}) {
    if (isOnline) return 'Online';
    if (lastSeen == null) return 'Offline';
    
    final now = DateTime.now().toUtc();
    final difference = now.difference(lastSeen.toUtc());

    if (difference.inMinutes < 5) return 'Online'; // Buffer for DB delay
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    if (difference.inDays < 30) return '${(difference.inDays / 7).floor()}w ago';
    if (difference.inDays < 365) return '${(difference.inDays / 30).floor()}mo ago';
    return '${(difference.inDays / 365).floor()}y ago';
  }
}
