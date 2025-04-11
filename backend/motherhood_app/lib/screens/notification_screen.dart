import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<dynamic> _messages = [];
  bool _isLoading = true;
  String apiUrl = "http://127.0.0.1:8000/api/mental_health/notifications/"; // Replace with actual URL

  // Fetch messages from the API
  Future<void> fetchMessages() async {
    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer YOUR_TOKEN_HERE', // Replace with real token
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);

        // Optional: Filter out old messages (e.g., older than 30 days)
        final now = DateTime.now();
        data = data.where((msg) {
          final createdAt = DateTime.parse(msg['created_at']);
          return now.difference(createdAt).inDays <= 30;
        }).toList();

        setState(() {
          _messages = data;
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load messages');
      }
    } catch (e) {
      print("Error fetching messages: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    fetchMessages();
  }

  // Group messages by the date they were created
  Map<String, List<dynamic>> groupMessagesByDate(List<dynamic> messages) {
    Map<String, List<dynamic>> groupedMessages = {};

    for (var message in messages) {
      final date = message['created_at'].substring(0, 10); // Extract date (yyyy-mm-dd)

      if (groupedMessages[date] == null) {
        groupedMessages[date] = [];
      }

      groupedMessages[date]?.add(message);
    }

    return groupedMessages;
  }

  @override
  Widget build(BuildContext context) {
    final pinkColor = Colors.pink.shade100;
    final darkPink = Colors.pink.shade300;

    return Scaffold(
      backgroundColor: pinkColor,
      appBar: AppBar(
        backgroundColor: darkPink,
        title: const Text(
          "Daily Motivation",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.pink))
          : RefreshIndicator(
              onRefresh: fetchMessages, // Pull-to-refresh action
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Group messages by date
                  ...groupMessagesByDate(_messages).entries.map((entry) {
                    final date = entry.key;
                    final messages = entry.value;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            date,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.pinkAccent,
                            ),
                          ),
                        ),
                        // Message cards
                        ...messages.map((message) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.pink.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  message['message'],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.pink,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "- ${message['author']}",
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontStyle: FontStyle.italic,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Text(
                                      message['created_at']
                                          .substring(0, 10),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    );
                  }).toList(),
                ],
              ),
            ),
    );
  }
}
