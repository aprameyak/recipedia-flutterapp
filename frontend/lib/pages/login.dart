import 'package:cooking_app/auth/auth.dart';
import 'package:cooking_app/pages/reset.dart';
import 'package:flutter/material.dart';
import 'package:cooking_app/pages/reg.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

//App selects a random background from pexel upon opening the app
class _BackgroundRNG extends StatefulWidget {
  final Widget child;
  const _BackgroundRNG({required this.child});

  @override
  _BackgroundRNGState createState() => _BackgroundRNGState();
}

class _BackgroundRNGState extends State<_BackgroundRNG> {
  late Future<String> _imageUrlFuture;

  @override
  void initState() {
    super.initState();
    _imageUrlFuture = fetchRandomImageUrl('food');
    debugPrint("Background image url loaded");
  }

  Future<String> fetchRandomImageUrl(String query) async {
    final apiKey = dotenv.env['PEXELS_API'];
    final url = Uri.parse(
      'https://api.pexels.com/v1/search?query=$query&per_page=30',
    );
    final response = await http.get(url, headers: {'Authorization': apiKey!});

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final List photos = json['photos'];
      final randomPhoto = photos[Random().nextInt(photos.length)];
      debugPrint('Pexels response: ${response.statusCode}');
      return randomPhoto['src']['original'];
    } else {
      debugPrint('Pexels error: ${response.statusCode}');
      throw Exception('Failed to fetch image');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return FutureBuilder<String>(
      future: _imageUrlFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError || !snapshot.hasData) {
          return Container(color: Colors.white, child: widget.child);
        } else {
          final imageUrl = snapshot.data!;
          return Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(imageUrl),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withValues(alpha: 0.85),
                  BlendMode.darken,
                ),
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.4, 0.7, 1.0],
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.1),
                    Colors.black.withValues(alpha: 0.7),
                    Colors.black.withValues(alpha: 0.95),
                  ],
                ),
              ),
              child: Column(
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.26),
                  Text(
                    "Recipedia",
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 60,
                      color: Colors.white,
                      decoration: TextDecoration.none,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: screenWidth * 0.08,
                        right: screenWidth * 0.08,
                        top: screenWidth * 0.03,
                        bottom: screenWidth * 0.03,
                      ),
                      child: widget.child,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}

class _LoginPageState extends State<LoginPage> {
  final auth = Auth();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> login() async {
    final email = _email.text.trim();
    final password = _password.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await auth.signIn(email, password);
      if (!mounted) return;

      if (response.user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Login failed - please try again")),
        );
      }
    } catch (e) {
      if (!mounted) return;

      String message = "An error occurred";
      if (e.toString().contains('Invalid login credentials')) {
        message = "Incorrect email or password";
      } else if (e.toString().contains('Email not confirmed')) {
        message = "Please verify your email first";
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _BackgroundRNG(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: const Text('Login', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              TextField(
                controller: _email,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: Colors.white70),
                  hintText: 'Enter your email',
                  hintStyle: TextStyle(color: Colors.white54),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white54),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                enableSuggestions: false,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _password,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(color: Colors.white70),
                  hintText: 'Enter your password',
                  hintStyle: TextStyle(color: Colors.white54),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white54),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                obscureText: true,
                enableSuggestions: false,
                autocorrect: false,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : login,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        "Login",
                        style: TextStyle(color: Colors.black),
                      ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _isLoading
                    ? null
                    : () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const Reg()),
                      ),
                child: const Text(
                  "Don't have an account? Sign up",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Reset()),
                ),
                child: const Text(
                  "Forgot Password?",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
