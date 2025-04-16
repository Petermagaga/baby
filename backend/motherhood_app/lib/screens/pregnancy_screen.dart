import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:motherhood_app/services/pregnancy_service.dart';
import 'package:motherhood_app/models/Pregnancy_model.dart';

class PregnancyScreen extends StatefulWidget {
  @override
  _PregnancyScreenState createState() => _PregnancyScreenState();
}

class _PregnancyScreenState extends State<PregnancyScreen> {
  final _formKey = GlobalKey<FormState>();
  final weeksController = TextEditingController();
  DateTime? selectedDate;
  Pregnancy? pregnancyData;
  List<dynamic> nutritionList = [];
  List<Map<String, dynamic>> clinicalMilestones = [];
  int? countdown;
  int? trimester;

  

  final PregnancyService _pregnancyService = PregnancyService();

  @override
  void initState() {
    super.initState();
    fetchPregnancyInfo();
  }

  Future<void> fetchPregnancyInfo() async {
    final data = await _pregnancyService.fetchPregnancy();
    if (data != null) {
      setState(() {
        pregnancyData = data;
        trimester = data.trimester;
      });

      await fetchNutrition(trimester.toString());

      final startDate = data.startDate;
      calculateClinicalMilestones(startDate);

      final dueDate = startDate.add(Duration(days: 280));
      setState(() {
        countdown = dueDate.difference(DateTime.now()).inDays;
      });
    }
  }

  Future<void> fetchNutrition(String trimester) async {
    }
  

  void calculateClinicalMilestones(DateTime startDate) {
    clinicalMilestones = [
      {
        'label': 'First Trimester Screening',
        'date': startDate.add(Duration(days: 20 * 12)),
        'description': 'Check for chromosomal conditions and overall health.'
      },
      {
        'label': 'Anatomy Scan',
        'date': startDate.add(Duration(days: 20 * 7)),
        'description': 'Detailed ultrasound to examine baby’s organs and growth.'
      },
      {
        'label': 'Glucose Screening',
        'date': startDate.add(Duration(days: 20 * 24)),
        'description': 'Test for gestational diabetes.'
      },
      {
        'label': 'Due Date',
        'date': startDate.add(Duration(days: 280)),
        'description': 'Expected delivery date.'
      },
    ];
  }

  Future<void> savePregnancy() async {
    DateTime? calculatedDate;

    if (selectedDate != null) {
      calculatedDate = selectedDate!;
    } else if (weeksController.text.isNotEmpty) {
      int weeks = int.tryParse(weeksController.text) ?? 0;
      calculatedDate = DateTime.now().subtract(Duration(days: weeks * 7));
    }

    if (calculatedDate != null) {
      final success = await _pregnancyService.createPregnancy(startDate: calculatedDate);
      if (success) {
        fetchPregnancyInfo();
      }
    }
  }

  Future<void> deletePregnancy() async {
    final success = await _pregnancyService.deletePregnancy();
    if (success) {
      setState(() {
        pregnancyData = null;
        countdown = null;
        trimester = null;
        nutritionList = [];
        clinicalMilestones = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Pregnancy Tracker")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: pregnancyData == null
            ? Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Enter pregnancy start date or weeks pregnant:"),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: weeksController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Weeks Pregnant",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) {
                          setState(() {
                            selectedDate = date;
                          });
                        }
                      },
                      child: Text(selectedDate == null
                          ? "Pick Pregnancy Start Date"
                          : "Selected: ${DateFormat.yMMMd().format(selectedDate!)}"),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: savePregnancy,
                      child: Text("Save"),
                    )
                  ],
                ),
              )
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Trimester: ${pregnancyData?.trimester}",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text("Due Date: ${pregnancyData?.dueDate}"),
                    Text("Days Left: $countdown"),
                    SizedBox(height: 10),
                    LinearProgressIndicator(
                      value: (280 - (countdown ?? 280)) / 280,
                      minHeight: 10,
                    ),
                    SizedBox(height: 20),
                    Text("Daily Recommendations",
                        style:
                            TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ...nutritionList.map((item) => Card(
                          margin: EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            title: Text(item['title'] ?? ''),
                            subtitle: Text(item['description'] ?? ''),
                          ),
                        )),
                    SizedBox(height: 20),
                    Text("Clinical Milestones",
                        style:
                            TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ...clinicalMilestones.map((milestone) => ListTile(
                          leading: Icon(Icons.calendar_today),
                          title: Text(milestone['label']),
                          subtitle: Text(
                              "${DateFormat.yMMMd().format(milestone['date'])} - ${milestone['description']}"),
                        )),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: deletePregnancy,
                      style:
                          ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: Text("Reset Pregnancy"),
                    )
                  ],
                ),
              ),
      ),
    );
  }
}
