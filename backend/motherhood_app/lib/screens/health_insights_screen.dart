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
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Health Insights & Journal",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        backgroundColor: Colors.pinkAccent,
        centerTitle: true,
        elevation: 5,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isWideScreen = constraints.maxWidth > 600;

          return isWideScreen
              ? Row(
                  children: [
                    Expanded(child: _buildRecommendationSection()),
                    Expanded(child: JournalSection()),
                  ],
                )
              : Column(
                  children: [
                    Expanded(child: _buildRecommendationSection()),
                    Divider(height: 1),
                    Expanded(child: JournalSection()),
                  ],
                );
        },
      ),
    );
  }

  Widget _buildRecommendationSection() {
    return AnimatedContainer(
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
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.pinkAccent),
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
    );
  }
}
class JournalSection extends StatefulWidget {
  @override
  _JournalSectionState createState() => _JournalSectionState();
}

class _JournalSectionState extends State<JournalSection> {
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  List<Map<String, dynamic>> _entries = [];
  List<Map<String, dynamic>> _filteredEntries = [];

  @override
  void initState() {
    super.initState();
    fetchJournalEntries();
    _searchController.addListener(_filterEntries);
  }

  Future<void> fetchJournalEntries() async {
    try {
      final response = await http.get(
        Uri.parse("http://127.0.0.1:8000/api/journal/entries/"),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _entries = data.reversed.toList().cast<Map<String, dynamic>>();
          _filterEntries();
        });
      }
    } catch (e) {
      // Handle error silently for now
    }
  }

  void _filterEntries() {
    final searchQuery = _searchController.text.toLowerCase();
    final selectedDateStr = _selectedDate.toIso8601String().substring(0, 10);

    setState(() {
      _filteredEntries = _entries.where((entry) {
        final text = entry["entry"]?.toString().toLowerCase() ?? '';
        final date = entry["date"]?.toString().substring(0, 10) ?? '';
        return text.contains(searchQuery) && date == selectedDateStr;
      }).toList();
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _filterEntries();
      });
    }
  }

  Future<void> saveJournalEntry() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    try {
      final response = await http.post(
        Uri.parse("http://127.0.0.1:8000/api/journal/entries/"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "entry": text,
          "date": DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 201) {
        _controller.clear();
        await fetchJournalEntries();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Entry saved!")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving journal.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate =
        "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}";

    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Journal for $formattedDate",
            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: _pickDate,
                icon: Icon(Icons.calendar_today),
                label: Text("Pick Date"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pinkAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: "Search entries...",
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          TextField(
            controller: _controller,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: "Write your journal entry...",
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: saveJournalEntry,
              icon: Icon(Icons.save),
              label: Text("Save"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pinkAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Divider(),
          Expanded(
            child: _filteredEntries.isEmpty
                ? Center(child: Text("No entries found."))
                : ListView.builder(
                    itemCount: _filteredEntries.length,
                    itemBuilder: (context, index) {
                      final entry = _filteredEntries[index];
                      return Card(
                        elevation: 3,
                        margin: EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          title: Text(entry["entry"]),
                          subtitle: Text(entry["date"] ?? ""),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
