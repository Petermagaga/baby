import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  User? user;
  bool _isChatOpen = false;
  bool _isEmergencyOpen = false;

  late AnimationController _controller;
  late Animation<double> _wiggleAnimation;

  final TextEditingController _chatController = TextEditingController();
  List<Map<String, String>> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchUserData();

    // Animation controller for wiggling effect
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);

    _wiggleAnimation = Tween<double>(begin: -10, end: 10).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _chatController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserData() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      await Future.delayed(const Duration(seconds: 1));
      setState(() {
        user = currentUser;
      });
    }
  }

  Future<void> _sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    setState(() {
      _messages.add({"user": message});
      _isLoading = true;
    });

    _chatController.clear();

    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("accessToken");

      if (token == null) {
        setState(() {
          _messages.add({"bot": "❌ Authentication required! Please log in."});
        });
        return;
      }

      final response = await http.post(
        Uri.parse("http://127.0.0.1:8000/api/chatbot/ask/"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"message": message}),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final botReply = data["response"] ?? "🤖 Sorry, I didn't understand.";

        setState(() {
          _messages.add({"bot": botReply});
        });
      } else {
        setState(() {
          _messages.add({"bot": "❌ Error: Unable to get a response."});
        });
      }
    } catch (e) {
      setState(() {
        _messages.add({"bot": "⚠️ Network error. Please check your internet connection."});
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _callEmergency() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: '911');
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Unable to make a call")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String userName = user?.displayName ?? "User";
    userName = userName[0].toUpperCase() + userName.substring(1);

    return Scaffold(
      backgroundColor: const Color(0xFFF5EDE1),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.wb_sunny, color: Colors.orange, size: 28),
            const SizedBox(width: 10),
            Text(
              "Hello, $userName! 👋",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle, color: Colors.black87, size: 30),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              final token = prefs.getString("accessToken");

              if (token == null) {
                Navigator.pushNamed(context, "/login");
              } else {
                Navigator.pushNamed(context, "/profile");
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: const [
                FeatureCard(icon: Icons.help_outline, label: "FAQ", route: "/faq", color: Colors.blueAccent),
                FeatureCard(icon: Icons.pregnant_woman, label: "Pregnancy Tracker", route: "/pregnancy-tracker", color: Colors.pinkAccent),
                FeatureCard(icon: Icons.baby_changing_station, label: "Baby Tracker", route: "/baby-tracker", color: Colors.teal),
                FeatureCard(icon: Icons.health_and_safety, label: "Health Insights", route: "/health-insights", color: Colors.green),
                FeatureCard(icon: Icons.chat, label: "Find a Friend", route: "/community", color: Colors.orange),
                FeatureCard(icon: Icons.vaccines, label: "Immunization", route: "/immunization", color: Colors.redAccent),
              ],
            ),
          ),

          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              backgroundColor: Colors.blueAccent,
              onPressed: () {
                setState(() {
                  _isChatOpen = !_isChatOpen;
                });
              },
              child: Icon(_isChatOpen ? Icons.close : Icons.chat),
            ),
          ),

          AnimatedBuilder(
            animation: _wiggleAnimation,
            builder: (context, child) {
              return Positioned(
                right: 10 + _wiggleAnimation.value,
                top: MediaQuery.of(context).size.height / 2 - 30,
                child: FloatingActionButton(
                  backgroundColor: const Color.fromARGB(255, 176, 193, 20),
                  onPressed: () {
                    setState(() {
                      _isEmergencyOpen = !_isEmergencyOpen;
                    });
                  },
                  child: const Icon(Icons.safety_check, size: 24),
                ),
              );
            },
          ),

          if (_isEmergencyOpen)
            Positioned(
              bottom: 140,
              right: 20,
              child: FloatingActionButton(
                backgroundColor: const Color.fromARGB(255, 221, 51, 212),
                onPressed: () {
                  Navigator.pushNamed(context, "/emergency");
                },
                child: const Icon(Icons.phone),
              ),
            ),
        ],
      ),
    );
  }
}

class FeatureCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String route;
  final Color color;

  const FeatureCard({super.key, required this.icon, required this.label, required this.route, required this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Container(
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Icon(icon, color: Colors.white, size: 30), Text(label, style: const TextStyle(color: Colors.white))],
        ),
      ),
    );
  }
}
