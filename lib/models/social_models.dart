class Message {
  final String id;
  final String senderId;
  final String receiverId;
  final String content;
  final DateTime createdAt;
  final bool isRead;

  Message({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.createdAt,
    this.isRead = false,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      senderId: json['sender_id'],
      receiverId: json['receiver_id'],
      content: json['content'],
      createdAt: DateTime.parse(json['created_at']),
      isRead: json['is_read'] ?? false,
    );
  }
}

class Friend {
  final String id;
  final String nickname;
  final String status; // 'pending', 'accepted'

  Friend({required this.id, required this.nickname, required this.status});

  factory Friend.fromJson(Map<String, dynamic> json, String currentUserId) {
    // Determine the friend's ID and nickname based on who is who in the friendship table
    // This is a simplified version; real logic depends on query results
    return Friend(
      id: json['friend_id'],
      nickname: json['profiles']['nickname'],
      status: json['status'],
    );
  }
}
