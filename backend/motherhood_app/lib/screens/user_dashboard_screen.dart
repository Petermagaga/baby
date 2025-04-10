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
          "Welcome back, ${user?.displayName ?? "User"}!",
        ), // ✅ Dynamic User Greeting
        backgroundColor: Colors.green[700],
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
            decoration: BoxDecoration(color: Colors.green[700]),
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

/// Dashboard Content (Separated for Clarity)
class DashboardContent extends StatelessWidget {
  const DashboardContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Dashboard Content Here"));
  }
}
