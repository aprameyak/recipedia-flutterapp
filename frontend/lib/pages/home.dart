import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cooking_app/widgets/main_scaffold_with_bottom_navbar.dart';

//Do sendDataToBackend with map of changes (feed of ~20 recipes) when opening the home page
class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class HomeApp extends StatelessWidget {
  const HomeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: const Home());
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _Home();
}

class _Home extends State<Home> {
  final CarouselController controller = CarouselController(initialItem: 1);

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      currentIndex: 0,
      body: Container(
        color: const Color.fromARGB(255, 252, 251, 248),
        child: ListView(
          children: <Widget>[
            Padding(
              padding: EdgeInsetsDirectional.only(top: 35.0, start: 50.0),
              child: Text(
                "Good ${"[time period]"}, Chef ${"[user]!"}",
                style: GoogleFonts.inter(
                  fontSize: 50,
                  decoration: TextDecoration.none,
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsetsDirectional.only(top: 15.0, start: 50.0),
              child: Text(
                'What would you like to cook today?',
                style: GoogleFonts.inter(
                  fontSize: 30,
                  color: Color.fromARGB(255, 108, 107, 107),
                  decoration: TextDecoration.none,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsetsDirectional.only(top: 55.0, start: 50.0),
              child: Text(
                'Browse by Category',
                style: GoogleFonts.inter(
                  fontSize: 30,
                  color: Colors.black,
                  decoration: TextDecoration.none,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsetsDirectional.only(
                top: 30,
                start: 50.0,
                end: 50.0,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 140),
                child: CarouselView.weighted(
                  flexWeights: const <int>[2, 2, 2, 2, 2, 2],
                  consumeMaxWeight: false,
                  children: CategoryInfo.values.map((CategoryInfo info) {
                    return Container(
                      margin: EdgeInsets.all(5),
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: switch (info.label) {
                            'Breakfast' => Color(0xFFC62828),
                            'Lunch' => Color(0xFFAD1457),
                            'Dinner' => Color(0xFF6A1B9A),
                            'Desserts' => Color(0xFF4527A0),
                            'Proteins' => Color(0xFF283593),
                            'Carbs' => Color(0xFF1565C0),
                            'Vegetarian' => Color(0xFF0277BD),
                            'Drinks' => Color(0xFF00838F),
                            'Healthy' => Color(0xFF00695C),
                            'Keto' => Color(0xFF2E7D32),
                            'Recent' => Color(0xFF558B2F),
                            'Calorie Friendly' => Color(0xFF9E9D24),
                            'Fine Dining' => Color(0xFFF57F17),
                            'Cheap & Fast' => Color(0xFFEF6C00),
                            'Random' => Color(0xFFD84315),
                            _ => Color(0x00000000),
                          },
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              decoration: BoxDecoration(
                                color: switch (info.label) {
                                  'Breakfast' => Color(0xFFFFCDD2),
                                  'Lunch' => Color(0xFFF8BBD9),
                                  'Dinner' => Color(0xFFE1BEE7),
                                  'Desserts' => Color(0xFFD1C4E9),
                                  'Proteins' => Color(0xFFC5CAE9),
                                  'Carbs' => Color(0xFFBBDEFB),
                                  'Vegetarian' => Color(0xFFB3E5FC),
                                  'Drinks' => Color(0xFFB2EBF2),
                                  'Healthy' => Color(0xFFB2DFDB),
                                  'Keto' => Color(0xFFC8E6C9),
                                  'Recent' => Color(0xFFDCEDC8),
                                  'Calorie Friendly' => Color(0xFFF0F4C3),
                                  'Fine Dining' => Color(0xFFFFF9C4),
                                  'Cheap & Fast' => Color(0xFFFFE0B2),
                                  'Random' => Color(0xFFFFCCBC),
                                  _ => Color(0xFF808080),
                                },
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                info.recipeCount,
                                style: TextStyle(
                                  color: switch (info.label) {
                                    'Breakfast' => Color(0xFFC62828),
                                    'Lunch' => Color(0xFFAD1457),
                                    'Dinner' => Color(0xFF6A1B9A),
                                    'Desserts' => Color(0xFF4527A0),
                                    'Proteins' => Color(0xFF283593),
                                    'Carbs' => Color(0xFF1565C0),
                                    'Vegetarian' => Color(0xFF0277BD),
                                    'Drinks' => Color(0xFF00838F),
                                    'Healthy' => Color(0xFF00695C),
                                    'Keto' => Color(0xFF2E7D32),
                                    'Recent' => Color(0xFF558B2F),
                                    'Calorie Friendly' => Color(0xFF9E9D24),
                                    'Fine Dining' => Color(0xFFF57F17),
                                    'Cheap & Fast' => Color(0xFFEF6C00),
                                    'Random' => Color(0xFFD84315),
                                    _ => Color(0x00000000),
                                  },
                                ),
                                overflow: TextOverflow.clip,
                                softWrap: false,
                              ),
                            ),
                            Text(
                              info.label,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.clip,
                              softWrap: false,
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsetsDirectional.only(top: 75.0, start: 50.0),
              child: Text(
                'Recipes For You',
                style: GoogleFonts.inter(
                  fontSize: 30,
                  color: Colors.black,
                  decoration: TextDecoration.none,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsetsDirectional.only(
                top: 20.0,
                start: 50.0,
                end: 50.0,
              ),
              child: Text("hi"),
            ),
          ],
        ),
      ),
    );
  }
}

enum CategoryInfo {
  breakfast('Breakfast', '245 recipes'),
  lunch('Lunch', '245 recipes'),
  dinner('Dinner', '245 recipes'),
  desserts('Desserts', '245 recipes'),
  proteins('Proteins', '245 recipes'),
  carbs('Carbs', '245 recipes'),
  vegetarian('Vegetarian', '245 recipes'),
  drinks('Drinks', '245 recipes'),
  healthy('Healthy', '245 recipes'),
  keto('Keto', '245 recipes'),
  recent('Recent', '245 recipes'),
  calorieFriendly('Calorie Friendly', '245 recipes'),
  fineDining('Fine Dining', '245 recipes'),
  cheapAndFast('Cheap & Fast', '245 recipes'),
  random('Random', '245 recipes');

  const CategoryInfo(this.label, this.recipeCount);
  final String label;
  final String recipeCount;
}

enum PostInfo {
  pasta(
    'Homemade Pasta with Fresh Herbs',
    'jonathan',
    'https://images.unsplash.com/photo-1617735605078-8a9336be0816?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxyZWNpcGUlMjBib29rJTIwZm9vZCUyMHByZXBhcmF0aW9ufGVufDF8fHx8MTc1NzgxOTY4MXww&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral',
    'Carbs',
    48,
    'idk',
  ),
  curry(
    'Spicy Thai Green Curry',
    'bobby',
    'https://images.unsplash.com/photo-1647846241734-7c2ab3db1d32?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxyZWNpcGUlMjBib29rJTIwZm9vZCUyMHByZXBhcmF0aW9ufGVufDF8fHx8MTc1NzgxOTY4MXww&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral',
    'Vegetarian',
    46,
    'idk',
  ),
  ratatouille(
    'Classic French Ratatouille',
    'remy',
    'https://images.unsplash.com/photo-1722639096482-4e1a805f9b0b?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxmb29kJTIwc2VhcmNoJTIwaW5ncmVkaWVudHN8ZW58MXx8fHwxNzU3ODE5NjgxfDA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral',
    'Fine Dining',
    49,
    'idk',
  );

  //These fields have to be final
  const PostInfo(
    this.title,
    this.profileId,
    this.imageUrl,
    this.category,
    this.likeCount,
    this.recipe,
  );
  final String title;
  final String profileId;
  final String imageUrl;
  final String category;
  final int likeCount;
  final String recipe;
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    sendDataToBackend({});
  }

  Future<void> sendDataToBackend(Map<String, dynamic> data) async {
    final accessToken =
        Supabase.instance.client.auth.currentSession?.accessToken;
    if (accessToken == null) return;

    final response = await http.get(
      Uri.parse('http://localhost:5000/users/profile/feed'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      debugPrint("Feed loaded successfully");
    } else {
      debugPrint("Failed: ${response.statusCode}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return HomeApp();
  }
}
