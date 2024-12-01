import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:okto_flutter_sdk/okto_flutter_sdk.dart';

final GoogleSignIn googleSignIn = GoogleSignIn(
  clientId:
      '324745364380-38jb5uabb5hp2vrs76a8nls4741dco40.apps.googleusercontent.com',
);

final storage = FlutterSecureStorage();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Okto with your API key
  final okto = Okto('6d3b308e-771c-47ef-be0e-f507321391d7', BuildType.sandbox);

  runApp(MyApp(okto: okto));
}

class MyApp extends StatelessWidget {
  final Okto okto;

  const MyApp({super.key, required this.okto});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DApp Login',
      theme: ThemeData(
        scaffoldBackgroundColor: Color(0xFF1E0738), // Purple background
        colorScheme: ColorScheme.dark(
          primary: Color(0xFF9C27B0), // Purple accent
          secondary: Color(0xFF673AB7), // Secondary purple
        ),
        textTheme: TextTheme(
          headlineLarge: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 28),
          bodyLarge: TextStyle(color: Colors.white70, fontSize: 16),
          bodyMedium: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF9C27B0), // Purple button
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50), // Rounded design
            ),
            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        useMaterial3: true,
      ),
      home: LoginPage(okto: okto),
    );
  }
}

class LoginPage extends StatefulWidget {
  final Okto okto;

  const LoginPage({super.key, required this.okto});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String? userName;
  String? userEmail;

  final GoogleSignIn googleSignIn = GoogleSignIn();

  // Sign-in with Google
  Future<void> signInWithGoogle() async {
    try {
      final googleUser = await googleSignIn.signIn();
      if (googleUser != null) {
        final googleAuth = await googleUser.authentication;
        if (googleAuth.idToken != null) {
          // Store ID Token securely using flutter_secure_storage
          await storage.write(
              key: 'google_id_token', value: googleAuth.idToken);

          // Authenticate with Okto
          await widget.okto.authenticate(idToken: googleAuth.idToken!);
          setState(() {
            userName = googleUser.displayName;
            userEmail = googleUser.email;
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login failed: $e")),
      );
    }
  }

  // Sign out from both Google and Okto
  Future<void> signOut() async {
    await googleSignIn.signOut();
    await storage.delete(key: 'google_id_token'); // Delete stored token
    setState(() {
      userName = null;
      userEmail = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Secure DApp Login",
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        centerTitle: true,
      ),
      body: Center(
        child: userName == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App Logo Placeholder
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Color(0xFF673AB7),
                    child: Icon(
                      Icons.security,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 40),
                  ElevatedButton.icon(
                    onPressed: signInWithGoogle,
                    icon: Icon(Icons.login, color: Colors.white),
                    label: Text("Sign in with Google"),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Access your secure DApp with ease!",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Welcome, $userName!",
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Email: $userEmail",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: signOut,
                    child: const Text("Sign Out"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
