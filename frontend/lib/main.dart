import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'services/api_service.dart';
import 'screens/blog_list_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Blog App',
      debugShowCheckedModeBanner: false,
      darkTheme: ThemeData.dark(),
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.grey[100],
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.grey),
      ),
      home: const AuthGate(),
    );
  }
}

// Checks if token exists → skip login if already logged in
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final _api = ApiService();
  late Future<Widget> _startScreen;

  @override
  void initState() {
    super.initState();
    _startScreen = _api.getToken().then(
      (token) => token != null ? const BlogListScreen() : const LoginScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _startScreen,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return snapshot.data!;
      },
    );
  }
}
