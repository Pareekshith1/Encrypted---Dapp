import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../services/auth_service.dart';

class SignUpScreen extends StatefulWidget {
  final VoidCallback onSwitchToSignIn;

  const SignUpScreen({super.key, required this.onSwitchToSignIn});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final OAuthService _oauthService = OAuthService();

  Future<void> _signup() async {
    final name = nameController.text.trim();
    final phone = phoneController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (name.isEmpty || phone.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill all fields.')));
      return;
    }

    try {
      await _dbHelper.insertUser({
        'name': name,
        'phone': phone,
        'email': email,
        'password': password,
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Signup successful.')));
      widget.onSwitchToSignIn();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: Email already exists.')));
    }
  }

  Future<void> _googleLogin() async {
    final token = await _oauthService.authenticate();
    if (token != null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Google Login successful.')));
      // Redirect to home or save user info from Google token.
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Google Login failed.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: 'Phone'),
                ),
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
                    onPressed: _signup, child: const Text('Sign Up')),
                const SizedBox(height: 16),
                const Row(children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text('OR'),
                  ),
                  Expanded(child: Divider()),
                ]),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _googleLogin,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('Login with Google'),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: widget.onSwitchToSignIn,
                  child: const Text('Already have an account? Log In'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
