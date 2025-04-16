import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:motherhood_app/models/nutrition_models.dart';
import 'package:motherhood_app/services/token_manager.dart';

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => "❗ ApiException: $message";
}

class ApiService {
  static const String baseUrl =
      "http://127.0.0.1:8000/api"; // ✅ Update this for production

  /// 🔐 Get stored JWT token
  static Future<Map<String, String>?> getAuthHeaders() async {
    final token = await TokenManager.getValidToken();
    if (token == null) return null;
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  /// 🧠 Fetch Health Insights
  static Future<Map<String, dynamic>?> fetchHealthInsights() async {
    final headers = await getAuthHeaders();
    if (headers == null) return null;

    final response = await http.get(
      Uri.parse("$baseUrl/health_insights/"),
      headers: headers,
    );

    return _handleJsonResponse(response, "Health insights");
  }

  /// 👶 Fetch Baby Tracking Dashboard
  static Future<Map<String, dynamic>?> fetchBabyTrackingDashboard() async {
    final headers = await getAuthHeaders();
    if (headers == null) return null;

    final response = await http.get(
      Uri.parse("$baseUrl/baby_tracking/dashboard/"),
      headers: headers,
    );

    return _handleJsonResponse(response, "Baby tracking dashboard");
  }

  /// 🍼 Fetch Pregnancy Data
  static Future<Map<String, dynamic>?> fetchPregnancyData() async {
    final headers = await getAuthHeaders();
    if (headers == null) return null;

    final response = await http.get(
      Uri.parse("$baseUrl/baby_tracking/"),
      headers: headers,
    );

    return _handleJsonResponse(response, "Pregnancy data");
  }

  /// 🔔 Fetch Notifications
  static Future<Map<String, dynamic>?> fetchNotifications() async {
    final headers = await getAuthHeaders();
    if (headers == null) return null;

    final response = await http.get(
      Uri.parse("$baseUrl/notifications/"),
      headers: headers,
    );

    return _handleJsonResponse(response, "Notifications");
  }

  /// 💉 Fetch Immunization Records
  static Future<List<Map<String, dynamic>>> fetchImmunizationRecords() async {
    final headers = await getAuthHeaders();
    if (headers == null) throw ApiException("User not authenticated");

    final response = await http.get(
      Uri.parse("$baseUrl/immunization/records/"),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      _logError(response, "Immunization records");
      throw ApiException("Failed to load immunization records");
    }
  }

  /// 🍽️ Fetch Nutrition Guides
  static Future<List<NutritionGuide>> fetchNutritionGuides(
    String trimester,
  ) async {
    final headers = await getAuthHeaders();
    if (headers == null) throw ApiException("User not authenticated");

    final response = await http.get(
      Uri.parse('$baseUrl/nutrition/meals/'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      return data.map((item) => NutritionGuide.fromJson(item)).toList();
    } else {
      _logError(response, "Nutrition guides");
      throw ApiException('Failed to load nutrition guides');
    }
  }

  /// 🍱 Fetch Daily Meal Plans
  static Future<List<DailyMeal>> fetchDailyMealPlans() async {
    final headers = await getAuthHeaders();
    if (headers == null) throw ApiException("User not authenticated");

    final response = await http.get(
      Uri.parse('$baseUrl/nutrition/meal-plans/'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      return data.map((item) => DailyMeal.fromJson(item)).toList();
    } else {
      _logError(response, "Meal plans");
      throw ApiException('Failed to load meal plans');
    }
  }

  /// 👤 Fetch User Profile
  static Future<Map<String, dynamic>> fetchUserProfile() async {
    final headers = await getAuthHeaders();
    if (headers == null) throw ApiException("User not authenticated");

    final response = await http.get(
      Uri.parse("$baseUrl/users/me/"),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      _logError(response, "User profile");
      throw ApiException("Failed to fetch profile");
    }
  }

  /// 🔍 Utility: Handle and parse response
  static Map<String, dynamic>? _handleJsonResponse(
    http.Response response,
    String label,
  ) {
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      _logError(response, label);
      return null;
    }
  }

  /// 🚨 Utility: Print detailed error info
  static void _logError(http.Response response, String label) {
    print("❌ [$label] Error ${response.statusCode}: ${response.body}");
  }
}
