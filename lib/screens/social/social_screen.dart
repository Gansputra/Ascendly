import 'dart:ui';
import 'package:ascendly/core/theme.dart';
import 'package:ascendly/models/social_models.dart';
import 'package:ascendly/models/user_profile.dart';
import 'package:ascendly/services/auth_service.dart';
import 'package:ascendly/services/database_service.dart';
import 'package:ascendly/services/gamification_service.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:animate_do/animate_do.dart';
import 'package:ascendly/widgets/skeleton.dart';
import 'package:ascendly/services/presence_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';

class SocialScreen extends StatefulWidget {
  const SocialScreen({Key? key}) : super(key: key);

  @override
  State<SocialScreen> createState() => _SocialScreenState();
}

class _SocialScreenState extends State<SocialScreen> {
  final _dbService = DatabaseService();
  final _authService = AuthService();
  List<Map<String, dynamic>> _pendingRequests = [];
  List<Map<String, dynamic>> _currentFriends = []; // Added to fix search dialog error
  bool _isLoading = true;
  late Stream<List<Map<String, dynamic>>> _friendsStream;

  @override
  void initState() {
    super.initState();
    _friendsStream = _dbService.getFriendsStream(_authService.currentUser!.id);
    _loadFriends();
  }

  Future<void> _loadFriends() async {
    try {
      final pending = await _dbService.getPendingRequests(_authService.currentUser!.id);
      final friends = await _dbService.getFriends(_authService.currentUser!.id);
      if (mounted) {
        setState(() {
          _pendingRequests = pending;
          _currentFriends = friends;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('SocialScreen: Error loading friends: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.userPlus),
            onPressed: _showAddFriendDialog,
          ),
        ],
      ),
      body: _isLoading
          ? const SocialSkeleton()
          : CustomScrollView(
              slivers: [
                if (_pendingRequests.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'FRIEND REQUESTS (${_pendingRequests.length})',
                            style: TextStyle(
                              fontSize: 12, 
                              fontWeight: FontWeight.bold, 
                              letterSpacing: 1.5, 
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                          const SizedBox(height: 12),
                          ..._pendingRequests.map((req) => _buildPendingRequestTile(req)),
                          const Divider(height: 32, color: Colors.white10),
                        ],
                      ),
                    ),
                  ),
                StreamBuilder<List<Map<String, dynamic>>>(
                  stream: _friendsStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting && _isLoading) {
                      return const SliverFillRemaining(child: Center(child: CircularProgressIndicator()));
                    }
                    final friends = snapshot.data ?? _currentFriends;
                    // Update current friends for search dialog
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (snapshot.hasData && _currentFriends != snapshot.data) {
                        _currentFriends = snapshot.data!;
                      }
                    });
                    
                    if (friends.isEmpty && _pendingRequests.isEmpty) {
                      return SliverFillRemaining(child: _buildEmptyState());
                    }
                    return SliverPadding(
                      padding: const EdgeInsets.all(16),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildFriendTile(friends[index]),
                          ),
                          childCount: friends.length,
                        ),
                      ),
                    );
                  },
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
    );
  }

  Widget _buildPendingRequestTile(Map<String, dynamic> request) {
    final sender = request['profiles'];
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            const CircleAvatar(
              backgroundColor: AppTheme.primaryColor,
              child: Icon(Icons.person, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(sender['nickname'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('wants to be your friend', style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.check_circle, color: Colors.green),
              onPressed: () async {
                await _dbService.acceptFriendRequest(_authService.currentUser!.id, sender['id']);
                _loadFriends();
              },
            ),
            IconButton(
              icon: const Icon(Icons.cancel, color: Colors.redAccent),
              onPressed: () async {
                await _dbService.declineFriendRequest(_authService.currentUser!.id, sender['id']);
                _loadFriends();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.users, size: 64, color: AppTheme.textSecondary.withOpacity(0.2)),
          const SizedBox(height: 16),
          const Text('Your circle is empty', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const Text('Add friends to start the journey together.', style: TextStyle(color: AppTheme.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildFriendTile(Map<String, dynamic> friend) {
    final profileData = friend['profiles'];
    final lastSeenStr = profileData['last_seen'] != null 
        ? DateTime.parse(profileData['last_seen']) 
        : null;
    final status = PresenceService.formatLastSeen(lastSeenStr);
    final isOnline = status == 'Online';

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => ChatScreen(
              friendId: profileData['id'], 
              friendNickname: profileData['nickname'],
              friendLastSeen: lastSeenStr,
            ),
          ));
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Stack(
                children: [
                  const CircleAvatar(
                    backgroundColor: AppTheme.primaryColor,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  if (isOnline)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: AppTheme.successColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.surfaceColor, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(profileData['nickname'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(
                      status, 
                      style: TextStyle(
                        color: isOnline ? AppTheme.successColor : AppTheme.textSecondary, 
                        fontSize: 12
                      )
                    ),
                  ],
                ),
              ),
              const Icon(LucideIcons.messageCircle, color: AppTheme.primaryColor),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddFriendDialog() {
    final searchController = TextEditingController();
    List<UserProfile> searchResults = [];
    bool isSearching = false;

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
              const Text('Add Friend', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const Text('Search by Nickname or User ID', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
              const SizedBox(height: 24),
              TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Enter nickname or ID...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.05),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
                onChanged: (val) async {
                  if (val.length < 3) {
                    setModalState(() {
                      searchResults = [];
                    });
                    return;
                  }
                  
                  setModalState(() => isSearching = true);
                  try {
                    final results = await _dbService.searchUsers(val);
                    setModalState(() {
                      searchResults = results.where((u) => u.id != _authService.currentUser!.id).toList();
                      isSearching = false;
                    });
                  } catch (e) {
                    setModalState(() => isSearching = false);
                  }
                },
              ),
              const SizedBox(height: 16),
              if (isSearching)
                Column(
                  children: List.generate(3, (index) => const Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: Skeleton(height: 60),
                  )),
                )
              else if (searchController.text.length >= 3 && searchResults.isEmpty)
                Center(child: Padding(padding: const EdgeInsets.all(20), child: Text('No users found', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)))))
              else
                SizedBox(
                  height: 300,
                  child: ListView.builder(
                    itemCount: searchResults.length,
                    itemBuilder: (context, index) {
                      final user = searchResults[index];
                      final isAlreadyFriend = _currentFriends.any((f) {
                        try {
                          return f['profiles']['id'] == user.id;
                        } catch (e) {
                          return false;
                        }
                      });
                      
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        onTap: () => _showUserProfilePreview(user, isAlreadyFriend),
                        leading: const CircleAvatar(backgroundColor: AppTheme.primaryColor, child: Icon(Icons.person, color: Colors.white, size: 20)),
                        title: Text(user.nickname ?? 'Anonymous', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('Tap to view profile', style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5))),
                        trailing: isAlreadyFriend 
                          ? const Icon(LucideIcons.checkCircle2, color: AppTheme.successColor, size: 20)
                          : const Icon(Icons.chevron_right, color: AppTheme.primaryColor),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showUserProfilePreview(UserProfile user, bool isAlreadyFriend) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showDialog(
      context: context,
      builder: (context) => ZoomIn(
        duration: const Duration(milliseconds: 300),
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 40),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              // Glassmorphic Container
              ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(24, 64, 24, 24),
                    decoration: BoxDecoration(
                      color: (isDark ? Colors.white : Colors.black).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          user.nickname ?? 'Anonymous',
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Level ${user.level}',
                            style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Stats Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildMiniStat('Goal', user.goal ?? 'Not set', LucideIcons.target),
                            _buildMiniStat('XP', '${user.xp}', LucideIcons.zap),
                          ],
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          child: isAlreadyFriend
                            ? OutlinedButton.icon(
                                onPressed: () => Navigator.pop(context),
                                icon: const Icon(LucideIcons.check),
                                label: const Text('Already Friends'),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  side: BorderSide(color: AppTheme.successColor.withOpacity(0.5)),
                                  foregroundColor: AppTheme.successColor,
                                ),
                              )
                            : ElevatedButton.icon(
                                onPressed: () async {
                                  await _dbService.addFriend(_authService.currentUser!.id, user.id);
                                  if (context.mounted) {
                                    Navigator.pop(context); // Close preview
                                    Navigator.pop(context); // Close search dialog
                                    _loadFriends();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Added ${user.nickname} as friend!')),
                                    );
                                  }
                                },
                                icon: const Icon(LucideIcons.userPlus),
                                label: const Text('Add Friend'),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  backgroundColor: AppTheme.primaryColor,
                                  foregroundColor: Colors.white,
                                  elevation: 8,
                                  shadowColor: AppTheme.primaryColor.withOpacity(0.4),
                                ),
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Floating Avatar
              Positioned(
                top: -40,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: AppTheme.primaryColor,
                    child: Text(
                      (user.nickname ?? 'A')[0].toUpperCase(),
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 20, color: AppTheme.primaryColor.withOpacity(0.7)),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary, letterSpacing: 1)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class ChatScreen extends StatefulWidget {
  final String friendId;
  final String friendNickname;
  final DateTime? friendLastSeen;

  const ChatScreen({
    Key? key,
    required this.friendId,
    required this.friendNickname,
    this.friendLastSeen,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final _dbService = DatabaseService();
  final _authService = AuthService();
  late Stream<List<Message>> _chatStream;
  late RealtimeChannel _typingChannel;
  bool _isFriendTyping = false;
  Timer? _typingTimer;

  @override
  void initState() {
    super.initState();
    _chatStream = _dbService.getChatStream(_authService.currentUser!.id, widget.friendId);
    
    // Typing indicator channel
    final roomId = _getRoomId(_authService.currentUser!.id, widget.friendId);
    _typingChannel = PresenceService().getTypingChannel(roomId);
    
    _typingChannel.onBroadcast(event: 'typing', callback: (payload) {
      if (payload['user_id'] == widget.friendId) {
        if (mounted) {
          setState(() {
            _isFriendTyping = payload['is_typing'] ?? false;
          });
        }
      }
    }).subscribe();
  }

  String _getRoomId(String id1, String id2) {
    final ids = [id1, id2]..sort();
    return ids.join('_');
  }

  @override
  void dispose() {
    _messageController.dispose();
    _typingTimer?.cancel();
    _typingChannel.unsubscribe();
    super.dispose();
  }

  void _onTypingChanged(String value) {
    PresenceService().setTyping(
      _getRoomId(_authService.currentUser!.id, widget.friendId),
      _authService.currentUser!.id,
      value.isNotEmpty,
    );

    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 2), () {
      PresenceService().setTyping(
        _getRoomId(_authService.currentUser!.id, widget.friendId),
        _authService.currentUser!.id,
        false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.friendNickname, style: const TextStyle(fontSize: 16)),
            Text(
              PresenceService.formatLastSeen(widget.friendLastSeen),
              style: TextStyle(
                fontSize: 10, 
                color: PresenceService.formatLastSeen(widget.friendLastSeen) == 'Online' 
                  ? AppTheme.successColor 
                  : AppTheme.textSecondary
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Message>>(
              stream: _chatStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const ChatSkeleton();
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No messages yet. Say hi!'));
                }
                final messages = snapshot.data!;
                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message.senderId == _authService.currentUser!.id;
                    
                    return FadeInUp(
                      duration: const Duration(milliseconds: 200),
                      child: _buildMessageBubble(message, isMe),
                    );
                  },
                );
              },
            ),
          ),
          if (_isFriendTyping)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${widget.friendNickname} is typing...',
                  style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: AppTheme.primaryColor),
                ),
              ),
            ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Message message, bool isMe) {
    final timeStr = DateFormat('HH:mm').format(message.createdAt.toLocal());
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 4),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isMe ? AppTheme.primaryColor : (isDark ? AppTheme.surfaceColor : Colors.grey[200]),
              borderRadius: BorderRadius.circular(16).copyWith(
                bottomRight: isMe ? const Radius.circular(0) : const Radius.circular(16),
                bottomLeft: isMe ? const Radius.circular(16) : const Radius.circular(0),
              ),
            ),
            child: Text(
              message.content, 
              style: TextStyle(
                color: isMe ? Colors.white : (isDark ? Colors.white : Colors.black87),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8, left: 4, right: 4),
            child: Text(
              timeStr,
              style: TextStyle(
                fontSize: 10,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).colorScheme.surface,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              onChanged: _onTypingChanged,
              decoration: const InputDecoration(
                hintText: 'Type a message...',
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(LucideIcons.send, color: AppTheme.primaryColor),
            onPressed: () async {
              final content = _messageController.text.trim();
              if (content.isNotEmpty) {
                _messageController.clear();
                _onTypingChanged(''); // Stop typing indicator
                await _dbService.sendMessage(
                  _authService.currentUser!.id,
                  widget.friendId,
                  content,
                );
                if (mounted) {
                  GamificationService().completeQuest(_authService.currentUser!.id, 'social_chat', context: context);
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
