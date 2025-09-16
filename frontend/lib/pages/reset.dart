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
      appBar: AppBar(
        title: const Text('Reset Password'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: _email,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _newPass,
              decoration: const InputDecoration(labelText: "New Password"),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _confirm,
              decoration: const InputDecoration(
                labelText: "Confirm New Password",
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: reset,
              child: const Text("Reset Password"),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Center(child: Text("Back to Login")),
            ),
          ],
        ),
      ),
    );
  }
}
