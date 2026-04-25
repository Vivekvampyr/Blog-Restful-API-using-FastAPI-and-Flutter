import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/blog.dart';
import '../models/comment.dart';
import '../widgets/comment_tile.dart'; // ← added

class BlogDetailScreen extends StatefulWidget {
  final Blog blog;
  const BlogDetailScreen({super.key, required this.blog});

  @override
  State<BlogDetailScreen> createState() => _BlogDetailScreenState();
}

class _BlogDetailScreenState extends State<BlogDetailScreen> {
  final _api = ApiService();
  final _commentCtrl = TextEditingController();
  late Future<List<Comment>> _comments;
  bool _likeLoading = false;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  void _loadComments() {
    _comments = _api
        .getComments(widget.blog.id)
        .then((list) => list.map((e) => Comment.fromJson(e)).toList());
  }

  Future<void> _submitComment() async {
    final text = _commentCtrl.text.trim();
    if (text.isEmpty) return;
    await _api.addComment(widget.blog.id, text);
    _commentCtrl.clear();
    setState(() => _loadComments());
  }

  Future<void> _toggleLike() async {
    setState(() => _likeLoading = true);
    await _api.addLike(widget.blog.id);
    setState(() => _likeLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.blog.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Blog Meta
            Text(
              'By ${widget.blog.ownerName}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 4),
            Text(
              '🏷️ ${widget.blog.tags}',
              style: TextStyle(color: Colors.blue[400]),
            ),
            const Divider(height: 24),

            // Blog Content
            Text(widget.blog.content, style: const TextStyle(fontSize: 16)),
            const Divider(height: 32),

            // Like Button
            Row(
              children: [
                _likeLoading
                    ? const CircularProgressIndicator()
                    : IconButton(
                      icon: const Icon(
                        Icons.favorite_border,
                        color: Colors.red,
                      ),
                      onPressed: _toggleLike,
                    ),
                Text('${widget.blog.likes} likes'),
              ],
            ),
            const Divider(height: 24),

            // Comments heading
            const Text(
              'Comments',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // ↓ replaced ListTile with CommentTile
            FutureBuilder<List<Comment>>(
              future: _comments,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                final comments = snapshot.data!;
                if (comments.isEmpty) {
                  return const Text('No comments yet.');
                }

                return Column(
                  children:
                      comments
                          .map((c) => CommentTile(comment: c)) // ← changed
                          .toList(),
                );
              },
            ),

            const SizedBox(height: 16),

            // Add Comment
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Write a comment...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _submitComment,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
