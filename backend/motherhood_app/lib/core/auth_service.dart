import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:motherhood_app/services/token_manager.dart'; // ✅ import your TokenManager

class AuthService {
  static const String baseUrl = "http://127.0.0.1:8000/api/users";
  static const String tokenUrl = "http://127.0.0.1:8000/api/token/";
  static const String refreshUrl = "http://127.0.0.1:8000/api/token/refresh/";

  Future<bool> register(String username, String email, String password, {required String healthConditions}) async {
    final url = Uri.parse('$baseUrl/register/');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": username,
        "email": email,
        "password": password,
        // Optionally add healthConditions here if your backend expects it
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

  Future<bool> login(String usernameOrEmail, String password) async {
    final response = await http.post(
      Uri.parse(tokenUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": usernameOrEmail,
        "password": password,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      await TokenManager.setTokens(data["access"], data["refresh"]);
      print("✅ Login successful");
      return true;
    } else {
      print("❌ Login failed: ${response.body}");
      return false;
    }
  }

  Future<void> logout() async {
    await TokenManager.clearTokens();
    print("✅ User logged out");
  }

  Future<bool> isAuthenticated() async {
    final token = await getValidToken();
    return token != null;
  }

  Future<String?> getValidToken() async {
    final accessToken = TokenManager.accessToken;
    final refreshToken = TokenManager.refreshToken;

    if (accessToken != null) {
      return accessToken;
    }

    if (refreshToken == null) {
      print("❌ No refresh token available.");
      return null;
    }

    final response = await http.post(
      Uri.parse(refreshUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"refresh": refreshToken}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await TokenManager.setTokens(data['access'], refreshToken);
      print("🔄 Token refreshed successfully");
      return data['access'];
    } else {
      print("❌ Token refresh failed: ${response.body}");
      return null;
    }
  }
}
