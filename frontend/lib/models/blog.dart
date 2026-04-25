class Blog {
  final int id;
  final String title;
  final String content;
  final String tags;
  final int likes;
  final int comments;
  final String ownerName;

  Blog({
    required this.id,
    required this.title,
    required this.content,
    required this.tags,
    required this.likes,
    required this.comments,
    required this.ownerName,
  });

  factory Blog.fromJson(Map<String, dynamic> json) => Blog(
    id: json['id'],
    title: json['title'],
    content: json['content'],
    tags: json['tags'] ?? '',
    likes: json['likes'] ?? 0,
    comments: json['comments'] ?? 0,
    ownerName: json['owner_name'] ?? 'Unknown',
  );
}
