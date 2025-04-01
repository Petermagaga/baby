import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/api.dart';
import '../models/user_profile.dart';

class ProfileService {
  final Dio _dio = Dio(BaseOptions(baseUrl: API.baseURL));

  Future<bool> saveUserProfile(UserProfile profile) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) return false;

    try {
      Response response = await _dio.post(
        "user/profile/",
        data: profile.toJson(),
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );
      return response.statusCode == 201;
    } catch (e) {
      print("Profile Error: $e");
      return false;
    }
  }
}
