import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddIncomePage extends StatefulWidget {
  @override
  _AddIncomePageState createState() => _AddIncomePageState();
}

class _AddIncomePageState extends State<AddIncomePage> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final List<String> _sources = ['Salary', 'Business', 'Investment', 'Other'];
  String? _selectedSource;

  @override
  void initState() {
    super.initState();
    _selectedSource = _sources.isNotEmpty
        ? _sources[0]
        : null; // Initialize with the first source if available
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void saveIncome() async {
    if (_amountController.text.isEmpty ||
        _selectedSource == null ||
        _descriptionController.text.isEmpty) {
      // Show error if any field is empty
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Please fill all fields'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    double? amount = double.tryParse(_amountController.text);
    if (amount == null) {
      // Show error if amount is not a valid number
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Please enter a valid amount'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String userId = user.uid;
      String userEmail = user.email ?? 'No email';

      FirebaseFirestore.instance.collection('incomes').add({
        'userId': userId,
        'userEmail': userEmail,
        'amount': amount,
        'source': _selectedSource,
        'description': _descriptionController.text,
        'timestamp': FieldValue.serverTimestamp(), // Add server timestamp
      }).then((value) {
        _amountController.clear();
        _descriptionController.clear();
        setState(() {
          _selectedSource = _sources.isNotEmpty ? _sources[0] : null;
        });

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Success'),
            content: Text('Income added successfully'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          ),
        );
      }).catchError((error) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Error'),
            content: Text('Failed to add income: $error'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          ),
        );
      });
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('No user logged in'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Add Income',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor:
            Color(0xFF222831), // Matching color with AddExpensePage
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF222831),
              Color(0xFF393E46),
              Color(0xFFFD7014),
              Color(0xFFEEEEEE),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: 'Amount',
                  border: OutlineInputBorder(), // Added border
                ),
                keyboardType: TextInputType.number,
                style: TextStyle(color: Color(0xFFEEEEEE)),
              ),
              SizedBox(height: 12.0),
              DropdownButtonFormField<String>(
                value: _selectedSource,
                onChanged: (newValue) {
                  setState(() {
                    _selectedSource = newValue;
                  });
                },
                items: _sources.map((source) {
                  return DropdownMenuItem<String>(
                    value: source,
                    child: Text(source,
                        style: TextStyle(color: Color(0xFFEEEEEE))),
                  );
                }).toList(),
                decoration: InputDecoration(
                  labelText: 'Source',
                  border: OutlineInputBorder(), // Added border
                ),
                style: TextStyle(color: Color(0xFFEEEEEE)),
              ),
              SizedBox(height: 12.0),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(), // Added border
                ),
                style: TextStyle(color: Color(0xFFEEEEEE)),
              ),
              SizedBox(height: 20.0),
              // Arrange buttons in two columns
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: saveIncome,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF222831),
                      ),
                      child: Text(
                        'Save',
                        style: TextStyle(color: Color(0xFFEEEEEE)),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.0),
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        _amountController.clear();
                        _descriptionController.clear();
                        setState(() {
                          _selectedSource =
                              _sources.isNotEmpty ? _sources[0] : null;
                        });
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Color(0xFF222831),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: Color(0xFFEEEEEE)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CurvedNavigationBar(
        height: 60.0,
        items: const [
          Icon(
            Icons.dashboard,
            color: Color(0xFFEEEEEE),
          ),
          Icon(
            Icons.attach_money,
            color: Color(0xFFEEEEEE),
          ),
          Icon(
            Icons.bar_chart,
            color: Color(0xFFEEEEEE),
          ),
          Icon(
            Icons.notification_add,
            color: Color(0xFFEEEEEE),
          ),
          Icon(Icons.settings, color: Color(0xFFEEEEEE)),
        ],
        color: Color(0xFF222831),
        buttonBackgroundColor: Color(0xFFFD7014),
        backgroundColor: Color(0xFF393E46),
        animationCurve: Curves.easeInOut,
        animationDuration: Duration(milliseconds: 300),
        onTap: (index) {
          // Handle button tap
        },
      ),
    );
  }
}
