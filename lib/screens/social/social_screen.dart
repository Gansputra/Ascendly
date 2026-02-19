import 'package:ascendly/core/theme.dart';
import 'package:ascendly/models/social_models.dart';
import 'package:ascendly/services/auth_service.dart';
import 'package:ascendly/services/database_service.dart';
import 'package:ascendly/services/gamification_service.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class SocialScreen extends StatefulWidget {
  const SocialScreen({super.key});

  @override
  State<SocialScreen> createState() => _SocialScreenState();
}

class _SocialScreenState extends State<SocialScreen> {
  final _dbService = DatabaseService();
  final _authService = AuthService();
  List<Map<String, dynamic>> _friends = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFriends();
  }

  Future<void> _loadFriends() async {
    try {
      final friends = await _dbService.getFriends(_authService.currentUser!.id);
      if (mounted) {
        setState(() {
          _friends = friends;
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
          : _friends.isEmpty
              ? _buildEmptyState()
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _friends.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final friend = _friends[index];
                    return _buildFriendTile(friend);
                  },
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
    return InkWell(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => ChatScreen(friendId: friend['profiles']['id'], friendNickname: friend['profiles']['nickname']),
        ));
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
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
                const Center(child: Padding(padding: EdgeInsets.all(20), child: Text('No users found', style: TextStyle(color: Colors.white54))))
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
                        title: Text(user.nickname, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('ID: ${user.id.substring(0, 8)}...', style: const TextStyle(fontSize: 10, color: Colors.white24)),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.friendNickname)),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Message>>(
              stream: _dbService.getChatStream(_authService.currentUser!.id, widget.friendId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final messages = snapshot.data!;
                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[messages.length - 1 - index];
                    final isMe = message.senderId == _authService.currentUser!.id;
                    return _buildMessageBubble(message.content, isMe);
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

  Widget _buildMessageBubble(String content, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? AppTheme.primaryColor : AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(16).copyWith(
            bottomRight: isMe ? const Radius.circular(0) : const Radius.circular(16),
            bottomLeft: isMe ? const Radius.circular(16) : const Radius.circular(0),
          ),
        ),
        child: Text(content, style: const TextStyle(color: Colors.white)),
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
            onPressed: () {
              if (_messageController.text.isNotEmpty) {
                _dbService.sendMessage(
                  _authService.currentUser!.id,
                  widget.friendId,
                  _messageController.text,
                );
                GamificationService().completeQuest(_authService.currentUser!.id, 'social_chat', context: context);
                _messageController.clear();
              }
            },
          ),
        ],
      ),
    );
  }
}
