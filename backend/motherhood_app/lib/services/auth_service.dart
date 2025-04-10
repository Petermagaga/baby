import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart';
import 'package:image_picker/image_picker.dart';

class AuthService {
  static const String _loginUrl = "http://127.0.0.1:8000/api/token/";
  static const String _registerUrl = "http://127.0.0.1:8000/api/users/register/";

  // 🔐 LOGIN FUNCTION
  Future<bool> login(String usernameOrEmail, String password) async {
    final url = Uri.parse(_loginUrl);
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"username": usernameOrEmail, "password": password}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      await _saveToken(data["access"], data["refresh"]);
      print("✅ Logged in: Access=${data["access"]}");
      return true;
    } else {
      print("❌ Login failed: ${response.body}");
      return false;
    }
  }

  // ✅ REGISTRATION FUNCTION WITH MULTIPART
  Future<bool> register({
    required String username,
    required String email,
    required String password,
    String? age,
    String? healthConditions,
    String? location,
    String? jobType,
    XFile? profileImage,
  }) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(_registerUrl));

      request.fields['username'] = username;
      request.fields['email'] = email;
      request.fields['password'] = password;
      if (age != null) request.fields['age'] = age;
      if (healthConditions != null) request.fields['health_conditions'] = healthConditions;
      if (location != null) request.fields['location'] = location;
      if (jobType != null) request.fields['job_type'] = jobType;

      if (profileImage != null) {
        final file = File(profileImage.path);
        final mimeType = lookupMimeType(file.path) ?? 'image/jpeg';

        request.files.add(await http.MultipartFile.fromPath(
          'profile_picture',
          file.path,
          contentType: MediaType.parse(mimeType),
          filename: basename(file.path),
        ));
      }

      final response = await request.send();

      if (response.statusCode == 201) {
        print("✅ Registration successful");
        return true;
      } else {
        print("❌ Registration failed: ${await response.stream.bytesToString()}");
        return false;
      }
    } catch (e) {
      print("❌ Registration error: $e");
      return false;
    }
  }

  // 🔐 SAVE TOKENS LOCALLY
  Future<void> _saveToken(String accessToken, String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("accessToken", accessToken);
    await prefs.setString("refreshToken", refreshToken);
  }

  // 🔄 REFRESH TOKEN
  Future<String?> refreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    String? refresh = prefs.getString("refreshToken");

    if (refresh == null) return null;

    final response = await http.post(
      Uri.parse("http://127.0.0.1:8000/api/token/refresh/"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"refresh": refresh}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      await prefs.setString("accessToken", data["access"]);
      return data["access"];
    } else {
      print("❌ Refresh failed: ${response.body}");
      return null;
    }
  }

  // 🔍 GET TOKEN
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("accessToken");
  }

  // 🔒 LOGOUT
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("accessToken");
    await prefs.remove("refreshToken");
  }

  // 🔎 IS LOGGED IN
  Future<bool> isAuthenticated() async {
    return (await getToken()) != null;
  }
}
