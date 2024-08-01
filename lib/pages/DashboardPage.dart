import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:expense_legend/pages/ChartsPage.dart';
import 'package:expense_legend/pages/profile_page.dart';
import 'package:expense_legend/pages/add_expense_page.dart';
import 'package:expense_legend/pages/add_income_page.dart';
import 'package:expense_legend/pages/budget_page.dart';
import 'package:expense_legend/pages/notification_page.dart';

class Income {
  final String title;
  final double amount;

  Income({required this.title, required this.amount});

  factory Income.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Income(
      title: data['description'] ?? '',
      amount: data['amount']?.toDouble() ?? 0.0,
    );
  }
}

class Expense {
  final String title;
  final double amount;

  Expense({required this.title, required this.amount});

  factory Expense.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Expense(
      title: data['description'] ?? '',
      amount: data['amount']?.toDouble() ?? 0.0,
    );
  }
}

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  double totalIncome = 0.0;
  double totalExpenses = 0.0;
  double balance = 0.0;

  int _pageIndex = 0;

  List<Income> incomeList = [];
  List<Expense> expenseList = [];

  @override
  void initState() {
    super.initState();
    fetchIncomeData();
    fetchExpenseData();
  }

  void fetchIncomeData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String userId = user.uid;
      FirebaseFirestore.instance
          .collection('incomes')
          .where('userId', isEqualTo: userId)
          .snapshots()
          .listen((snapshot) {
        List<Income> incomes =
            snapshot.docs.map((doc) => Income.fromFirestore(doc)).toList();
        setState(() {
          incomeList = incomes;
          totalIncome = incomes.fold(0.0, (sum, item) => sum + item.amount);
          balance = totalIncome - totalExpenses;
        });
      });
    }
  }

  void fetchExpenseData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String userId = user.uid;
      FirebaseFirestore.instance
          .collection('expenses')
          .where('userId', isEqualTo: userId)
          .snapshots()
          .listen((snapshot) {
        List<Expense> expenses =
            snapshot.docs.map((doc) => Expense.fromFirestore(doc)).toList();
        setState(() {
          expenseList = expenses;
          totalExpenses = expenses.fold(0.0, (sum, item) => sum + item.amount);
          balance = totalIncome - totalExpenses;
        });
        // Check if expense exceeds 500 Ksh interval and send notifications
        _checkAndSendExpenseNotifications();
      });
    }
  }

  void _checkAndSendExpenseNotifications() {
    double currentExpense = totalExpenses;
    double previousExpense = currentExpense - 500;
    if (currentExpense >= 500 && currentExpense >= previousExpense) {
      _sendExpenseNotification(currentExpense);
    }
  }

  void _sendExpenseNotification(double expenseAmount) {
    String notificationMessage = 'You have spent Ksh. $expenseAmount in total.';
    // Replace with your notification logic (e.g., using Firebase Cloud Messaging or local notifications)
    print(notificationMessage); // For demonstration, print to console
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Dashboard',
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
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSummaryCards(),
            SizedBox(height: 20.0),
            _buildActionButtons(screenWidth),
            SizedBox(height: 20.0),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildListsContainer(),
                  ],
                ),
              ),
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
          setState(() {
            _pageIndex = index;
          });
          // Handle button tap
          switch (index) {
            case 0:
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => DashboardPage()));
              break;
            case 1:
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => BudgetPage()));
              break;
            case 2:
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ChartsPage()));
              break;
            case 3:
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => NotificationsPage()));
              break;
            case 4:
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ProfilePage()));
              break;
          }
        },
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildSummaryCard(
            'Total Income', totalIncome.toString(), Color(0xFFFD7014)),
        _buildSummaryCard(
            'Total Expenses', totalExpenses.toString(), Color(0xFF393E46)),
        _buildSummaryCard('Balance', balance.toString(), Color(0xFFFD7014)),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, Color backgroundColor) {
    return Card(
      color: backgroundColor,
      elevation: 2.0,
      child: Padding(
        padding: EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                  fontSize: 10.0,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFEEEEEE)),
            ),
            SizedBox(height: 7.0),
            Text(
              value,
              style: TextStyle(
                  fontSize: 15.0,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFEEEEEE)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(double screenWidth) {
    double buttonWidth = screenWidth > 400 ? 150 : double.infinity;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Container(
          width: buttonWidth,
          child: ElevatedButton(
            onPressed: () async {
              final result = await Navigator.push(context,
                  MaterialPageRoute(builder: (context) => AddIncomePage()));
              if (result != null && result is Income) {
                setState(() {
                  incomeList.add(result);
                  totalIncome += result.amount;
                  balance = totalIncome - totalExpenses;
                });
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF222831),
            ),
            child: const Text(
              'Add Income',
              style: TextStyle(color: Color(0xFFEEEEEE)),
            ),
          ),
        ),
        Container(
          width: buttonWidth,
          child: ElevatedButton(
            onPressed: () async {
              final result = await Navigator.push(context,
                  MaterialPageRoute(builder: (context) => AddExpensePage()));
              if (result != null && result is Expense) {
                setState(() {
                  expenseList.add(result);
                  totalExpenses += result.amount;
                  balance = totalIncome - totalExpenses;
                });
                // Check and send notification after adding expense
                _checkAndSendExpenseNotifications();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF222831),
            ),
            child: Text(
              'Add Expense',
              style: TextStyle(color: Color(0xFFEEEEEE)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildListsContainer() {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Color(0xFF393E46),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Income List',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFD7014),
                ),
              ),
              SizedBox(height: 10.0),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: incomeList.length,
                itemBuilder: (context, index) {
                  Income income = incomeList[index];
                  return ListTile(
                    title: Text(
                      income.title,
                      style: TextStyle(color: Color(0xFFEEEEEE)),
                    ),
                    trailing: Text(
                      'Ksh. ${income.amount.toString()}',
                      style: TextStyle(
                        color: Color(0xFFFD7014),
                        fontSize: 14.0,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        SizedBox(height: 20.0),
        Container(
          decoration: BoxDecoration(
            color: Color(0xFFFD7014),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Expense List',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF393E46),
                ),
              ),
              SizedBox(height: 10.0),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: expenseList.length,
                itemBuilder: (context, index) {
                  Expense expense = expenseList[index];
                  return ListTile(
                    title: Text(
                      expense.title,
                      style: TextStyle(color: Color(0xFFEEEEEE)),
                    ),
                    trailing: Text(
                      'Ksh. ${expense.amount.toString()}',
                      style: TextStyle(
                        color: Color(0xFF222831),
                        fontSize: 14.0,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
