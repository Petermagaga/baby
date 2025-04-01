import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HealthInsightsScreen extends StatefulWidget {
  @override
  _HealthInsightsScreenState createState() => _HealthInsightsScreenState();
}

class _HealthInsightsScreenState extends State<HealthInsightsScreen> {
  String? recommendation;
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    fetchHealthRecommendations();
  }

  Future<void> fetchHealthRecommendations() async {
    try {
      final response = await http.get(
        Uri.parse("http://127.0.0.1:8000/api/health_insights/recommendations/"),
      );

      if (response.statusCode == 200) {
        List<dynamic> recommendations = jsonDecode(response.body);
        setState(() {
          recommendation = recommendations.isNotEmpty
              ? recommendations.first["recommendation_text"]
              : "No recommendations available.";
          isLoading = false;
          hasError = false;
        });
      } else {
        setState(() {
          recommendation = "Failed to load recommendations.";
          isLoading = false;
          hasError = true;
        });
      }
    } catch (e) {
      setState(() {
        recommendation = "Error fetching data.";
        isLoading = false;
        hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Health Insights")),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : hasError
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        recommendation ?? "An error occurred.",
                        style: TextStyle(color: Colors.red, fontSize: 16),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: fetchHealthRecommendations,
                        child: const Text("Retry"),
                      ),
                    ],
                  )
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      recommendation ?? "No data available",
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
      ),
    );
  }
}
