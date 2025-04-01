import 'package:flutter/material.dart';
import '../services/immunization_service.dart';

class ImmunizationScreen extends StatefulWidget {
  @override
  _ImmunizationScreenState createState() => _ImmunizationScreenState();
}

class _ImmunizationScreenState extends State<ImmunizationScreen> {
  final ImmunizationService immunizationService = ImmunizationService();

  List<Map<String, String>> immunizationSchedule = [
    {"age": "At birth", "vaccine": "BCG, Hepatitis B"},
    {"age": "6 weeks", "vaccine": "DTP, Polio, Rotavirus"},
    {"age": "10 weeks", "vaccine": "DTP, Polio, Rotavirus"},
    {"age": "14 weeks", "vaccine": "DTP, Polio, Hib"},
    {"age": "9 months", "vaccine": "Measles, Yellow Fever"},
  ];

  List<Map<String, dynamic>> immunizationRecords = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    loadImmunizationRecords();
  }

  Future<void> loadImmunizationRecords() async {
    try {
      // Replace with actual token retrieval (e.g., from shared preferences)
      String token = "YOUR_JWT_TOKEN";
      List<Map<String, dynamic>> records = await immunizationService.fetchImmunizationRecords();
      setState(() {
        immunizationRecords = records;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Immunization Schedule & Records")),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage, style: TextStyle(color: Colors.red)))
              : ListView(
                  padding: EdgeInsets.all(16),
                  children: [
                    Text("📌 Scheduled Immunizations", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    ...immunizationSchedule.map((item) => ListTile(
                          title: Text(item["age"] ?? "", style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text("Vaccine: ${item["vaccine"]}"),
                          trailing: Icon(Icons.schedule, color: Colors.blue),
                        )),
                    Divider(),
                    Text("🩺 Received Immunizations", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    ...immunizationRecords.map((record) => ListTile(
                          title: Text(record['vaccine_name'], style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text("Given on: ${record['date_given']}"),
                          trailing: record['next_due_date'] != null
                              ? Text("Next: ${record['next_due_date']}", style: TextStyle(color: Colors.orange))
                              : Icon(Icons.check_circle_outline, color: Colors.green),
                        )),
                  ],
                ),
    );
  }
}
