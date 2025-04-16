import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:motherhood_app/screens/community_screen.dart' show CommunityScreen;
// Import your AuthService and MatchedUser model
import 'package:motherhood_app/services/auth_service.dart' as service;
import 'package:motherhood_app/models/matched_user.dart' as models;

class FindFriendScreen extends StatefulWidget {
  @override
  _FindFriendScreenState createState() => _FindFriendScreenState();
}

class _FindFriendScreenState extends State<FindFriendScreen> {
  List<models.MatchedUser> matchedUsers = [];
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchMatchedUsers();
  }

  Future<void> _fetchMatchedUsers() async {
    try {
      final users = await service.AuthService().getMatchedUsers();

      
      
      print("Fetched users: ${users.length}");
      
      setState(() {
        matchedUsers = users;

        // ✅ Add a fallback user if list is empty (only for development)
        if (matchedUsers.isEmpty) {
          matchedUsers = [
           models. MatchedUser(
              id: 999,
              username: "TestFriend",
              email: "test@mock.com",
              location: "Test City",
              distanceKm: 0.5,
            ),
          ];
        }

        isLoading = false;
      });
    } catch (e) {
      print("Error fetching users: $e");
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
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.pinkAccent),
              ),
            )
          : hasError
              ? Center(
                  child: Text(
                    "Error fetching data. Please try again!",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.red,
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: matchedUsers.length,
                  itemBuilder: (context, index) {
                    final user = matchedUsers[index];
                    return Card(
                      elevation: 3,
                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.pinkAccent,
                          child: Text(
                            user.username[0].toUpperCase(),
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(
                          user.username,
                          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text("Distance: ${user.distanceKm} km"),
                        trailing: Icon(Icons.message, color: Colors.pinkAccent),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatScreen(user: user),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CommunityScreen(),
                ),
              );
            },
            child: Text(
              "Go to Community Screen",
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.pinkAccent),
          ),
        ),
      ),
    );
  }
}

class ChatScreen extends StatelessWidget {
  final models.MatchedUser user;

  ChatScreen({required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chat with ${user.username}"),
        backgroundColor: Colors.pinkAccent,
        centerTitle: true,
      ),
      body: Center(
        child: Text(
          "Chatting with ${user.username}",
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
