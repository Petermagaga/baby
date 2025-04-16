import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:motherhood_app/models/Pregnancy_model.dart';
import 'package:motherhood_app/services/token_manager.dart'; // Adjust path as needed

const baseUrl = 'http://127.0.0.1:8000/api'; // Make sure your IP or domain is correct

class PregnancyService {
  Future<bool> createPregnancy({required DateTime startDate}) async {
    final token = await TokenManager.getValidToken();
    if (token == null) return false;

    final response = await http.post(
      Uri.parse('$baseUrl/pregnancy/create/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'start_date': startDate.toIso8601String()}),
    );

    return response.statusCode == 201;
  }

  Future<Pregnancy?> fetchPregnancy() async {
    final token = await TokenManager.getValidToken();
    if (token == null) return null;

    final response = await http.get(
      Uri.parse('$baseUrl/pregnancy/'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return Pregnancy.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  Future<bool> deletePregnancy() async {
    final token = await TokenManager.getValidToken();
    if (token == null) return false;

    final response = await http.delete(
      Uri.parse('$baseUrl/pregnancy/delete/'),
      headers: {'Authorization': 'Bearer $token'},
    );

    return response.statusCode == 204;
  }

  Future<List<dynamic>> fetchNutritionGuide(String trimester) async {
  final token = await TokenManager.getValidToken();
  if (token == null) return [];

  final response = await http.get(
    Uri.parse('$baseUrl/nutrition-guide/?trimester=$trimester'),
    headers: {'Authorization': 'Bearer $token'},
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  }
  return [];
}


}
