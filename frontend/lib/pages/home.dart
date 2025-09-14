import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cooking_app/widgets/main_scaffold_with_bottom_navbar.dart';
import 'dart:convert';
import 'dart:math';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

//Do sendDataToBackend with map of changes (feed of ~20 recipes) when opening the home page
class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

//App's frosted glowing card on top of the random background
class ScrollableFrostedCard extends StatelessWidget {
  const ScrollableFrostedCard({super.key});

  Widget _buildCategoryItem(String title, String imageUrl, double screenWidth) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: screenWidth * 0.06,
          backgroundImage: NetworkImage(imageUrl),
          backgroundColor: Colors.black,
        ),
        SizedBox(height: screenWidth * 0.01),
        Text(
          title,
          style: GoogleFonts.lato(
            color: Colors.black,
            fontSize: screenWidth * 0.03,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenHeight = size.height;
    final screenWidth = size.width;
    debugPrint('Screen Width: ${size.width}, Screen Height: ${size.height}');

    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Glow layer behind the card
          Container(
            width: screenWidth * 0.95,
            height: screenHeight * 0.5,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.yellow.withValues(alpha: 0.3),
                  blurRadius: 60,
                  spreadRadius: 20,
                ),
              ],
            ),
          ),

          // Frosted glass scrollable card
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                width: double.infinity,
                constraints: BoxConstraints(maxHeight: screenHeight * 0.5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.04, 
                  vertical: screenHeight * 0.025, 
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Featured Recipes:",
                        style: GoogleFonts.truculenta(
                          fontSize: screenWidth * 0.06, 
                          color: Colors.blue,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Text(
                        "Explore by category or diet:",
                        style: GoogleFonts.truculenta(
                          fontSize: screenWidth * 0.05, 
                          color: Colors.blueGrey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: screenHeight * 0.02), 
                      Wrap(
                        spacing: screenWidth * 0.02,
                        runSpacing: screenHeight * 0.01,
                        alignment: WrapAlignment.center,
                        children: [
                          _buildCategoryItem("Desserts", 'https://zhangcatherine.com/wp-content/uploads/2022/09/dog-cake.jpg', screenWidth),
                          _buildCategoryItem("Proteins", 'https://static01.nyt.com/images/2024/05/16/multimedia/fs-tandoori-chicken-hmjq/fs-tandoori-chicken-hmjq-mediumSquareAt3X.jpg', screenWidth),
                          _buildCategoryItem("Drinks", 'https://static.vecteezy.com/system/resources/thumbnails/049/110/238/small_2x/close-up-of-colorful-refreshing-drinks-with-ice-cubes-and-bubbles-perfect-for-summer-and-party-themes-photo.jpeg', screenWidth),
                          _buildCategoryItem("Luxurious", 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSNt7pl88JtgGQ_9zUPouLb8Va_WOl4bkZJPg&s', screenWidth),
                          _buildCategoryItem("Carbs", 'https://assets.clevelandclinic.org/transform/40f5393d-e6d3-4968-90f2-cbd894b67779/wholeGrainProducts-842797430-770x533-1_jpg', screenWidth),
                          _buildCategoryItem("Cheap & Fast", 'https://static.vecteezy.com/system/resources/thumbnails/002/454/867/small_2x/chronometer-timer-counter-isolated-icon-free-vector.jpg', screenWidth),
                          _buildCategoryItem("Random Recipe", 'https://png.pngtree.com/png-vector/20190329/ourmid/pngtree-vector-shuffle-icon-png-image_889552.jpg', screenWidth),
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.03),
                      Divider(color: Colors.black, thickness: 2),
                      SizedBox(height: screenHeight * 0.02), 
                      Text(
                        "Your friends' dishes:",
                        style: GoogleFonts.truculenta(
                          fontSize: screenWidth * 0.05, 
                          color: Colors.blueGrey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: List.generate(
                          10,
                          (i) => Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 10,
                            ),
                            child: Text(
                              "Recipe ${i + 1}: [Insert name, content, and initial image posting of recipe here]",
                              style: GoogleFonts.lato(
                                fontSize: screenWidth * 0.04,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

//App selects a random background from unsplash upon opening the app
class _BackgroundRNG extends StatefulWidget {
  final List<Widget> children;
  const _BackgroundRNG({required this.children});

  @override
  _BackgroundRNGState createState() => _BackgroundRNGState();
}

class _BackgroundRNGState extends State<_BackgroundRNG> {
  late Future<String> _imageUrlFuture;

  @override
  void initState() {
    super.initState();
    //Loads the image url BEFORE the build()
    //Goes constructor, createState(), initState(), build()
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
          return Container(
            color: Colors.white,
            child: Column(children: widget.children),
          );
        } else {
          final imageUrl = snapshot.data!;
          return Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(imageUrl),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withValues(alpha: 0.3),
                  BlendMode.darken,
                ),
              ),
            ),
            padding: EdgeInsets.all(screenWidth * 0.08), 
            child: Column(
              children: widget.children,
            ),
          );
        }
      },
    );
  }
}

class _HomePageState extends State<HomePage> {
  User? get _currentUser => Supabase.instance.client.auth.currentUser;

  @override
  void initState() {
    super.initState();
    sendDataToBackend({});
  }

  Future<void> sendDataToBackend(Map<String, dynamic> data) async {
    final accessToken = Supabase.instance.client.auth.currentSession?.accessToken;
    if (accessToken == null) return;

    final response = await http.get(
      Uri.parse('http://localhost:5000/users/profile/feed'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      print("Feed loaded successfully");
    } else {
      print("Failed: ${response.statusCode}");
    }
  }


  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;
    final screenHeight = size.height;
    
    return MainScaffold(
      body: _BackgroundRNG(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Welcome, chef ',
                      style: TextStyle(
                        fontSize: screenWidth * 0.05, 
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                      ),
                    ),
                    TextSpan(
                      text: '${_currentUser?.email ?? "Guest"}!',
                      style: TextStyle(
                        fontSize: screenWidth * 0.05, 
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: screenHeight * 0.01), 
              Text(
                'Discover and post your favorite recipes!',
                style: TextStyle(fontSize: screenWidth * 0.035, color: Colors.amber),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          Expanded(
            child: ScrollableFrostedCard(),
          ),
        ],
      ),
      currentIndex: 0,
    );
  }
}
