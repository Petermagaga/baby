import 'dart:convert';
import 'package:http/http.dart' as http;

class ProfileService {
  static const String baseUrl = "http://127.0.0.1:8000/api/users";

  /// **Fetch User Profile**
  static Future<Map<String, dynamic>> fetchProfile() async {
    final response = await http.get(Uri.parse("$baseUrl/profile/"));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load profile");
    }
  }

  /// **Fetch Profile Completion Percentage**
  static Future<int> fetchProfileCompletion(String username) async {
    final response = await http.get(Uri.parse("$baseUrl/profile/completion/username=$username"));

    if (response.statusCode == 200) {
      return jsonDecode(response.body)["completion_percentage"];
    } else {
      throw Exception("Failed to fetch profile completion: ${response.body}");
    }
  }

  /// **Update User Profile**
  static Future<void> updateProfile(Map<String, dynamic> updatedData) async {
    final response = await http.put(
      Uri.parse("$baseUrl/profile/"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(updatedData),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to update profile");
    }
  }

  /// **Upload Profile Picture**
  static Future<void> uploadProfilePicture(String filePath) async {
    var request = http.MultipartRequest("POST", Uri.parse("$baseUrl/profile/upload/"));
    request.files.add(await http.MultipartFile.fromPath("file", filePath));

    final response = await request.send();
    if (response.statusCode != 200) {
      throw Exception("Failed to upload profile picture");
    }
  }

  /// **Update Password**
  static Future<void> updatePassword(String username,String newPassword) async {
    final response = await http.post(
      Uri.parse("$baseUrl/profile/update-password/"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username":username,
        "password": newPassword}),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to update password");
    }
  }
}
