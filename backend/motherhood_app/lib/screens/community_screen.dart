import 'package:flutter/material.dart';

class CommunityScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Community")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Find a Friend", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, "/find_friend");
              },
              child: Text("Find a Friend Near Me"),
            ),

            SizedBox(height: 20),

            Text("Join a Discussion", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
    );
  }
}

class DiscussionGroupTile extends StatelessWidget {
  final String title;

  DiscussionGroupTile({required this.title});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        trailing: Icon(Icons.arrow_forward),
        onTap: () {
          Navigator.pushNamed(context, "/chat", arguments: title);
        },
      ),
    );
  }
}
