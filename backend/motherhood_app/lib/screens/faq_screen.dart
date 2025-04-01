import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FAQScreen extends StatefulWidget {
  @override
  _FAQScreenState createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen> with SingleTickerProviderStateMixin {
  List<dynamic> faqs = [];
  bool isLoading = true;
  String selectedCategory = "Pregnancy";

  @override
  void initState() {
    super.initState();
    fetchFAQs();
  }

  Future<void> fetchFAQs() async {
    setState(() => isLoading = true);

    final response = await http.get(
      Uri.parse('http://127.0.0.1:8000/api/faqs/?category=$selectedCategory'),
    );

    if (response.statusCode == 200) {
      setState(() {
        faqs = json.decode(response.body);
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFCE4EC), // Light pink background
      appBar: AppBar(
        backgroundColor: Color(0xFFE91E63), // Dark pink
        title: Text('Baby FAQs', style: TextStyle(fontFamily: 'Poppins')),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildCategorySelector(),
            SizedBox(height: 10),
            isLoading
                ? Center(child: CircularProgressIndicator())
                : faqs.isEmpty
                    ? Center(child: Text("No FAQs available for this category", style: TextStyle(color: Colors.grey)))
                    : Expanded(child: _buildFAQList()),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySelector() {
    List<String> categories = ["Pregnancy", "Postnatal", "Baby Care", "Nutrition"];

    return Container(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: categories.map((category) {
          bool isSelected = selectedCategory == category;
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedCategory = category;
                fetchFAQs();
              });
            },
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 8),
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? Color(0xFFE91E63) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
              ),
              child: Text(category,
                  style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold)),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFAQList() {
    return ListView.builder(
      itemCount: faqs.length,
      itemBuilder: (context, index) {
        return _buildFAQItem(faqs[index]);
      },
    );
  }

  Widget _buildFAQItem(dynamic faq) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: ExpansionTile(
        leading: Icon(Icons.baby_changing_station, color: Colors.pink),
        title: Text(faq['question'], style: TextStyle(fontWeight: FontWeight.bold)),
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
            ),
            child: Text(faq['answer'], style: TextStyle(color: Colors.black87)),
          ),
        ],
      ),
    );
  }
}
