import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/blog.dart';
import '../widgets/blog_card.dart';
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
  final _searchCtrl = TextEditingController();
  late Future<List<Blog>> _blogs;
  bool _isSearching = false;

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

  void _searchBlogs(String tag) {
    if (tag.trim().isEmpty) {
      // if search is cleared, go back to all blogs
      setState(() {
        _isSearching = false;
        _loadBlogs();
      });
      return;
    }
    setState(() {
      _isSearching = true;
      _blogs = _api
          .searchBlogs(tag.trim())
          .then((list) => list.map((e) => Blog.fromJson(e)).toList());
    });
  }

  void _clearSearch() {
    _searchCtrl.clear();
    setState(() {
      _isSearching = false;
      _loadBlogs();
    });
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
      body: Column(
        children: [
          // ─── Search Bar ───────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: TextField(
              controller: _searchCtrl,
              onSubmitted: _searchBlogs, // search on keyboard "done"
              decoration: InputDecoration(
                hintText: 'Search by tag...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon:
                    _isSearching
                        ? IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: _clearSearch, // ← clears and reloads all
                        )
                        : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),

          // ─── Blog List ────────────────────────────────────
          Expanded(
            child: FutureBuilder<List<Blog>>(
              future: _blogs,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final blogs = snapshot.data!;
                if (blogs.isEmpty) {
                  return Center(
                    child: Text(
                      _isSearching
                          ? 'No blogs found for "${_searchCtrl.text}"'
                          : 'No blogs yet.',
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: blogs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final blog = blogs[index];
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
          ),
        ],
      ),
    );
  }
}
