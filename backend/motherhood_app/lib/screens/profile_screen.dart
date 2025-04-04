import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:motherhood_app/services/profile_service.dart';

class ProfileScreen extends StatefulWidget {
  final Function(ThemeMode) toggleTheme;

  ProfileScreen({required this.toggleTheme});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker picker = ImagePicker();

  File? _image;
  bool _isLoading = false;
  double _opacity = 0.0;
  int profileCompletion = 0;
  Map<String, dynamic> profileData = {};

  final usernameController = TextEditingController();
  final ageController = TextEditingController();
  final locationController = TextEditingController();
  final jobTypeController = TextEditingController();
  final healthConditionsController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() => _opacity = 1.0);
      }
    });

    loadProfile().then((_) {
      if (mounted && usernameController.text.isNotEmpty) {
        loadProfileCompletion();
      } else {
        print("Skipping profile completion fetch: Username is empty");
      }
    });
  }

  Future<void> loadProfile() async {
    try {
      Map<String, dynamic> data = await ProfileService.fetchProfile();
      if (mounted) {
        setState(() {
          profileData = data;
          usernameController.text = data["username"] ?? "";
          ageController.text = data["age"]?.toString() ?? "";
          locationController.text = data["location"] ?? "";
          jobTypeController.text = data["job_type"] ?? "";
          healthConditionsController.text = data["health_conditions"] ?? "";
        });
      }
    } catch (e) {
      showError("Error loading profile: $e");
    }
  }

  Future<void> loadProfileCompletion() async {
    try {
      String username = usernameController.text.trim();
      if (username.isEmpty) {
        print("Skipping profile completion fetch: Username is empty");
        return;
      }

      int completion = await ProfileService.fetchProfileCompletion(username);
      if (mounted) {
        setState(() => profileCompletion = completion);
      }
    } catch (e) {
      print("Error fetching profile completion: $e");
    }
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() => _image = File(pickedFile.path));
      }
    } catch (e) {
      showError("Error picking image: $e");
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      Map<String, dynamic> updatedData = {
        "username": usernameController.text,
        "age": ageController.text.isNotEmpty
            ? int.tryParse(ageController.text) ?? 0
            : null,
        "location": locationController.text,
        "job_type": jobTypeController.text,
        "health_conditions": healthConditionsController.text,
      };

      await ProfileService.updateProfile(updatedData);
      if (_image != null) {
        await ProfileService.uploadProfilePicture(_image!.path);
      }

      showSuccess("Profile updated successfully!");
      loadProfile();
      loadProfileCompletion();
    } catch (e) {
      showError("Error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updatePassword() async {
    String username = usernameController.text.trim();
    
    if (username.isEmpty) {
      showError("Error: Username is empty. Reload the profile.");
      return;
    }

    if (passwordController.text.isEmpty || confirmPasswordController.text.isEmpty) {
      showError("Error: Password fields cannot be empty.");
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      showError("Passwords do not match!");
      return;
    }

    try {
      await ProfileService.updatePassword(username, passwordController.text);
      showSuccess("Password updated!");
    } catch (e) {
      showError("Error updating password: $e");
    }
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _opacity,
      duration: Duration(milliseconds: 500),
      child: Scaffold(
        appBar: AppBar(title: Text("Profile")),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: _image != null
                      ? FileImage(_image!)
                      : (profileData["profile_picture"]?.isNotEmpty ?? false)
                          ? NetworkImage(profileData["profile_picture"])
                          : AssetImage('assets/default_profile.png') as ImageProvider,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton.icon(
                      icon: Icon(Icons.camera_alt, color: Colors.blue),
                      label: Text("Change Picture", style: TextStyle(color: Colors.blue)),
                      onPressed: _pickImage,
                    ),
                    TextButton.icon(
                      icon: Icon(Icons.delete, color: Colors.red),
                      label: Text("Remove Picture", style: TextStyle(color: Colors.red)),
                      onPressed: () async {
                        setState(() {
                          _image = null;
                          profileData["profile_picture"] = "";
                        });
                        await ProfileService.updateProfile({"profile_picture": ""});
                      },
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Text("Profile Completion", style: TextStyle(fontSize: 18)),
                LinearProgressIndicator(value: profileCompletion / 100),
                Text("$profileCompletion% completed"),
                SizedBox(height: 20),
                Text("Change Password", style: TextStyle(fontSize: 18)),
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(labelText: "New Password"),
                ),
                TextFormField(
                  controller: confirmPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(labelText: "Confirm New Password"),
                ),
                ElevatedButton(
                  onPressed: _isLoading ? null : _updateProfile,
                  child: Text("Save Profile Changes"),
                ),
                ElevatedButton(
                  onPressed: _isLoading ? null : _updatePassword,
                  child: Text("Update Password"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
