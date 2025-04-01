import 'package:flutter/material.dart';
import '../../core/ProfileService.dart';
import '../../models/user_profile.dart';

class ProfileSetupScreen extends StatefulWidget {
  @override
  _ProfileSetupScreenState createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _healthController = TextEditingController();
  final _locationController = TextEditingController();
  final _jobController = TextEditingController();
  final _pregnancyDateController = TextEditingController();
  bool _loading = false;

  void _saveProfile() async {
    setState(() => _loading = true);

    UserProfile profile = UserProfile(
      name: _nameController.text.trim(),
      age: int.parse(_ageController.text.trim()),
      healthConditions: _healthController.text.trim(),
      location: _locationController.text.trim(),
      job: _jobController.text.trim(),
      pregnancyStartDate: _pregnancyDateController.text.trim(),
    );

    bool success = await ProfileService().saveUserProfile(profile);
    setState(() => _loading = false);

    if (success) {
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Profile setup failed! Try again.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Profile Setup")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: _nameController, decoration: InputDecoration(labelText: 'Full Name')),
              TextField(controller: _ageController, decoration: InputDecoration(labelText: 'Age'), keyboardType: TextInputType.number),
              TextField(controller: _healthController, decoration: InputDecoration(labelText: 'Health Conditions')),
              TextField(controller: _locationController, decoration: InputDecoration(labelText: 'Location')),
              TextField(controller: _jobController, decoration: InputDecoration(labelText: 'Occupation')),
              TextField(controller: _pregnancyDateController, decoration: InputDecoration(labelText: 'Pregnancy Start Date')),
              SizedBox(height: 20),
              _loading
                  ? CircularProgressIndicator()
                  : ElevatedButton(onPressed: _saveProfile, child: Text("Save Profile")),
            ],
          ),
        ),
      ),
    );
  }
}

