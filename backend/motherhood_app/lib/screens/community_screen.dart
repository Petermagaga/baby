import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
                onTap: () => Navigator.pushNamed(context, "/find_friend"),
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
