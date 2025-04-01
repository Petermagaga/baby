import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProfileService {
  static const String baseUrl = "http://your-backend-domain.com/api/users";

  /// **Get Token from SharedPreferences**
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  /// **Fetch User Profile**
  static Future<Map<String, dynamic>> fetchProfile() async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse("$baseUrl/profile/"),  // Ensure trailing slash
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load profile");
    }
  }

  /// **Fetch Profile Completion Percentage**
  static Future<int> fetchProfileCompletion() async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse("$baseUrl/profile/completion/"), // Ensure trailing slash
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)["completion"];
    } else {
      throw Exception("Failed to fetch profile completion");
    }
  }

  /// **Update User Profile**
  static Future<void> updateProfile(Map<String, dynamic> updatedData) async {
    final token = await getToken();
    final response = await http.put(
      Uri.parse("$baseUrl/profile/"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode(updatedData),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to update profile");
    }
  }

  /// **Upload Profile Picture**
  static Future<void> uploadProfilePicture(String filePath) async {
    final token = await getToken();
    var request = http.MultipartRequest("POST", Uri.parse("$baseUrl/profile/upload/"));
    request.headers["Authorization"] = "Bearer $token";
    request.files.add(await http.MultipartFile.fromPath("file", filePath));

    final response = await request.send();
    if (response.statusCode != 200) {
      throw Exception("Failed to upload profile picture");
    }
  }

  /// **Update Password**
  static Future<void> updatePassword(String newPassword) async {
    final token = await getToken();
    final response = await http.post(
      Uri.parse("$baseUrl/profile/update-password/"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({"password": newPassword}),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to update password");
    }
  }
}
