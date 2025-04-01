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
  Map<String, dynamic> profileData = {
    "username": "",
    "age": "",
    "location": "",
    "job_type": "",
    "health_conditions": "",
    "profile_picture": "",
  };

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
        setState(() {
          _opacity = 1.0;
        });
      }
    });
    loadProfile();
    loadProfileCompletion();
  }

  /// **Load Profile Data**
  Future<void> loadProfile() async {
    try {
      Map<String, dynamic> data = await ProfileService.fetchProfile();
      if (data.isNotEmpty && mounted) {
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error loading profile: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  /// **Load Profile Completion Percentage**
  Future<void> loadProfileCompletion() async {
    try {
      int completion = await ProfileService.fetchProfileCompletion();
      if (mounted) {
        setState(() {
          profileCompletion = completion;
        });
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  /// **Pick Image for Profile Picture**
  Future<void> _pickImage() async {
    try {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error picking image: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  /// **Update Profile**
  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      Map<String, dynamic> updatedData = {
        "username": usernameController.text,
        "age": ageController.text.isNotEmpty ? int.tryParse(ageController.text) ?? 0 : null,
        "location": locationController.text,
        "job_type": jobTypeController.text,
        "health_conditions": healthConditionsController.text,
      };

      await ProfileService.updateProfile(updatedData);
      if (_image != null) {
        await ProfileService.uploadProfilePicture(_image!.path);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Profile updated successfully!"), backgroundColor: Colors.green),
        );
        loadProfile();
        loadProfileCompletion();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// **Update Password**
  Future<void> _updatePassword() async {
    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Passwords do not match!"), backgroundColor: Colors.red),
      );
      return;
    }

    try {
      await ProfileService.updatePassword(passwordController.text);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Password updated!"), backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }
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
                /// **Profile Picture**
                CircleAvatar(
                  radius: 50,
                  backgroundImage: _image != null
                      ? FileImage(_image!)
                      : (profileData["profile_picture"]?.isNotEmpty ?? false)
                          ? NetworkImage(profileData["profile_picture"])
                          : AssetImage('assets/default_profile.png') as ImageProvider,
                  onBackgroundImageError: (_, __) {
                    if (mounted) {
                      setState(() {
                        profileData["profile_picture"] = "";
                      });
                    }
                  },
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

                /// **Profile Completion Progress Bar**
                Text("Profile Completion", style: TextStyle(fontSize: 18)),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: LinearProgressIndicator(
                    value: profileCompletion / 100,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                ),
                Text("$profileCompletion% completed", style: TextStyle(fontSize: 16)),

                /// **Save Profile Updates**
                ElevatedButton(
                  onPressed: _isLoading ? null : _updateProfile,
                  child: _isLoading ? CircularProgressIndicator(color: Colors.white) : Text("Save Changes"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
