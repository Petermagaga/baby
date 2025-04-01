import 'package:flutter/material.dart';
import '../services/api_service.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  Map<String, dynamic>? notifications;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    var data = await ApiService.fetchNotifications();
    setState(() {
      notifications = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Notifications")),
      body: notifications == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                if (notifications!["motivational_message"] != null)
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.mood, color: Colors.blue),
                      title: const Text("Motivational Message"),
                      subtitle: Text(notifications!["motivational_message"]["message"]),
                    ),
                  ),

                if (notifications!["counseling_sessions"] != null)
                  ...notifications!["counseling_sessions"].map<Widget>((session) {
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.event, color: Colors.green),
                        title: Text("Counseling with ${session["counselor_name"]}"),
                        subtitle: Text("Status: ${session["status"]}"),
                      ),
                    );
                  }).toList(),
              ],
            ),
    );
  }
}
