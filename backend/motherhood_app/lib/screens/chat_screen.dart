import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chat_message.dart'; // Adjust path as needed

class ChatScreen extends StatefulWidget {
  final String groupTitle;

  ChatScreen({required this.groupTitle});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  List<ChatMessage> _messages = [];
  String currentUsername = "";
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access');
    final username = prefs.getString('username') ?? "";

    if (token == null) return;

    final url = Uri.parse("http://127.0.0.1:8000/api/chatmessage/");

    final res = await http.get(url, headers: {
      'Authorization': 'Bearer $token',
    });

    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      setState(() {
        currentUsername = username;
        _messages = data
            .map((json) => ChatMessage.fromJson(json, username))
            .toList()
            .reversed
            .toList();
      });
    } else {
      print("Error loading messages: ${res.statusCode}");
    }
  }

  // Add the refreshToken function here
  Future<void> refreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString('refresh_token');
  
    if (refreshToken != null) {
      final url = Uri.parse("http://127.0.0.1:8000/api/refresh-token/");

      final res = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'refresh_token': refreshToken}),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final newAccessToken = data['access'];

        // Save the new access token to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('access', newAccessToken);

        print("Token refreshed successfully.");
      } else {
        print("Failed to refresh token.");
      }
    } else {
      print("No refresh token available.");
    }
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    setState(() => _isSending = true); // Start loading

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access');

    final url = Uri.parse("http://127.0.0.1:8000/api/chatmessage/");

    if (token == null) {
      print("Token missing. User needs to log in again.");
      return;
    }

    try {
      final res = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'group_title': widget.groupTitle,
          'message': text,
        }),
      );

      if (res.statusCode == 201) {
        _controller.clear();
        await _loadMessages();
      } else if (res.statusCode == 401) {
        print("Token expired. Trying to refresh...");
        await refreshToken(); // Refresh token here
        await _sendMessage(text); // Retry sending the message
      } else {
        print("Message send failed: ${res.statusCode} ${res.body}");
      }
    } catch (e) {
      print("Error sending message: $e");
    } finally {
      setState(() => _isSending = false); // Stop loading
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.groupTitle),
        backgroundColor: Colors.pinkAccent,
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? Center(child: Text("No messages yet."))
                : ListView.builder(
                    reverse: true,
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      return Align(
                        alignment: msg.isMine
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: EdgeInsets.symmetric(
                              vertical: 4, horizontal: 12),
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: msg.isMine
                                ? Colors.pinkAccent
                                : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: msg.isMine
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              Text(
                                msg.senderName,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: msg.isMine
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                msg.message,
                                style: TextStyle(
                                  color: msg.isMine
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                _formatTimestamp(msg.timestamp),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: msg.isMine
                                      ? Colors.white70
                                      : Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Divider(height: 1),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.pinkAccent,
                    shape: BoxShape.circle,
                  ),
                  child: _isSending
                      ? Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : IconButton(
                          icon: Icon(Icons.send, color: Colors.white),
                          onPressed: () =>
                              _sendMessage(_controller.text),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    if (now.difference(timestamp).inDays == 0) {
      return "${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}";
    } else {
      return "${timestamp.month}/${timestamp.day} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}";
    }
  }
}
