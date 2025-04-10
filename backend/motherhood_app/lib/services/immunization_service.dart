import 'dart:convert';
import 'package:http/http.dart' as http;

class ImmunizationService {
  // Fetch Immunization Records WITHOUT authentication
  Future<List<Map<String, dynamic>>> fetchImmunizationRecords() async {
    final response = await http.get(
      Uri.parse("http://127.0.0.1:8000/api/immunization/records/"),
    );

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      throw Exception("Failed to load records");
    }
  }

  // Add New Immunization Record WITHOUT authentication
  Future<bool> addImmunizationRecord(String vaccineName, String dateGiven, String? nextDueDate) async {
    final response = await http.post(
      Uri.parse("http://127.0.0.1:8000/api/immunization/add/"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"vaccine_name": vaccineName, "date_given": dateGiven, "next_due_date": nextDueDate}),
    );

    return response.statusCode == 201;
  }

  // Update Immunization Progress WITHOUT authentication
  Future<bool> updateImmunizationProgress(int id, bool isCompleted) async {
    final response = await http.patch(
      Uri.parse("http://127.0.0.1:8000/api/immunization/update/$id/"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"is_completed": isCompleted}),
    );

    return response.statusCode == 200;
  }
}
