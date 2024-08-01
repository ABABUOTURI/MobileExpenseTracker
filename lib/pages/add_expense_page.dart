import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:expense_legend/pages/ChartsPage.dart';
import 'package:expense_legend/pages/DashboardPage.dart';
import 'package:expense_legend/pages/notification_page.dart';
import 'package:expense_legend/pages/profile_page.dart';

class AddExpensePage extends StatefulWidget {
  @override
  _AddExpensePageState createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  TextEditingController amountController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController categoryController = TextEditingController();
  int _pageIndex = 1; // Assuming BudgetPage is index 1

  @override
  void initState() {
    super.initState();
  }

  void saveExpense() async {
    String category = categoryController.text.trim();

    if (amountController.text.isEmpty ||
        category.isEmpty ||
        descriptionController.text.isEmpty) {
      // Show error if any field is empty
      _showErrorDialog('Please fill all fields');
      return;
    }

    double? amount = double.tryParse(amountController.text);
    if (amount == null) {
      // Show error if amount is not a valid number
      _showErrorDialog('Please enter a valid amount');
      return;
    }

    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String userId = user.uid;
      String userEmail = user.email ?? 'No email';

      try {
        await FirebaseFirestore.instance.collection('expenses').add({
          'amount': amount,
          'category': category,
          'description': descriptionController.text,
          'timestamp': FieldValue.serverTimestamp(), // Add server timestamp
          'userId': userId,
          'userEmail': userEmail,
        });

        amountController.clear();
        descriptionController.clear();
        categoryController.clear();

        _showSuccessDialog('Expense added successfully');
      } catch (error) {
        _showErrorDialog('Failed to add expense: $error');
      }
    } else {
      _showErrorDialog('No user logged in');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Success'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
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
          'Add Expense',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF222831),
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: amountController,
              decoration: InputDecoration(
                labelText: 'Amount',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              style: TextStyle(color: Color(0xFFEEEEEE)),
            ),
            SizedBox(height: 12.0),
            TextField(
              controller: categoryController,
              decoration: InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              style: TextStyle(color: Color(0xFFEEEEEE)),
            ),
            SizedBox(height: 12.0),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              style: TextStyle(color: Color(0xFFEEEEEE)),
            ),
            SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: saveExpense,
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
                      amountController.clear();
                      descriptionController.clear();
                      categoryController.clear();
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
      bottomNavigationBar: CurvedNavigationBar(
        index: _pageIndex,
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
          if (index == _pageIndex) return; // Avoid navigating to the same page
          setState(() {
            _pageIndex = index;
          });

          // Handle button tap
          switch (index) {
            case 0:
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => DashboardPage()));
              break;
            case 1:
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => AddExpensePage()));
              break;
            case 2:
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => ChartsPage()));
              break;
            case 3:
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => NotificationsPage()));
              break;
            case 4:
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => ProfilePage()));
              break;
          }
        },
      ),
    );
  }
}

class Category {
  String name;
  String type;

  Category({required this.name, required this.type});
}
