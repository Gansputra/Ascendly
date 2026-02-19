class Journal {
  final String? id;
  final String userId;
  final String mood;
  final String? note;
  final DateTime createdAt;

  Journal({
    this.id,
    required this.userId,
    required this.mood,
    this.note,
    required this.createdAt,
  });

  factory Journal.fromJson(Map<String, dynamic> json) {
    return Journal(
      id: json['id'],
      userId: json['user_id'],
      mood: json['mood'],
      note: json['note'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'mood': mood,
      'note': note,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
