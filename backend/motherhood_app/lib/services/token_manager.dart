import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TokenManager {
  static String? _accessToken;
  static String? _refreshToken;

  /// Initialize tokens from storage
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString("accessToken");
    _refreshToken = prefs.getString("refreshToken");
  }

  /// Access token getter
  static String? get accessToken => _accessToken;

  /// Refresh token getter
  static String? get refreshToken => _refreshToken;

  /// Store both tokens
  static Future<void> setTokens(String access, String refresh) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("accessToken", access);
    await prefs.setString("refreshToken", refresh);
    _accessToken = access;
    _refreshToken = refresh;
  }

  /// Clear both tokens
  static Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("accessToken");
    await prefs.remove("refreshToken");
    _accessToken = null;
    _refreshToken = null;
  }

  /// Get valid token (access or refresh)
  static Future<String?> getValidToken() async {
    final prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString("accessToken");
    String? refreshToken = prefs.getString("refreshToken");

    if (accessToken != null) {
      return accessToken;
    }

    if (refreshToken == null) {
      return null;
    }

    final response = await http.post(
      Uri.parse("http://127.0.0.1:8000/api/token/refresh/"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"refresh": refreshToken}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      String newAccessToken = data['access'];
      await prefs.setString("accessToken", newAccessToken);
      _accessToken = newAccessToken;
      return newAccessToken;
    }

    return null;
  }
}
