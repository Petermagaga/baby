import 'dart:convert';
import 'dart:io';
import 'firebase_storage_service.dart'; // Ensure this is your service that handles Firebase storage
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:motherhood_app/models/matched_user.dart';


class AuthService {

  Future<List<MatchedUser>> getMatchedUsers() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString("accessToken");

  if (token == null) {
    throw Exception("Not authenticated");
  }

  final response = await http.get(
    Uri.parse("http://127.0.0.1:8000/api/users/matches/"),
    headers: {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
    },
  );

  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    return data.map((json) => MatchedUser.fromJson(json)).toList();
  } else {
    print("❌ Failed to fetch matched users: ${response.body}");
    throw Exception("Failed to load matched users");
  }
}






  static const String _loginUrl = "http://127.0.0.1:8000/api/users/login/";
  static const String _registerUrl = "http://127.0.0.1:8000/api/users/register/";

  // 🔐 LOGIN FUNCTION
Future<bool> login(String usernameOrEmail, String password) async {
  final url = Uri.parse("http://127.0.0.1:8000/api/users/login/");
  final response = await http.post(
    url,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "username": usernameOrEmail,  // assuming you use email to login
      "password": password,
    }),
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);



    final prefs = await SharedPreferences.getInstance();
    print("💾 BEFORE saving: ${prefs.getString("accessToken")}");
    // ✅ Save tokens
    final access = data["tokens"]?["access"];
    final refresh = data["tokens"]?["refresh"];

        print("🔑 Access: $access");
        print("🔑 Refresh: $refresh");

    if (access != null && refresh != null) {
      await prefs.setString("accessToken", access);
      await prefs.setString("refreshToken", refresh);

      print("💾 AFTER saving: ${prefs.getString("accessToken")}");
    } else {
      print("⚠️ Tokens missing in response");
      return false;
    }

    // ✅ Save user info (optional, check for null)
    final user = data["user"];
    if (user != null && user is Map<String, dynamic>) {
      await prefs.setString("username", user["username"] ?? "");
      await prefs.setString("email", user["email"] ?? "");
      await prefs.setString("profile_picture", user["profile_picture"] ?? "");
      print("🧠 Saved user: ${user["username"]}");
      print("✅ Token saved: $access");
    } else {
      print("⚠️ No user data in response");
    }

    print("✅ Login successful");
    return true;
  } else {
    print("❌ Login failed: ${response.body}");
    return false;
  }
}


  // ✅ REGISTRATION FUNCTION WITH IMAGE UPLOAD TO FIREBASE
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
      String? imageUrl;
      if (profileImage != null) {
        imageUrl = await uploadProfileImageToFirebase(profileImage); // Upload image to Firebase and get URL
      }

      final response = await http.post(
        Uri.parse(_registerUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
          'age': age,
          'health_conditions': healthConditions,
          'location': location,
          'job_type': jobType,
          'profile_picture': imageUrl, // Send the image URL to Django
        }),
      );

      if (response.statusCode == 201) {
        print("✅ Registration successful");
        return true;
      } else {
        print('❌ Registration failed: ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Registration error: $e');
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

  // 🔥 UPLOAD IMAGE TO FIREBASE (FIREBASE STORAGE SERVICE)
  Future<String?> uploadProfileImageToFirebase(XFile imageFile) async {
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_images/${DateTime.now().millisecondsSinceEpoch}_${imageFile.name}');
      
      final uploadTask = await storageRef.putFile(File(imageFile.path));
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('❌ Upload error: $e');
      return null;
    }
  }
}
