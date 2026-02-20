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

class SocialScreen extends StatefulWidget {
  const SocialScreen({super.key});

  @override
  State<SocialScreen> createState() => _SocialScreenState();
}

class _SocialScreenState extends State<SocialScreen> {
  final _dbService = DatabaseService();
  final _authService = AuthService();
  List<Map<String, dynamic>> _friends = [];
  List<Map<String, dynamic>> _pendingRequests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFriends();
  }

  Future<void> _loadFriends() async {
    try {
      final friends = await _dbService.getFriends(_authService.currentUser!.id);
      final pending = await _dbService.getPendingRequests(_authService.currentUser!.id);
      if (mounted) {
        setState(() {
          _friends = friends;
          _pendingRequests = pending;
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
          ? const Center(child: CircularProgressIndicator())
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
                if (_friends.isEmpty && _pendingRequests.isEmpty)
                  SliverFillRemaining(child: _buildEmptyState())
                else
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildFriendTile(_friends[index]),
                        ),
                        childCount: _friends.length,
                      ),
                    ),
                  ),
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
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => ChatScreen(friendId: friend['profiles']['id'], friendNickname: friend['profiles']['nickname']),
          ));
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const CircleAvatar(
                backgroundColor: AppTheme.primaryColor,
                child: Icon(Icons.person, color: Colors.white),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(friend['profiles']['nickname'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const Text('Online', style: TextStyle(color: AppTheme.successColor, fontSize: 12)),
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
                const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))
              else if (searchController.text.length >= 3 && searchResults.isEmpty)
                Center(child: Padding(padding: const EdgeInsets.all(20), child: Text('No users found', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)))))
              else
                SizedBox(
                  height: 300,
                  child: ListView.builder(
                    itemCount: searchResults.length,
                    itemBuilder: (context, index) {
                      final user = searchResults[index];
                      final isAlreadyFriend = _friends.any((f) {
                        try {
                          return f['profiles']['id'] == user.id;
                        } catch (e) {
                          return false;
                        }
                      });
                      
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const CircleAvatar(backgroundColor: AppTheme.primaryColor, child: Icon(Icons.person, color: Colors.white, size: 20)),
                        title: Text(user.nickname ?? 'Anonymous', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('ID: ${user.id.substring(0, 8)}...', style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3))),
                        trailing: isAlreadyFriend 
                          ? const Text('Friend', style: TextStyle(color: Colors.green, fontSize: 12))
                          : ElevatedButton(
                              onPressed: () async {
                                await _dbService.addFriend(_authService.currentUser!.id, user.id);
                                if (context.mounted) {
                                  Navigator.pop(context);
                                  _loadFriends();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Added ${user.nickname} as friend!')),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                visualDensity: VisualDensity.compact,
                                backgroundColor: AppTheme.primaryColor,
                              ),
                              child: const Text('Add', style: TextStyle(color: Colors.white, fontSize: 12)),
                            ),
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
}

class ChatScreen extends StatefulWidget {
  final String friendId;
  final String friendNickname;

  const ChatScreen({super.key, required this.friendId, required this.friendNickname});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final _dbService = DatabaseService();
  final _authService = AuthService();
  late Stream<List<Message>> _chatStream;

  @override
  void initState() {
    super.initState();
    _chatStream = _dbService.getChatStream(_authService.currentUser!.id, widget.friendId);
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.friendNickname)),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Message>>(
              stream: _chatStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
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
                    final message = messages[index]; // Use directly as newest is index 0
                    final isMe = message.senderId == _authService.currentUser!.id;
                    
                    if (isMe) {
                      return FadeInRight(
                        duration: const Duration(milliseconds: 300),
                        child: _buildMessageBubble(message, isMe),
                      );
                    } else {
                      return FadeInLeft(
                        duration: const Duration(milliseconds: 300),
                        child: _buildMessageBubble(message, isMe),
                      );
                    }
                  },
                );
              },
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
                _messageController.clear(); // Clear immediately for better UX
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
