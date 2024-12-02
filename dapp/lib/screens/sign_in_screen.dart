import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../services/auth_service.dart';
import '../main_page.dart'; // Import MainPage for redirection

class SignInScreen extends StatefulWidget {
  final VoidCallback onSwitchToSignUp;

  const SignInScreen({super.key, required this.onSwitchToSignUp});

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final OAuthService _oauthService = OAuthService();

  Future<void> _signIn() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill all fields.')));
      return;
    }

    final user = await _dbHelper.getUserByEmail(email);
    if (user != null && user['password'] == password) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Login successful.')));

      // Redirect to MainPage after successful login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainPage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid email or password.')));
    }
  }

  Future<void> _googleLogin() async {
    final token = await _oauthService.authenticate();
    if (token != null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Google Login successful.')));

      // Redirect to MainPage after Google login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainPage()),
      );
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Google Login failed.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign In')),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password'),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                    onPressed: _signIn, child: const Text('Sign In')),
                const SizedBox(height: 16),
                const Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text('OR'),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _googleLogin,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('Login with Google'),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: widget.onSwitchToSignUp,
                  child: const Text('Don’t have an account? Sign Up'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
