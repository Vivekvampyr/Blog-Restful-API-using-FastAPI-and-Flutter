import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/blog.dart';
import '../widgets/blog_card.dart'; // ← added
import 'blog_detail_screen.dart';
import 'create_blog_screen.dart';
import 'login_screen.dart';

class BlogListScreen extends StatefulWidget {
  const BlogListScreen({super.key});

  @override
  State<BlogListScreen> createState() => _BlogListScreenState();
}

class _BlogListScreenState extends State<BlogListScreen> {
  final _api = ApiService();
  late Future<List<Blog>> _blogs;

  @override
  void initState() {
    super.initState();
    _loadBlogs();
  }

  void _loadBlogs() {
    _blogs = _api.getBlogs().then(
      (list) => list.map((e) => Blog.fromJson(e)).toList(),
    );
  }

  Future<void> _logout() async {
    await _api.clearToken();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blogs'),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateBlogScreen()),
          );
          setState(() => _loadBlogs());
        },
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<Blog>>(
        future: _blogs,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final blogs = snapshot.data!;
          if (blogs.isEmpty) return const Center(child: Text('No blogs yet.'));

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: blogs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final blog = blogs[index];
              // ↓ replaced Card+ListTile with BlogCard
              return BlogCard(
                blog: blog,
                onTap:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BlogDetailScreen(blog: blog),
                      ),
                    ),
              );
            },
          );
        },
      ),
    );
  }
}
