import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  User? user;

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((User? updatedUser) {
      setState(() {
        user = updatedUser;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purpleAccent[200],
      drawer: _buildSidebar(),
      appBar: AppBar(
        title: Text("Welcome back, ${user?.displayName ?? "User"}!"),
        backgroundColor: const Color.fromARGB(255, 159, 76, 165),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMainStatsCard(),
            const SizedBox(height: 20),
            Expanded(
              child: Row(
                children: [
                  Expanded(child: _buildCircularProgressStats()),
                  const SizedBox(width: 20),
                  Expanded(child: _buildRankingTable()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebar() {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(user?.displayName ?? "Guest User"),
            accountEmail: Text(user?.email ?? "No email found"),
            currentAccountPicture: CircleAvatar(
              backgroundImage: NetworkImage(user?.photoURL ?? "https://via.placeholder.com/150"),
            ),
            decoration: const BoxDecoration(color: Color.fromARGB(255, 222, 180, 15)),
          ),
          _buildDrawerItem(Icons.dashboard, "Dashboard"),
          _buildDrawerItem(Icons.analytics, "Analytics"),
          _buildDrawerItem(Icons.settings, "Settings"),
          const Spacer(),
          _buildDrawerItem(Icons.logout, "Log Out", isLogout: true),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, {bool isLogout = false}) {
    return ListTile(
      leading: Icon(icon, color: isLogout ? Colors.red : Colors.black54),
      title: Text(title, style: TextStyle(color: isLogout ? Colors.red : Colors.black)),
      onTap: () async {
        if (isLogout) {
          await FirebaseAuth.instance.signOut();
          if (mounted) {
            Navigator.pushReplacementNamed(context, "/login");
          }
        }
      },
    );
  }

  Widget _buildMainStatsCard() {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Dashboard Overview", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _buildLineChart(),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatTile("Orders", "4,321", Colors.green),
                _buildStatTile("Revenue", "\$12,500", Colors.blue),
                _buildStatTile("Visitors", "15.2%", Colors.orange),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLineChart() {
    return SizedBox(
      height: 150,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(show: true),
          borderData: FlBorderData(show: true),
          lineBarsData: [
            LineChartBarData(
              spots: const [
                FlSpot(1, 1),
                FlSpot(2, 3),
                FlSpot(3, 2.5),
                FlSpot(4, 4),
                FlSpot(5, 3.8),
              ],
              isCurved: true,
              gradient: const LinearGradient(colors: [Colors.green, Colors.blue]),
              barWidth: 4,
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [Colors.green.withOpacity(0.3), Colors.blue.withOpacity(0.3)],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatTile(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 14)),
      ],
    );
  }

  Widget _buildCircularProgressStats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Top Indicators", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildCircularStat(45, "Conversion"),
            _buildCircularStat(30, "Engagement"),
          ],
        ),
      ],
    );
  }

  Widget _buildCircularStat(double percentage, String label) {
    return Column(
      children: [
        SizedBox(
          width: 80,
          height: 80,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CircularProgressIndicator(
                value: percentage / 100,
                strokeWidth: 8,
                backgroundColor: Colors.grey[300],
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
              Center(child: Text("$percentage%", style: const TextStyle(fontWeight: FontWeight.bold))),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 14)),
      ],
    );
  }

  Widget _buildRankingTable() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Top Rankings", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            DataTable(
              columns: const [
                DataColumn(label: Text("Name")),
                DataColumn(label: Text("Score")),
              ],
              rows: [
                _buildDataRow("User A", "98"),
                _buildDataRow("User B", "85"),
                _buildDataRow("User C", "79"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  DataRow _buildDataRow(String name, String score) {
    return DataRow(cells: [DataCell(Text(name)), DataCell(Text(score))]);
  }
}
