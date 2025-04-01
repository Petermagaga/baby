import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  User? user;
  bool _isChatOpen = false;
  final TextEditingController _chatController = TextEditingController();
  List<Map<String, String>> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
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
    if (message.trim().isEmpty) return; // Prevent sending empty messages

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
        Uri.parse("http://127.0.0.1:8000/api/chatbot/ask/"), // Replace with actual API URL
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
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
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
              children: [
                FeatureCard(icon: Icons.help_outline, label: "FAQ", route: "/faq", color: Colors.blueAccent),
                FeatureCard(icon: Icons.pregnant_woman, label: "Pregnancy Tracker", route: "/pregnancy-tracker", color: Colors.pinkAccent),
                FeatureCard(icon: Icons.baby_changing_station, label: "Baby Tracker", route: "/baby-tracker", color: Colors.teal),
                FeatureCard(icon: Icons.health_and_safety, label: "Health Insights", route: "/health-insights", color: Colors.green),
                FeatureCard(icon: Icons.chat, label: "Find a Friend", route: "/community", color: Colors.orange),
                FeatureCard(icon: Icons.vaccines, label: "Immunization", route: "/immunization", color: Colors.redAccent),
              ],
            ),
          ),

          if (_isChatOpen)
            Positioned(
              bottom: 80,
              right: 20,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: MediaQuery.of(context).size.width * 0.35,
                height: _messages.isEmpty ? 80 : 140,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    if (_messages.isNotEmpty)
                      Expanded(
                        child: ListView.builder(
                          itemCount: _messages.length,
                          itemBuilder: (context, index) {
                            final message = _messages[index];
                            final isUser = message.containsKey("user");

                            return Align(
                              alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                              child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: isUser ? Colors.blueAccent : Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  message.values.first,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isUser ? Colors.white : Colors.black87,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                    if (_isLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 4),
                        child: SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),

                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _chatController,
                            decoration: InputDecoration(
                              hintText: "Type...",
                              hintStyle: const TextStyle(fontSize: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              contentPadding: const EdgeInsets.all(6),
                            ),
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.send, color: Colors.blueAccent, size: 18),
                          onPressed: () {
                            if (_chatController.text.isNotEmpty) {
                              _sendMessage(_chatController.text);
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
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
        ],
      ),
    );
  }
}

// ✅ **Fixed: FeatureCard Widget**
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
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 30),
            const SizedBox(height: 8),
            Text(label, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
