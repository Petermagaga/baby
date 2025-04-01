import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = "http://your-backend-url/api"; // Change this

  // 🔹 Fetch Profile
  static Future<Map<String, dynamic>> fetchProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("accessToken"); // Ensure it's "accessToken"

    if (token == null) {
      throw Exception("No authentication token found. Please log in.");
    }

    print("🔹 Fetching Profile with Token: $token"); // ✅ Debugging Token

    final response = await http.get(
      Uri.parse("$baseUrl/profile"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Failed to fetch profile");
    }
  }

  // 🔹 Fetch Health Insights
  static Future<Map<String, dynamic>?> fetchHealthInsights() async {
    String? token = await FirebaseAuth.instance.currentUser?.getIdToken();

    if (token == null) return null; // Handle unauthenticated user

    final response = await http.get(
      Uri.parse("$baseUrl/health_insights/"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print("❌ Error fetching health insights: ${response.statusCode}");
      return null;
    }
  }

  // 🔹 Fetch Baby Tracking Data (Dashboard Summary)
  static Future<Map<String, dynamic>?> fetchBabyTrackingDashboard() async {
    String? token = await FirebaseAuth.instance.currentUser?.getIdToken();

    if (token == null) return null; // Fix: Added return null for proper handling

    final response = await http.get(
      Uri.parse("$baseUrl/baby_tracking/dashboard/"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print("❌ Error fetching baby tracking dashboard: ${response.statusCode}");
      return null;
    }
  }

  // 🔹 Fetch Pregnancy Data (for current week)
  static Future<Map<String, dynamic>?> fetchPregnancyData() async {
    String? token = await FirebaseAuth.instance.currentUser?.getIdToken();
    
    if (token == null) return null; // Handle unauthenticated user

    final response = await http.get(
      Uri.parse("$baseUrl/baby_tracking/"), // Ensure correct API endpoint
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print("❌ Error fetching pregnancy data: ${response.statusCode}");
      return null;
    }
  }

  // 🔹 Fetch Notifications
  static Future<Map<String, dynamic>?> fetchNotifications() async {
    String? token = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (token == null) return null; // User not logged in

    final response = await http.get(
      Uri.parse("$baseUrl/notifications/"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print("❌ Error fetching notifications: ${response.statusCode}");
      return null;
    }
  }

  // 🔹 Fetch Immunization Records
  static Future<List<Map<String, dynamic>>> fetchImmunizationRecords(String token) async {
    final response = await http.get(
      Uri.parse("$baseUrl/immunization/records/"),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      throw Exception("Failed to load records");
    }
  }
}
