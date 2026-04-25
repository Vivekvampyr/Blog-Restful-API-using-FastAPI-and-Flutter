import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8000';
  // Use 10.0.2.2 for Android emulator
  // Use your PC's local IP (e.g. 192.168.1.5) for physical device

  final _storage = const FlutterSecureStorage();

  Future<String?> getToken() => _storage.read(key: 'token');
  Future<void> saveToken(String token) =>
      _storage.write(key: 'token', value: token);
  Future<void> clearToken() => _storage.delete(key: 'token');

  Future<Map<String, String>> _authHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ─── AUTH ────────────────────────────────────────────────
  Future<bool> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/token'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {'username': username, 'password': password},
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await saveToken(data['access_token']);
      return true;
    }
    return false;
  }

  Future<bool> register({
    required String username,
    required String email,
    required String firstName,
    required String lastName,
    required String password,
    required String role,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/user'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'email': email,
        'first_name': firstName,
        'last_name': lastName,
        'password': password,
        'role': role,
      }),
    );
    return response.statusCode == 204;
  }

  // ─── BLOGS ───────────────────────────────────────────────
  Future<List<dynamic>> getBlogs() async {
    final response = await http.get(Uri.parse('$baseUrl/blogs'));
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Failed to load blogs');
  }

  Future<bool> createBlog({
    required String title,
    required String content,
    required String tags,
  }) async {
    final headers = await _authHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/blogs'),
      headers: headers,
      body: jsonEncode({'title': title, 'content': content, 'tags': tags}),
    );
    return response.statusCode == 201;
  }

  Future<bool> deleteBlog(int blogId) async {
    final headers = await _authHeaders();
    final response = await http.delete(
      Uri.parse('$baseUrl/blog/$blogId'),
      headers: headers,
    );
    return response.statusCode == 200;
  }

  // ─── COMMENTS ────────────────────────────────────────────
  Future<List<dynamic>> getComments(int blogId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/blogs/$blogId/comments'),
    );
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Failed to load comments');
  }

  Future<bool> addComment(int blogId, String content) async {
    final headers = await _authHeaders();
    final response = await http.post(
      Uri.parse(
        '$baseUrl/blogs/$blogId/comments?content=${Uri.encodeComponent(content)}',
      ),
      headers: headers,
    );
    return response.statusCode == 200;
  }

  // ─── LIKES ───────────────────────────────────────────────
  Future<bool> addLike(int blogId) async {
    final headers = await _authHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/blogs/$blogId/likes'),
      headers: headers,
    );
    return response.statusCode == 200;
  }

  Future<bool> removeLike(int blogId) async {
    final headers = await _authHeaders();
    final response = await http.delete(
      Uri.parse('$baseUrl/blogs/$blogId/likes'),
      headers: headers,
    );
    return response.statusCode == 200;
  }

  Future<int> getLikes(int blogId) async {
    final response = await http.get(Uri.parse('$baseUrl/blogs/$blogId/likes'));
    if (response.statusCode == 200) return jsonDecode(response.body)['likes'];
    return 0;
  }
}
