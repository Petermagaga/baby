import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl = "http://127.0.0.1:8000/api/token/";

  // 🔹 Login Method (JWT Authentication)
  Future<bool> login(String usernameOrEmail, String password) async {
    final url = Uri.parse(baseUrl);
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"username": usernameOrEmail, "password": password}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      String accessToken = data["access"];
      String refreshToken = data["refresh"];

      await _saveToken(accessToken, refreshToken);

      // 🔹 Debug: Print token to check if it's saved
      print("🔹 Access Token: $accessToken");
      print("🔹 Refresh Token: $refreshToken");

      return true;
    } else {
      print("❌ Login Failed: ${response.body}");
      return false;
    }
  }

  // 🔹 Save Token to Local Storage
  Future<void> _saveToken(String accessToken, String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("accessToken", accessToken);
    await prefs.setString("refreshToken", refreshToken);
  }

  // 🔹 Retrieve Saved Token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("accessToken");
  }

  // 🔹 Logout Method
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("accessToken");
    await prefs.remove("refreshToken");
  }

  // 🔹 Check If User is Authenticated
  Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null;
  }

  // 🔹 Get Valid Token (Check Access Token, Otherwise Refresh)
  Future<String?> getValidToken() async {
    String? accessToken = await getToken();
    if (accessToken != null) {
      return accessToken;
    } else {
      return await refreshToken();
    }
  }

  // 🔹 Refresh Token
  Future<String?> refreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    String? refreshToken = prefs.getString("refreshToken");

    if (refreshToken == null) return null;

    final response = await http.post(
      Uri.parse("http://127.0.0.1:8000/api/token/refresh/"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"refresh": refreshToken}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      String newAccessToken = data["access"];
      await prefs.setString("accessToken", newAccessToken);
      print("🔹 Saved Auth Token: $newAccessToken");

      return newAccessToken;
    } else {
      print("❌ Token refresh failed: ${response.body}");
      return null;
    }
  }
}
