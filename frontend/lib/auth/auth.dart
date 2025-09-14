import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
class Auth {
  final SupabaseClient _supabase = Supabase.instance.client;
  String? get userID => _supabase.auth.currentUser?.id;
  Future<AuthResponse> signIn(String email, String password) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<AuthResponse> signUp(String email, String password) async {
    return await _supabase.auth.signUp(email: email, password: password);
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    await _supabase.auth.resetPasswordForEmail(
      email,
      redirectTo: 'http://localhost:3000/reset-password',
    );
  }

  String? getEmail() {
    return _supabase.auth.currentUser?.email;
  }

  Future<bool> isEmailVerified() async {
    final user = _supabase.auth.currentUser;
    return user?.emailConfirmedAt != null;
  }

  User? getCurrentUser() {
    return _supabase.auth.currentUser;
  }
}