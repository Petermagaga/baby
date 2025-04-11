import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as path;

class ProfileScreen extends StatefulWidget {
  final VoidCallback? toggleTheme;

  const ProfileScreen({Key? key, this.toggleTheme}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  int profileCompletion = 0;

  final usernameController = TextEditingController();
  final ageController = TextEditingController();
  final locationController = TextEditingController();
  final jobTypeController = TextEditingController();
  final healthConditionController = TextEditingController();
  final passwordController = TextEditingController();

  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _profileImage = File(picked.path));
    }
  }

  Future<void> _loadUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access') ?? "";

    try {
      final dio = Dio();
      final response = await dio.get(
        'http://127.0.0.1:8000/api/users/me/', // ✅ update as per platform
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final data = response.data;

      setState(() {
        usernameController.text = data['username'] ?? '';
        ageController.text = data['age']?.toString() ?? '';
        locationController.text = data['location'] ?? '';
        jobTypeController.text = data['job_type'] ?? '';
        healthConditionController.text = data['health_conditions'] ?? '';
      });

      // Optional: get profile completion
      final username = data['username'];
      final completionRes = await dio.get(
        'http://127.0.0.1:8000/api/users/profile-completion/?username=$username',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      setState(() {
        profileCompletion =
            completionRes.data['completion_percentage'] ?? 0;
      });
    } catch (e) {
      print("❌ Error loading profile: $e");
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access') ?? "";

      final dio = Dio();

      final formData = FormData.fromMap({
        'username': usernameController.text,
        'age': ageController.text,
        'location': locationController.text,
        'job_type': jobTypeController.text,
        'health_conditions': healthConditionController.text,
        if (passwordController.text.isNotEmpty)
          'password': passwordController.text,
        if (_profileImage != null)
          'profile_picture': await MultipartFile.fromFile(
            _profileImage!.path,
            filename: path.basename(_profileImage!.path),
          ),
      });

      final response = await dio.post(
        'http://127.0.0.1:8000/api/users/update-profile/',
        data: formData,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Profile updated!')),
        );
        await _loadUserProfile(); // Refresh view
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Update failed: ${response.statusMessage}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget buildStyledTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool obscure = false,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        validator: validator,
      ),
    );
  }

  @override
  void dispose() {
    usernameController.dispose();
    ageController.dispose();
    locationController.dispose();
    jobTypeController.dispose();
    healthConditionController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          if (widget.toggleTheme != null)
            IconButton(
              icon: const Icon(Icons.brightness_6),
              onPressed: widget.toggleTheme!,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: isDark ? 2 : 4,
            color: Theme.of(context).cardColor,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 60,
                      backgroundImage: _profileImage != null
                          ? FileImage(_profileImage!)
                          : const AssetImage('assets/default_avatar.png')
                              as ImageProvider,
                      child: _profileImage == null
                          ? const Icon(Icons.camera_alt, size: 30)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(value: profileCompletion / 100),
                  Text('$profileCompletion% profile complete'),
                  const SizedBox(height: 20),
                  buildStyledTextField(
                    controller: usernameController,
                    label: 'Username',
                    hint: 'Enter your username',
                    icon: Icons.person,
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Required' : null,
                  ),
                  buildStyledTextField(
                    controller: ageController,
                    label: 'Age',
                    hint: 'Enter your age',
                    icon: Icons.cake,
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Required' : null,
                  ),
                  buildStyledTextField(
                    controller: locationController,
                    label: 'Location',
                    hint: 'Enter your location',
                    icon: Icons.location_on,
                  ),
                  buildStyledTextField(
                    controller: jobTypeController,
                    label: 'Job Type',
                    hint: 'Enter your job type',
                    icon: Icons.work,
                  ),
                  buildStyledTextField(
                    controller: healthConditionController,
                    label: 'Health Conditions',
                    hint: 'Enter any health conditions',
                    icon: Icons.favorite,
                  ),
                  buildStyledTextField(
                    controller: passwordController,
                    label: 'Password',
                    hint: 'Update password (optional)',
                    icon: Icons.lock,
                    obscure: true,
                    validator: (value) =>
                        value != null && value.isNotEmpty && value.length < 6
                            ? 'Min 6 characters'
                            : null,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.save),
                    label: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Save Changes'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _isLoading ? null : _updateProfile,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
