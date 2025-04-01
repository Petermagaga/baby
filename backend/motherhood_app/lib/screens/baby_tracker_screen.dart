import 'package:flutter/material.dart';

class BabyTrackerScreen extends StatelessWidget {
  final String babyName = "Baby Noah";
  final String birthDate = "2024-02-10";
  final double babyWeight = 4.2; // In kg

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Baby Tracker")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Baby's Name: $babyName", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text("Date of Birth: $birthDate", style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            Text("Current Weight: $babyWeight kg", style: TextStyle(fontSize: 16)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, "/update_baby_weight");
              },
              child: Text("Update Baby Weight"),
            ),
          ],
        ),
      ),
    );
  }
}
