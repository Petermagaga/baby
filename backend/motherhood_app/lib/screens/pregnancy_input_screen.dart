import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:motherhood_app/services/token_manager.dart';

class PregnancyInputScreen extends StatefulWidget {
  @override
  _PregnancyInputScreenState createState() => _PregnancyInputScreenState();
}

class _PregnancyInputScreenState extends State<PregnancyInputScreen> {
  String _inputMode = 'date'; // 'date' or 'weeks'
  DateTime? _selectedDate;
  TextEditingController _weeksController = TextEditingController();
  bool _isLoading = false;

  // Replace with your actual backend URL.
  // If testing on an Android emulator, you might need to use "http://10.0.2.2:8000/..." instead of 127.0.0.1.
  final String _apiUrl = "http://127.0.0.1:8000/api/pregnancy/create/";

  Future<void> _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(Duration(days: 7 * 5)),
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submit() async {
    setState(() => _isLoading = true);

    DateTime startDate;
    if (_inputMode == 'date' && _selectedDate != null) {
      startDate = _selectedDate!;
    } else if (_inputMode == 'weeks' && _weeksController.text.isNotEmpty) {
      int weeks = int.tryParse(_weeksController.text) ?? 0;
      startDate = DateTime.now().subtract(Duration(days: weeks * 7));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please provide valid input.")),
      );
      setState(() => _isLoading = false);
      return;
    }

    DateTime dueDate = startDate.add(Duration(days: 280));

    // Get a valid token using your TokenManager.
    String? token = await TokenManager.getValidToken();
    print("Token: $token");
    
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Authentication token is missing. Please log in again.")),
      );
      setState(() => _isLoading = false);
      return;
    }

    try {
      var response = await http
          .post(
            Uri.parse(_apiUrl),
            headers: {
              "Content-Type": "application/json",
              "Authorization": "Bearer $token",
            },
            body: jsonEncode({
              "start_date": DateFormat('yyyy-MM-dd').format(startDate),
              "due_date": DateFormat('yyyy-MM-dd').format(dueDate),
            
            
            }),
          )
          .timeout(Duration(seconds: 10));
      if (response.statusCode == 201) {
        Navigator.pushReplacementNamed(context, '/pregnancyDashboard');
      } else {
        print("Failed response: ${response.statusCode} ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(


          SnackBar(content: Text("Failed to save. Try again.")),
        );
      }
    } catch (e) {
      print("Error during submission: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error occurred: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
      
    }
  }

  @override
  void dispose() {
    _weeksController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Start Your Pregnancy Journey")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButton<String>(
              value: _inputMode,
              items: [
                DropdownMenuItem(value: 'date', child: Text("I know the date")),
                DropdownMenuItem(value: 'weeks', child: Text("I know the weeks")),
              ],
              onChanged: (value) {
                setState(() {
                  _inputMode = value!;
                  _weeksController.clear();
                  _selectedDate = null;
                });
              },
            ),
            SizedBox(height: 16),
            if (_inputMode == 'date') ...[
              ElevatedButton(
                onPressed: _pickDate,
                child: Text(_selectedDate == null
                    ? "Pick Conception Date"
                    : "Selected: ${DateFormat.yMMMd().format(_selectedDate!)}"),
              )
            ] else ...[
              TextFormField(
                controller: _weeksController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: "Enter weeks pregnant"),
              ),
            ],
            SizedBox(height: 24),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _submit,
                    child: Text("Save and Continue"),
                  ),
          ],
        ),
      ),
    );
  }
}
