import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:expense_legend/pages/ChartsPage.dart';
import 'package:expense_legend/pages/DashboardPage.dart';
import 'package:expense_legend/pages/budget_page.dart';
import 'package:expense_legend/pages/profile_page.dart';

class NotificationsPage extends StatefulWidget {
  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final List<NotificationModel> _notifications = [];
  int _pageIndex = 3;

  @override
  void initState() {
    super.initState();
    calculateExpenseSummary(); // Initial calculation
  }

  void calculateExpenseSummary() {
    // Replace with your actual logic to calculate expense summaries
    double totalExpensesThisMonth = 1501; // Example total expenses
    double budgetThreshold = 1000; // Example budget threshold

    if (totalExpensesThisMonth > budgetThreshold) {
      setState(() {
        _notifications.add(NotificationModel(
          title: 'Budget Limit Exceeded',
          description:
              'You have exceeded your monthly budget limit of Ksh. ${budgetThreshold.toStringAsFixed(2)}.',
          time: DateTime.now(),
        ));
      });
    }

    setState(() {
      _notifications.add(NotificationModel(
        title: 'Expense Summary',
        description:
            'You have spent Ksh. ${totalExpensesThisMonth.toStringAsFixed(2)} in total.',
        time: DateTime.now(),
      ));
    });
  }

  void _onNavBarTapped(int index) {
    if (_pageIndex != index) {
      setState(() {
        _pageIndex = index;
      });
      switch (index) {
        case 0:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => DashboardPage()),
          );
          break;
        case 1:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => BudgetPage()),
          );
          break;
        case 2:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => ChartsPage()),
          );
          break;
        case 3:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => NotificationsPage()),
          );
          break;
        case 4:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => ProfilePage()),
          );
          break;
      }
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
          'Notifications',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF222831), // Matching color with BudgetPage
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
        padding: EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: _notifications.length,
          itemBuilder: (context, index) {
            return Card(
              color: Color(0xFF393E46), // Match card color
              child: ListTile(
                title: Text(
                  _notifications[index].title,
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  _notifications[index].description,
                  style: TextStyle(color: Colors.white),
                ),
                trailing: Text(
                  DateFormat('yMMMd')
                      .add_jm()
                      .format(_notifications[index].time),
                  style: TextStyle(color: Colors.white),
                ),
              ),
            );
          },
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
        onTap: _onNavBarTapped,
      ),
    );
  }
}

class NotificationModel {
  final String title;
  final String description;
  final DateTime time;

  NotificationModel({
    required this.title,
    required this.description,
    required this.time,
  });
}
