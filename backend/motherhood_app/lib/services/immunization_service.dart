import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ImmunizationService {
  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');  // Retrieve JWT token from storage
  }

  // Fetch Immunization Records
  Future<List<Map<String, dynamic>>> fetchImmunizationRecords() async {
    String? token = await _getToken();
    if (token == null) throw Exception("User not authenticated");

    final response = await http.get(
      Uri.parse("http://127.0.0.1:8000/api/immunization/records/"),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      throw Exception("Failed to load records");
    }
  }

  // Add New Immunization Record
  Future<bool> addImmunizationRecord(String vaccineName, String dateGiven, String? nextDueDate) async {
    String? token = await _getToken();
    if (token == null) throw Exception("User not authenticated");

    final response = await http.post(
      Uri.parse("http://127.0.0.1:8000/api/immunization/add/"),
      headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
      body: jsonEncode({"vaccine_name": vaccineName, "date_given": dateGiven, "next_due_date": nextDueDate}),
    );

    return response.statusCode == 201;
  }

  // Update Immunization Progress
  Future<bool> updateImmunizationProgress(int id, bool isCompleted) async {
    String? token = await _getToken();
    if (token == null) throw Exception("User not authenticated");

    final response = await http.patch(
      Uri.parse("http://127.0.0.1:8000/api/immunization/update/$id/"),
      headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
      body: jsonEncode({"is_completed": isCompleted}),
    );

    return response.statusCode == 200;
  }
}
