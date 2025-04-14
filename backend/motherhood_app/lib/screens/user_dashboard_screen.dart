import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'home_screen.dart';
import 'notification_screen.dart';


class UserDashboardScreen extends StatefulWidget {
  const UserDashboardScreen({super.key});

  @override
  _UserDashboardScreenState createState() => _UserDashboardScreenState();
}

class _UserDashboardScreenState extends State<UserDashboardScreen> {
  int _selectedIndex = 0; // To track the selected tab
  User? user; // Firebase user

  @override
  void initState() {
    super.initState();
    _fetchUser();
  }

  void _fetchUser() {
    setState(() {
      user = FirebaseAuth.instance.currentUser;
    });
  }

  final List<Widget> _screens = [
    const HomeScreen(), // Home Page
    const DashboardContent(), // Dashboard Page
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildSidebar(context), // Sidebar with dynamic user data
      appBar: AppBar(
        title: Text(
          "Bump2Baby!",
        ), // ✅ Dynamic User Greeting
        backgroundColor: Colors.redAccent[700],
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: _screens[_selectedIndex], // Show selected screen
      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: "Dashboard",
          ),
        ],
      ),
    );
  }

  /// Sidebar Navigation Menu with User Info
  Widget _buildSidebar(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(
              user?.displayName ?? "Guest User",
            ), // ✅ Dynamic Name
            accountEmail: Text(
              user?.email ?? "No email found",
            ), // ✅ Dynamic Email
            currentAccountPicture: CircleAvatar(
              backgroundImage: NetworkImage(
                user?.photoURL ?? "https://via.placeholder.com/150",
              ),
            ),
            decoration: BoxDecoration(color: Colors.purpleAccent[700]),
          ),
          _buildDrawerItem(Icons.home, "Home", () {
            setState(() {
              _selectedIndex = 0;
              Navigator.pop(context);
            });
          }),
          _buildDrawerItem(Icons.dashboard, "Dashboard", () {
            setState(() {
              _selectedIndex = 1;
              Navigator.pop(context);
            });
          }),
          _buildDrawerItem(Icons.analytics, "Analytics", () {}),
          _buildDrawerItem(Icons.settings, "Settings", () {}),
          const Spacer(),
          _buildDrawerItem(
            Icons.logout,
            "Log Out",
            _logoutUser,
            isLogout: true,
          ),
        ],
      ),
    );
  }

  /// Log Out Function
  void _logoutUser() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(
      context,
      "/login",
    ); // Redirect to login screen
  }

  /// Drawer Item
  Widget _buildDrawerItem(
    IconData icon,
    String title,
    VoidCallback onTap, {
    bool isLogout = false,
  }) {
    return ListTile(
      leading: Icon(icon, color: isLogout ? Colors.red : Colors.black54),
      title: Text(
        title,
        style: TextStyle(color: isLogout ? Colors.red : Colors.black),
      ),
      onTap: onTap,
    );
  }
}

class DashboardContent extends StatelessWidget {
  const DashboardContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _motivationalCard(),
          const SizedBox(height: 16),
          _progressOverview(),
          const SizedBox(height: 16),
          _quickStats(),
          const SizedBox(height: 16),
          _chartCard(),
        ],
      ),
    );
  }

  Widget _motivationalCard() {
    return Card(
      color: Colors.deepPurple[50],
      child: ListTile(
        leading: const Icon(Icons.favorite, color: Colors.pink),
        title: const Text("You’re doing amazing, mama 💪"),
        subtitle: const Text("“Progress, not perfection.”"),
      ),
    );
  }

  Widget _progressOverview() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _circularIndicator("Health", 0.7, Colors.green),
        _circularIndicator("Mood", 0.5, Colors.orange),
        _circularIndicator("Sleep", 0.8, Colors.blue),
      ],
    );
  }

  Widget _circularIndicator(String label, double value, Color color) {
    return Column(
      children: [
        SizedBox(
          width: 80,
          height: 80,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CircularProgressIndicator(
                value: value,
                strokeWidth: 8,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation(color),
              ),
              Center(
                child: Text("${(value * 100).toInt()}%", style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(label),
      ],
    );
  }

  Widget _quickStats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: const [
        _StatTile(label: "Counseling", value: "3"),
        _StatTile(label: "Journals", value: "12"),
        _StatTile(label: "Messages", value: "24"),
      ],
    );
  }

  Widget _chartCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Mood Trend", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            SizedBox(
              height: 150,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(show: true),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: const [
                        FlSpot(1, 2),
                        FlSpot(2, 3),
                        FlSpot(3, 1.5),
                        FlSpot(4, 3.5),
                        FlSpot(5, 4),
                      ],
                      isCurved: true,
                      gradient: const LinearGradient(colors: [Colors.purple, Colors.pink]),
                      barWidth: 4,
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [Colors.purple.withOpacity(0.2), Colors.pink.withOpacity(0.2)],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;

  const _StatTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Text(label),
      ],
    );
  }
}
