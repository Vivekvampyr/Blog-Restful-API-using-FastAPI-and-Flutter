import 'package:flutter/material.dart';
import '../services/api_service.dart';

class CreateBlogScreen extends StatefulWidget {
  const CreateBlogScreen({super.key});

  @override
  State<CreateBlogScreen> createState() => _CreateBlogScreenState();
}

class _CreateBlogScreenState extends State<CreateBlogScreen> {
  final _api = ApiService();
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();
  final _tagsCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _submit() async {
    if (_titleCtrl.text.trim().isEmpty || _contentCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Title and content are required');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    final success = await _api.createBlog(
      title: _titleCtrl.text.trim(),
      content: _contentCtrl.text.trim(),
      tags: _tagsCtrl.text.trim(),
    );
    setState(() => _loading = false);
    if (success && mounted) {
      Navigator.pop(context);
    } else {
      setState(() => _error = 'Failed to create blog. Are you a writer?');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Blog')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _contentCtrl,
              maxLines: 6,
              decoration: const InputDecoration(
                labelText: 'Content',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _tagsCtrl,
              decoration: const InputDecoration(
                labelText: 'Tags (e.g. flutter, tech)',
              ),
            ),
            const SizedBox(height: 20),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 8),
            _loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                  onPressed: _submit,
                  child: const Text('Publish'),
                ),
          ],
        ),
      ),
    );
  }
}
