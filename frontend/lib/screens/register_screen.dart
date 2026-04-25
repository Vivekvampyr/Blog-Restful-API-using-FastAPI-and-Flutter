import 'package:flutter/material.dart';
import '../services/api_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _api = ApiService();
  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  String _selectedRole = 'reader';
  bool _loading = false;
  String? _error;

  Future<void> _register() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final success = await _api.register(
      username: _usernameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      firstName: _firstNameCtrl.text.trim(),
      lastName: _lastNameCtrl.text.trim(),
      password: _passwordCtrl.text.trim(),
      role: _selectedRole,
    );
    setState(() => _loading = false);
    if (success && mounted) {
      Navigator.pop(context); // go back to login
    } else {
      setState(() => _error = 'Registration failed. Try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _usernameCtrl,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _emailCtrl,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _firstNameCtrl,
              decoration: const InputDecoration(labelText: 'First Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _lastNameCtrl,
              decoration: const InputDecoration(labelText: 'Last Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedRole,
              items: const [
                DropdownMenuItem(value: 'reader', child: Text('Reader')),
                DropdownMenuItem(value: 'writer', child: Text('Writer')),
              ],
              onChanged: (v) => setState(() => _selectedRole = v!),
              decoration: const InputDecoration(labelText: 'Role'),
            ),
            const SizedBox(height: 20),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 8),
            _loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                  onPressed: _register,
                  child: const Text('Register'),
                ),
          ],
        ),
      ),
    );
  }
}
