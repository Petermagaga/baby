import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:motherhood_app/screens/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'user_dashboard_screen.dart'; // Your main dashboard UI
import 'dashboard_screen.dart'; // Your home screen UI
import 'notification_screen.dart';

class MainDashboardScreen extends StatefulWidget {
  const MainDashboardScreen({super.key});

  @override
  State<MainDashboardScreen> createState() => _MainDashboardScreenState();
}

class _MainDashboardScreenState extends State<MainDashboardScreen> {
  int _selectedIndex = 0;

  User? user;
  String displayName = "Guest User";
  String email = "No email found";
  String profileImage = "https://via.placeholder.com/150";

  final List<Widget> _screens = [
    HomeScreen(),
    const DashboardScreen(),
    const UserDashboardScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _fetchUser();
    _loadPrefs();
  }

  void _fetchUser() {
    setState(() {
      user = FirebaseAuth.instance.currentUser;
    });
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      displayName = prefs.getString("username") ?? user?.displayName ?? "Guest User";
      email = prefs.getString("email") ?? user?.email ?? "No email found";
      profileImage = prefs.getString("profile_picture") ?? user?.photoURL ?? "https://via.placeholder.com/150";
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildSidebar(context),
      appBar: AppBar(
        title: Text("Bump2Baby, $displayName!"),
        backgroundColor: Colors.redAccent[700],
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationScreen()));
            },
          )
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Dashboard"),
        ],
      ),
    );
  }

  Widget _buildSidebar(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(displayName),
            accountEmail: Text(email),
            currentAccountPicture: CircleAvatar(
              backgroundImage: NetworkImage(profileImage),
            ),
            decoration: BoxDecoration(color: Colors.purpleAccent[700]),
          ),
          _drawerItem(Icons.home, "Home", () {
            setState(() => _selectedIndex = 0);
            Navigator.pop(context);
          }),
          _drawerItem(Icons.dashboard, "Dashboard", () {
            setState(() => _selectedIndex = 1);
            Navigator.pop(context);
          }),
          _drawerItem(Icons.analytics, "Analytics", () {}),
          _drawerItem(Icons.settings, "Settings", () {}),
          const Spacer(),
          _drawerItem(Icons.logout, "Log Out", _logoutUser, isLogout: true),
        ],
      ),
    );
  }

  Widget _drawerItem(IconData icon, String title, VoidCallback onTap, {bool isLogout = false}) {
    return ListTile(
      leading: Icon(icon, color: isLogout ? Colors.red : Colors.black54),
      title: Text(title, style: TextStyle(color: isLogout ? Colors.red : Colors.black)),
      onTap: onTap,
    );
  }

  void _logoutUser() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushReplacementNamed(context, "/login");
    }
  }
}
