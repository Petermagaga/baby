import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  final String groupTitle;

  ChatScreen({required this.groupTitle}); // Constructor to receive groupTitle
  
  @override
  Widget build(BuildContext context) {
    // You don't need to get groupTitle from ModalRoute anymore because it's already passed
    return Scaffold(
      appBar: AppBar(title: Text(groupTitle)), // Use the passed groupTitle
      body: Column(
        children: [
          Expanded(child: Center(child: Text("Chat messages will appear here."))),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Type a message...",
                suffixIcon: Icon(Icons.send),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
