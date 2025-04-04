import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
    setState(() => isLoading = true);

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
      appBar: AppBar(
        title: Text(
          "Health Insights",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        backgroundColor: Colors.pinkAccent,
        centerTitle: true,
        elevation: 5,
      ),
      body: AnimatedContainer(
        duration: Duration(milliseconds: 600),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.pink.shade200, Colors.pink.shade50],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: isLoading
              ? TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.5, end: 1.0),
                  duration: Duration(seconds: 1),
                  builder: (context, scale, child) {
                    return Transform.scale(
                      scale: scale,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.pinkAccent),
                        strokeWidth: 6,
                      ),
                    );
                  },
                )
              : hasError
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          recommendation ?? "An error occurred.",
                          style: GoogleFonts.poppins(
                            color: Colors.red,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 20),
                        _animatedButton(
                          text: "Retry",
                          onTap: fetchHealthRecommendations,
                        ),
                      ],
                    )
                  : Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        recommendation ?? "No data available",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.pink.shade900,
                        ),
                      ),
                    ),
        ),
      ),
    );
  }

  /// **Animated Pink Button**
  Widget _animatedButton({required String text, required VoidCallback onTap}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.8, end: 1.0),
      duration: Duration(milliseconds: 500),
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pinkAccent,
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              elevation: 5,
            ),
            child: Text(
              text,
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
            ),
          ),
        );
      },
    );
  }
}
