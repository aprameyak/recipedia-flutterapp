import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';

class Setmain extends StatefulWidget {
  const Setmain({super.key});
  
  @override
  State<Setmain> createState() => _Setmain();
}

class _Setmain extends State<Setmain> {

  @override
  void initState() {
    super.initState();
    sendDataToBackend({});
  }

  Future<void> sendDataToBackend(Map<String, dynamic> data) async {
    final accessToken = Supabase.instance.client.auth.currentSession?.accessToken;
    if (accessToken == null) return;

    final response = await http.get(
      Uri.parse('http://localhost:5000/users/profile/settings'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      print("Settings loaded successfully");
    } else {
      print("Failed: ${response.statusCode}");
    }
  }

  //In the widget, when editing settings, use sendDataToBackend(map) to send changes to backend
  @override
  Widget build(BuildContext context) {
    return SettingsList(
      sections: [
        SettingsSection(
          title: Text("Hello World"),
          tiles: <SettingsTile>[
            SettingsTile.navigation(
              leading: Icon(Icons.language),
              title: Text('Language'),
              value: Text('English'),
            ),
            SettingsTile.navigation(
              leading: Icon(Icons.format_align_center),
              title: Text("Theme?"),
            ),
          ],
        ),
      ],
    );
  }
}