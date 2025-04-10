import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl = "http://127.0.0.1:8000/api/users"; // ✅ API Base URL
  static const String tokenUrl = "http://127.0.0.1:8000/api/token/";
  static const String refreshUrl = "http://127.0.0.1:8000/api/token/refresh/";

  // 🔹 Register User
  Future<bool> register(String username, String email, String password, {required String healthConditions}) async {
    final url = Uri.parse('$baseUrl/register/');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": username,
        "email": email,
        "password": password,
      }),
    );

    if (response.statusCode == 201) {
      print("✅ Registration successful");
      return true;
    } else {
      print("❌ Registration failed: ${response.body}");
      return false;
    }
  }

  // 🔹 Login (JWT Authentication)
  Future<bool> login(String usernameOrEmail, String password) async {
    final url = Uri.parse(tokenUrl);
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": usernameOrEmail, // Change to "email" if needed
        "password": password,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      String accessToken = data["access"];
      String refreshToken = data["refresh"];

      await _saveToken(accessToken, refreshToken);
      print("✅ Login successful");
      return true;
    } else {
      print("❌ Login failed: ${response.body}");
      return false;
    }
  }

  // 🔹 Logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("accessToken");
    await prefs.remove("refreshToken");
    print("✅ User logged out");
  }

  // 🔹 Save Tokens
  Future<void> _saveToken(String accessToken, String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("accessToken", accessToken);
    await prefs.setString("refreshToken", refreshToken);
  }

  // 🔹 Retrieve Access Token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("auth_token");
  }

  // 🔹 Check Authentication Status
  Future<bool> isAuthenticated() async {
    final token = await getValidToken(); // ✅ Use refreshed token if needed
    return token != null;
  }

  // 🔹 Refresh Token If Expired
  Future<String?> getValidToken() async {
    final prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString("accessToken");
    String? refreshToken = prefs.getString("refreshToken");

    if (accessToken != null) {
      return accessToken; // ✅ Use existing token if still valid
    }

    if (refreshToken == null) {
      print("❌ No refresh token available.");
      return null;
    }

    // 🔄 Refresh token
    final response = await http.post(
      Uri.parse(refreshUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"refresh": refreshToken}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      String newAccessToken = data['access'];
      await prefs.setString("accessToken", newAccessToken); // ✅ Save new token
      print("🔄 Token refreshed successfully");
      return newAccessToken;
    } else {
      print("❌ Token refresh failed: ${response.body}");
      return null;
    }
  }
}
