import 'package:flutter/material.dart';
import '../services/api_service.dart'; // ✅ Import API service

class PregnancyTrackerScreen extends StatefulWidget {
  const PregnancyTrackerScreen({super.key});

  @override
  State<PregnancyTrackerScreen> createState() => _PregnancyTrackerScreenState();
}

class _PregnancyTrackerScreenState extends State<PregnancyTrackerScreen> {
  int currentWeek = 0; // Default pregnancy week
  Map<String, dynamic>? weekData; // Store fetched week data
  List<dynamic> notifications = []; // Store user notifications

  @override
  void initState() {
    super.initState();
    fetchTrackerData();
    fetchNotifications();
  }

  /// ✅ Fetch Pregnancy Data from API
  void fetchTrackerData() async {
    var data = await ApiService.fetchPregnancyData();
    if (mounted) {
      setState(() {
        currentWeek = data?['week'] ?? 1; // Default to week 1
        weekData = data?['details'] ?? {};
      });
    }
  }

  /// ✅ Fetch Notifications
  void fetchNotifications() async {
    var data = await ApiService.fetchNotifications();
    if (mounted) {
      setState(() {
        notifications = (data as List<dynamic>?) ?? [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFCE4EC), // Soft pink background
      appBar: AppBar(
        title: const Text("Pregnancy Tracker"),
        backgroundColor: Color(0xFFE91E63), // Dark pink
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: weekData == null
            ? const Center(child: CircularProgressIndicator()) // Show loader until data loads
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ✅ Progress Indicator
                  Text("Week $currentWeek of 40", 
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  _buildProgressIndicator(),

                  const SizedBox(height: 20),

                  // ✅ Baby's Growth
                  _buildCard(
                    title: "Your Baby's Growth",
                    content: weekData?['baby_growth'] ?? "Baby is growing beautifully!",
                    icon: Icons.child_care,
                  ),

                  // ✅ Mother's Changes
                  _buildCard(
                    title: "Mother's Changes",
                    content: weekData?['mother_changes'] ?? "Expect some body changes this week.",
                    icon: Icons.pregnant_woman,
                  ),

                  // ✅ Health Tips
                  _buildCard(
                    title: "Health Tips",
                    content: weekData?['health_tips'] ?? "Eat healthy and stay hydrated!",
                    icon: Icons.health_and_safety,
                  ),

                  const SizedBox(height: 20),

                  // ✅ Notifications
                  if (notifications.isNotEmpty) _buildNotifications(),
                ],
              ),
      ),
    );
  }

  /// ✅ Progress Indicator (Shows Pregnancy Progress)
  Widget _buildProgressIndicator() {
    return Column(
      children: [
        LinearProgressIndicator(
          value: currentWeek / 40,
          backgroundColor: Colors.pink[100],
          color: Colors.pinkAccent,
          minHeight: 10,
        ),
        const SizedBox(height: 5),
        Text(
          "You're ${((currentWeek / 40) * 100).toStringAsFixed(1)}% through your pregnancy!",
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  /// ✅ Build Information Cards
  Widget _buildCard({required String title, required String content, required IconData icon}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Icon(icon, color: Colors.pink, size: 30),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Text(content, style: TextStyle(color: Colors.black87)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ✅ Display Notifications
  Widget _buildNotifications() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Notifications", 
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.pinkAccent)),
        const SizedBox(height: 5),
        ...notifications.map((notification) => Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 2,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Text(notification['message'], style: TextStyle(color: Colors.black87)),
              ),
            )),
      ],
    );
  }
}
