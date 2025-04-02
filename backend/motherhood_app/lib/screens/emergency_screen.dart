import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EmergencyScreen extends StatefulWidget {
  @override
  _EmergencyScreenState createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  List<Map<String, dynamic>> emergencyContacts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchEmergencyContacts();
  }

  // Fetch emergency contacts from API (No authentication needed)
  Future<void> fetchEmergencyContacts() async {
    final url = Uri.parse("http://127.0.0.1:8000/api/emergency/send-alert/");
    try {
      final response = await http.post(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          emergencyContacts = List<Map<String, dynamic>>.from(data);
          isLoading = false;
        });
      } else {
        showError("Failed to load contacts");
      }
    } catch (e) {
      showError("Error: $e");
    }
  }

  // Send emergency alert (No authentication needed)
  Future<void> sendEmergencyAlert(int contactId) async {
    final url = Uri.parse("http://127.0.0.1:8000/api/emergency/contacts/");
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"contact_id": contactId}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Emergency alert sent successfully!")),
        );
      } else {
        showError("Failed to send alert");
      }
    } catch (e) {
      showError("Error: $e");
    }
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
    setState(() {
      isLoading = false;
    });
  }

  void confirmSendAlert(int contactId, String contactName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Send Emergency Alert?"),
        content: Text("Are you sure you want to alert $contactName?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              sendEmergencyAlert(contactId);
            },
            child: Text("Send", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Emergency Contacts")),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : emergencyContacts.isEmpty
              ? Center(child: Text("No emergency contacts available."))
              : ListView.builder(
                  itemCount: emergencyContacts.length,
                  itemBuilder: (context, index) {
                    final contact = emergencyContacts[index];
                    return Card(
                      child: ListTile(
                        leading: Icon(Icons.phone, color: Colors.red),
                        title: Text(contact['name']),
                        subtitle: Text(contact['phone']),
                        trailing: IconButton(
                          icon: Icon(Icons.warning, color: Colors.red),
                          onPressed: () => confirmSendAlert(contact['id'], contact['name']),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
