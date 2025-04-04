import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FindFriendScreen extends StatefulWidget {
  @override
  _FindFriendScreenState createState() => _FindFriendScreenState();
}

class _FindFriendScreenState extends State<FindFriendScreen> {
  List<dynamic> matchedUsers = [];
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchMatchedUsers();
  }

  Future<void> _fetchMatchedUsers() async {
    final String apiUrl = "http://127.0.0.1:8000/api/match_users/";
    final String token = "your-jwt-token"; // Replace with actual token retrieval

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          matchedUsers = json.decode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          hasError = true;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Find a Friend",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        backgroundColor: Colors.pinkAccent,
        centerTitle: true,
        elevation: 5,
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.pinkAccent)),
            )
          : hasError
              ? Center(
                  child: Text(
                    "Error fetching data. Please try again!",
                    style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.red),
                  ),
                )
              : matchedUsers.isEmpty
                  ? Center(
                      child: Text(
                        "No friends found nearby!",
                        style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.pink.shade800),
                      ),
                    )
                  : ListView.builder(
                      itemCount: matchedUsers.length,
                      itemBuilder: (context, index) {
                        final user = matchedUsers[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.pinkAccent,
                            child: Text(user["username"][0].toUpperCase(), style: TextStyle(color: Colors.white)),
                          ),
                          title: Text(user["username"], style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                          subtitle: Text("Distance: ${user['distance_km']} km"),
                          trailing: Icon(Icons.message, color: Colors.pinkAccent),
                          onTap: () {
                            // Navigate to chat or profile screen
                          },
                        );
                      },
                    ),
    );
  }
}
