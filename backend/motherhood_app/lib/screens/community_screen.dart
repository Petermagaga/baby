import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  Future<List<MatchedUser>> getMatchedUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access'); // Assuming 'access' is the key you used to store JWT

    if (token == null) {
      print("No token found in SharedPreferences.");
      return [];
    }

    final url = Uri.parse('https://127.0.0.1:8000/api/users/match-users/'); // Replace with your real URL

    final res = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((json) => MatchedUser.fromJson(json)).toList();
    } else {
      print("Error: ${res.statusCode}");
      return [];
    }
  }
}


class CommunityScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Community",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        backgroundColor: Colors.pinkAccent,
        centerTitle: true,
        elevation: 5,
      ),
      body: AnimatedContainer(
        duration: Duration(milliseconds: 600),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.pink.shade200, Colors.pink.shade50],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle("Find a Friend"),
              SizedBox(height: 10),
              _animatedButton(
                text: "Find a Friend Near Me",
                onTap: () => _showMatchedUsers(context),
              ),
              SizedBox(height: 30),
              _sectionTitle("Join a Discussion"),
              SizedBox(height: 10),
              Expanded(
                child: ListView(
                  children: [
                    DiscussionGroupTile(title: "First-Time Mothers"),
                    DiscussionGroupTile(title: "High-Risk Pregnancy Support"),
                    DiscussionGroupTile(title: "Healthy Pregnancy Tips"),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// **Reusable Section Title**
  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.pink.shade900,
      ),
    );
  }

  /// **Animated Pink Button**
  Widget _animatedButton({required String text, required VoidCallback onTap}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.8, end: 1.0),
      duration: Duration(milliseconds: 500),
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pinkAccent,
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              elevation: 5,
            ),
            child: Text(
              text,
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
            ),
          ),
        );
      },
    );
  }
}

/// **Animated Discussion Group Tile**
class DiscussionGroupTile extends StatelessWidget {
  final String title;
  DiscussionGroupTile({required this.title});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.8, end: 1.0),
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: Card(
            color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 6,
            shadowColor: Colors.pinkAccent.withOpacity(0.3),
            margin: EdgeInsets.symmetric(vertical: 10),
            child: ListTile(
              title: Text(
                title,
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.pink.shade900),
              ),
              trailing: Icon(Icons.arrow_forward_ios, color: Colors.pinkAccent),
              onTap: () {
                Navigator.pushNamed(context, "/chat", arguments: title);
              },
            ),
          ),
        );
      },
    );
  }
}
class MatchedUser {
  final int id;
  final String username;
  final double distanceKm;
  final List<String> commonInterests;

  MatchedUser({required this.id, required this.username, required this.distanceKm, required this.commonInterests});

  factory MatchedUser.fromJson(Map<String, dynamic> json) {
    return MatchedUser(
      id: json['id'],
      username: json['username'],
      distanceKm: json['distance_km'].toDouble(),
      commonInterests: List<String>.from(json['common_interests']),
    );
  }
}
void _showMatchedUsers(BuildContext context) async {
  final response = await AuthService().getMatchedUsers(); // Defined next
  if (response != null && response.isNotEmpty) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) {
        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: response.length,
          itemBuilder: (context, index) {
            final user = response[index];
            return Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              margin: EdgeInsets.symmetric(vertical: 8),
              elevation: 4,
              child: ListTile(
                leading: Icon(Icons.person, color: Colors.pink),
                title: Text(user.username, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                subtitle: Text(
                  'Distance: ${user.distanceKm} km\nShared interests: ${user.commonInterests.join(", ")}',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            );
          },
        );
      },
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("No nearby friends found.")));
  }
}
