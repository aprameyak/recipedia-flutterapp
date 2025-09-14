import 'package:flutter/material.dart';
import 'package:cooking_app/widgets/main_scaffold_with_bottom_navbar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});
  
  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {

  @override
  void initState() {
    super.initState();
    sendDataToBackend({});
  }

  Future<void> sendDataToBackend(Map<String, dynamic> data) async {
    final accessToken = Supabase.instance.client.auth.currentSession?.accessToken;
    if (accessToken == null) return;

    final response1 = await http.get(
      Uri.parse('http://localhost:5000/users/profile/favorites'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );
    if (response1.statusCode == 200) {
      print("Favorites loaded successfully");
    } else {
      print("Failed: ${response1.statusCode}");
    }
    
    final response2 = await http.get(
      Uri.parse('http://localhost:5000/users/profile/comments'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );
    if (response2.statusCode == 200) {
      print("Comments loaded successfully");
    } else {
      print("Failed: ${response2.statusCode}");
    }

  }
  
  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Welcome to the Favorites Page'),
            const SizedBox(height: 20),
          ],
        ),
      ),
      currentIndex: 3,
    );
  }
}

