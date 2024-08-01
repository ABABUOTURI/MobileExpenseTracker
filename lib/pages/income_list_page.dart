import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:expense_legend/pages/ChartsPage.dart';
import 'package:expense_legend/pages/DashboardPage.dart';
import 'package:expense_legend/pages/budget_page.dart';
import 'package:expense_legend/pages/notification_page.dart';
import 'package:expense_legend/pages/profile_page.dart';

class IncomeListPage extends StatefulWidget {
  @override
  _IncomeListPageState createState() => _IncomeListPageState();
}

class _IncomeListPageState extends State<IncomeListPage> {
  String selectedFilterSource = 'All';
  DateTime selectedFilterDate = DateTime.now();

  Stream<QuerySnapshot> getIncomesStream() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      print('User ID: ${user.uid}'); // Debugging line
      return FirebaseFirestore.instance
          .collection('incomes')
          .orderBy('timestamp', descending: true)
          .snapshots();
    } else {
      print('No user is logged in'); // Debugging line
      return Stream.empty();
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
        title: Text('Income List'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedFilterSource,
                    onChanged: (newValue) {
                      setState(() {
                        selectedFilterSource = newValue!;
                      });
                    },
                    items: ['All', 'Salary', 'Business', 'Investment', 'Other']
                        .map((source) {
                      return DropdownMenuItem<String>(
                        value: source,
                        child: Text(source),
                      );
                    }).toList(),
                    decoration: InputDecoration(
                      labelText: 'Filter by Source',
                    ),
                  ),
                ),
                SizedBox(width: 10.0),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Filter by Date',
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    readOnly: true,
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: selectedFilterDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          selectedFilterDate = pickedDate;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.0),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: getIncomesStream(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    print('Error: ${snapshot.error}'); // Debugging line
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    print('Loading data...'); // Debugging line
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
                    print('No incomes found'); // Debugging line
                    return Center(child: Text('No incomes found'));
                  }

                  var incomes = snapshot.data!.docs.map((doc) {
                    var data = doc.data() as Map<String, dynamic>;
                    return Income(
                      date:
                          (data['timestamp'] as Timestamp).toDate().toString(),
                      amount: data['amount'],
                      source: data['source'],
                      description: data['description'],
                    );
                  }).toList();

                  return ListView.builder(
                    itemCount: incomes.length,
                    itemBuilder: (context, index) {
                      var income = incomes[index];
                      return Card(
                        child: ListTile(
                          title: Text('${income.date} - ${income.source}'),
                          subtitle:
                              Text('${income.amount} - ${income.description}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () {
                                  // Implement editing logic here
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () {
                                  // Implement deletion logic here
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
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
          switch (index) {
            case 0:
              // Navigate to Home Page
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => DashboardPage()));
              break;
            case 1:
              // Navigate to Add Income Page
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => BudgetPage()));
              break;
            case 2:
              // Navigate to Expense Tracker Page
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ChartsPage()));
              break;
            case 3:
              // Navigate to Notifications Page
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => NotificationsPage()));
              break;
            case 4:
              // Navigate to Settings Page
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ProfilePage()));
              break;
          }
        },
      ),
    );
  }
}

class Income {
  final String date;
  final double amount;
  final String source;
  final String description;

  Income({
    required this.date,
    required this.amount,
    required this.source,
    required this.description,
  });
}
