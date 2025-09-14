import 'package:cooking_app/auth/auth.dart';
import 'package:cooking_app/pages/login.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';

class Reset extends StatefulWidget {
  const Reset({super.key});
  @override
  State<Reset> createState() => _ResetState();
}

class _ResetState extends State<Reset> {
  final auth = Auth();
  final _email = TextEditingController();
  final _newPass = TextEditingController();
  final _confirm = TextEditingController();
  void reset() async {
    final email = _email.text.trim();
    // In current flow, new password and confirmation are captured but not used.
    // Validation and backend update to be implemented later.
    try {
      await auth.resetPassword(email);
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          TextField(
            controller: _email,
            decoration: const InputDecoration(labelText: 'Username'),
          ),
          TextField(
            controller: _newPass,
            decoration: const InputDecoration(labelText: "New Password"),
          ),
          TextField(
            controller: _confirm,
            decoration: const InputDecoration(
              labelText: "Confirm New Password",
            ),
          ),
          ElevatedButton(
            onPressed: reset,
            child: const Text("Change Password"),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
            ),
            child: const Center(child: Text("Go Back")),
          ),
        ],
      ),
    );
  }
}
