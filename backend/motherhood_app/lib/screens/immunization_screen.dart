import 'package:flutter/material.dart';
import 'package:motherhood_app/services/immunization_service.dart'; // Update path as needed

class ImmunizationScreen extends StatefulWidget {
  @override
  _ImmunizationScreenState createState() => _ImmunizationScreenState();
}

class _ImmunizationScreenState extends State<ImmunizationScreen> with TickerProviderStateMixin {
  final ImmunizationService immunizationService = ImmunizationService();

  List<Map<String, String>> immunizationSchedule = [
    {"age": "At birth", "vaccine": "BCG, Hepatitis B"},
    {"age": "6 weeks", "vaccine": "DTP, Polio, Rotavirus"},
    {"age": "10 weeks", "vaccine": "DTP, Polio, Rotavirus"},
    {"age": "14 weeks", "vaccine": "DTP, Polio, Hib"},
    {"age": "9 months", "vaccine": "Measles, Yellow Fever"},
  ];

  List<Map<String, dynamic>> immunizationRecords = [];
  bool isLoading = true;
  String errorMessage = '';

  late AnimationController _controller;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    loadImmunizationRecords();
  }

  Future<void> loadImmunizationRecords() async {
    try {
      List<Map<String, dynamic>> records = await immunizationService.fetchImmunizationRecords();
      setState(() {
        immunizationRecords = records;
        isLoading = false;
      });
      _controller.forward();
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildScheduleCard(String age, String vaccine) {
    return AnimatedBuilder(
      animation: _fadeIn,
      builder: (context, child) => Opacity(
        opacity: _fadeIn.value,
        child: Transform.translate(
          offset: Offset(0, 20 * (1 - _fadeIn.value)),
          child: child,
        ),
      ),
      child: Card(
        color: Colors.pink.shade50,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: ListTile(
          leading: const Icon(Icons.vaccines, color: Colors.pink),
          title: Text(age, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.pinkAccent)),
          subtitle: Text(vaccine),
          trailing: const Icon(Icons.schedule, color: Colors.pinkAccent),
        ),
      ),
    );
  }

  Widget _buildRecordCard(Map<String, dynamic> record) {
    return AnimatedBuilder(
      animation: _fadeIn,
      builder: (context, child) => Opacity(
        opacity: _fadeIn.value,
        child: Transform.translate(
          offset: Offset(0, 20 * (1 - _fadeIn.value)),
          child: child,
        ),
      ),
      child: Card(
        color: Colors.pink.shade100.withOpacity(0.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: ListTile(
          leading: const Icon(Icons.check_circle, color: Colors.green),
          title: Text(record['vaccine_name'], style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text("Given on: ${record['date_given']}"),
          trailing: record['next_due_date'] != null
              ? Text("Next: ${record['next_due_date']}", style: const TextStyle(color: Colors.deepOrange))
              : const Icon(Icons.verified, color: Colors.green),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink.shade50,
      appBar: AppBar(
        backgroundColor: Colors.pink.shade300,
        title: const Text("💉 Immunization Schedule"),
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.pinkAccent))
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage, style: const TextStyle(color: Colors.red)))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "📌 Scheduled Immunizations",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.pink),
                      ),
                      const SizedBox(height: 10),
                      ...immunizationSchedule.map((item) => _buildScheduleCard(item["age"]!, item["vaccine"]!)).toList(),

                      const SizedBox(height: 20),
                      const Divider(thickness: 1.2),
                      const SizedBox(height: 10),

                      const Text(
                        "🩺 Received Immunizations",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.pink),
                      ),
                      const SizedBox(height: 10),
                      ...immunizationRecords.map((record) => _buildRecordCard(record)).toList(),
                    ],
                  ),
                ),
    );
  }
}
