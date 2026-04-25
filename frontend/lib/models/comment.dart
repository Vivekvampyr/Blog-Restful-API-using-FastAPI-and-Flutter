class Comment {
  final int id;
  final String content;
  final int userId;
  final String ownerName;

  Comment({
    required this.id,
    required this.content,
    required this.userId,
    required this.ownerName,
  });

  factory Comment.fromJson(Map<String, dynamic> json) => Comment(
    id: json['id'],
    content: json['content'],
    userId: json['user_id'],
    ownerName: json['owner_name'] ?? 'Unknown',
  );
}
