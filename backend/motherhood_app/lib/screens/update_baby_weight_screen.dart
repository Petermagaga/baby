import 'package:flutter/material.dart';

class UpdateBabyWeightScreen extends StatefulWidget {
  @override
  _UpdateBabyWeightScreenState createState() => _UpdateBabyWeightScreenState();
}

class _UpdateBabyWeightScreenState extends State<UpdateBabyWeightScreen> {
  final TextEditingController weightController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Update Baby Weight")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: weightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: "Enter Baby's Weight (kg)"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                double newWeight = double.tryParse(weightController.text) ?? 0.0;
                if (newWeight > 0) {
                  // Save weight data (later to be connected with the backend)
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Baby weight updated successfully!")),
                  );
                  Navigator.pop(context);
                }
              },
              child: Text("Save"),
            ),
          ],
        ),
      ),
    );
  }
}
