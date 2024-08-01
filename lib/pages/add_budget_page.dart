import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:expense_legend/models/notification.dart'; // Import NotificationModel
import '../models/budget.dart'; // Import Budget and CategoryBudget models

class AddBudgetPage extends StatefulWidget {
  final Function(Budget) onSave;

  const AddBudgetPage({required this.onSave});

  @override
  _AddBudgetPageState createState() => _AddBudgetPageState();
}

class _AddBudgetPageState extends State<AddBudgetPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _monthlyBudgetController =
      TextEditingController();
  List<CategoryBudget> _categoryBudgets = [];
  List<NotificationModel> _notifications = []; // Initialize _notifications list
  final List<String> _categories = [
    'Food',
    'Transport',
    'Entertainment',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    _categoryBudgets = _categories
        .map((category) => CategoryBudget(category: category, amount: 0))
        .toList();
  }

  void _saveBudget() async {
    if (_formKey.currentState!.validate()) {
      double monthlyBudget =
          double.tryParse(_monthlyBudgetController.text) ?? 0;
      Budget newBudget = Budget(
        monthlyBudget: monthlyBudget,
        categoryBudgets: _categoryBudgets,
      );

      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String userId = user.uid;
        String email = user.email ?? '';

        // Save budget to Firestore
        await FirebaseFirestore.instance.collection('budgets').add({
          'userId': userId,
          'email': email,
          'monthlyBudget': monthlyBudget,
          'categoryBudgets': _categoryBudgets
              .map((cb) => {'category': cb.category, 'amount': cb.amount})
              .toList(),
        });

        // Notify user about new budget
        _notifications.add(NotificationModel(
          title: 'New Budget Added',
          description:
              'Your new monthly budget of $monthlyBudget Ksh has been successfully added.',
          time: DateTime.now(),
        ));

        // Call onSave callback to update parent widget
        widget.onSave(newBudget);

        // Navigate back
        Navigator.pop(context);
      } else {
        // Handle the case where user is not logged in
        print('No user logged in');
      }
    }
  }

  void _cancel() {
    Navigator.pop(context);
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
          'Add Your Budget',
          style: TextStyle(color: Color(0xFFEEEEEE)),
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: <Widget>[
                // Redesigned TextFormField for Monthly Budget
                TextFormField(
                  controller: _monthlyBudgetController,
                  decoration: InputDecoration(
                    labelText: 'Monthly Budget',
                    labelStyle: TextStyle(color: Color(0xFFEEEEEE)),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFEEEEEE)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFEEEEEE)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFEEEEEE)),
                    ),
                    fillColor: Color(0xFF393E46),
                    filled: true,
                  ),
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: Color(0xFFEEEEEE)), // Set text color
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter a monthly budget';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20), // Add spacing between fields

                const Text(
                  'Category Budgets',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFEEEEEE)),
                ),
                SizedBox(height: 20), // Add spacing between title and fields

                // Add SizedBox between each category budget TextFormField
                ..._categoryBudgets.map((categoryBudget) {
                  return Column(
                    children: [
                      TextFormField(
                        initialValue: categoryBudget.amount.toString(),
                        decoration: InputDecoration(
                          labelText: categoryBudget.category,
                          labelStyle: TextStyle(color: Color(0xFFEEEEEE)),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFFEEEEEE)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFFEEEEEE)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFFEEEEEE)),
                          ),
                          fillColor: Color(0xFF393E46),
                          filled: true,
                        ),
                        keyboardType: TextInputType.number,
                        style: TextStyle(
                            color: Color(0xFFEEEEEE)), // Set text color
                        onChanged: (value) {
                          setState(() {
                            categoryBudget.amount = double.tryParse(value) ?? 0;
                          });
                        },
                      ),
                      SizedBox(height: 20), // Add spacing between fields
                    ],
                  );
                }).toList(),

                SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    ElevatedButton(
                      onPressed: _saveBudget,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Color(0xFF222831), // Set button background color
                      ),
                      child: Text(
                        'Save',
                        style: TextStyle(
                            color: Color(0xFFEEEEEE)), // Set text color
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _cancel,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Color(0xFF222831), // Set button background color
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                            color: Color(0xFFEEEEEE)), // Set text color
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
