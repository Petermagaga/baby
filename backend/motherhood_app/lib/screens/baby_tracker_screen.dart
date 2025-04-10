import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class BabyTrackerScreen extends StatefulWidget {
  @override
  _BabyTrackerScreenState createState() => _BabyTrackerScreenState();
}

class _BabyTrackerScreenState extends State<BabyTrackerScreen> {
  final String babyName = "Baby Noah";
  final String birthDate = "2024-02-10";
  double babyWeight = 4.2;

  final TextEditingController weightController = TextEditingController();
  bool _showWeightForm = false;

  List<String> _nutritionAdvice = [];
  bool _isLoading = false;
  String _errorMessage = '';
  
  @override
  void initState() {
    super.initState();
    fetchNutritionAdvice();
  }

  Future<void> fetchNutritionAdvice() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("accessToken");

      final response = await http.get(
        Uri.parse("http://127.0.0.1:8000/api/nutrition-guide/?weight=$babyWeight"),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _nutritionAdvice = List<String>.from(data.map((item) => item['advice']));
        });
      } else {
        setState(() {
          _errorMessage = "Failed to fetch nutrition advice. (${response.statusCode})";
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Something went wrong. Check your connection.";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _updateWeight() {
    final newWeight = double.tryParse(weightController.text);

    if (newWeight != null && newWeight > 0) {
      setState(() {
        babyWeight = newWeight;
        _showWeightForm = false;
      });
      fetchNutritionAdvice();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("✅ Baby weight updated to $newWeight kg")),
      );
      weightController.clear();  // Clear the input after successful weight update
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("⚠️ Please enter a valid weight (e.g., 5.4)")),
      );
    }
  }

  Widget _buildNutritionAdviceSection() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    } else if (_errorMessage.isNotEmpty) {
      return Text(_errorMessage, style: TextStyle(color: Colors.red));
    } else if (_nutritionAdvice.isEmpty) {
      return Text("No nutrition advice available for this weight.");
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _nutritionAdvice
            .map((advice) => Card(
                  color: Colors.pink.shade50,
                  margin: EdgeInsets.symmetric(vertical: 6),
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Text(advice, style: TextStyle(fontSize: 15)),
                  ),
                ))
            .toList(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("👶 Baby Tracker"),
        backgroundColor: Colors.pinkAccent,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("👶 Baby Profile", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            _buildInfoRow("Name", babyName),
            _buildInfoRow("Birth Date", birthDate),
            _buildInfoRow("Current Weight", "$babyWeight kg", highlight: true),
            SizedBox(height: 10),

            ElevatedButton.icon(
              icon: Icon(_showWeightForm ? Icons.close : Icons.edit),
              label: Text(_showWeightForm ? "Cancel" : "Update Weight"),
              onPressed: () {
                setState(() => _showWeightForm = !_showWeightForm);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pinkAccent,
              ),
            ),

            if (_showWeightForm) ...[
              SizedBox(height: 10),
              TextField(
                controller: weightController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: "Enter new weight (kg)",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: _updateWeight,
                child: Text("Save"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
              ),
            ],

            Divider(height: 30, color: Colors.pinkAccent),

            Text("🥗 Nutrition Advice", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            _buildNutritionAdviceSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String title, String value, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text("$title: ", style: TextStyle(fontWeight: FontWeight.w600)),
          Text(
            value,
            style: TextStyle(color: highlight ? Colors.pink : Colors.black87),
          ),
        ],
      ),
    );
  }
}
