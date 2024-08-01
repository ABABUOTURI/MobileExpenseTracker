import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:expense_legend/pages/profile_page.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:expense_legend/pages/DashboardPage.dart';
import 'package:expense_legend/pages/budget_page.dart';
import 'package:expense_legend/pages/notification_page.dart';
import 'package:expense_legend/pages/security_settings_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChartsPage extends StatefulWidget {
  const ChartsPage({Key? key}) : super(key: key);

  @override
  _ChartsPageState createState() => _ChartsPageState();
}

class _ChartsPageState extends State<ChartsPage> {
  int _pageIndex = 2; // Set initial page index to 2 to display ChartsPage by default
  double income = 0.0;
  double expense = 0.0;
  double budget = 0.0;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String userId = user.uid;

      // Fetch income
      QuerySnapshot incomeSnapshot = await FirebaseFirestore.instance
          .collection('incomes')
          .where('userId', isEqualTo: userId)
          .get();
      double totalIncome = incomeSnapshot.docs
          .map((doc) => doc['amount'] as double)
          .fold(0.0, (a, b) => a + b);

      // Fetch expense
      QuerySnapshot expenseSnapshot = await FirebaseFirestore.instance
          .collection('expenses')
          .where('userId', isEqualTo: userId)
          .get();
      double totalExpense = expenseSnapshot.docs
          .map((doc) => doc['amount'] as double)
          .fold(0.0, (a, b) => a + b);

      // Fetch budget
      QuerySnapshot budgetSnapshot = await FirebaseFirestore.instance
          .collection('budgets')
          .where('userId', isEqualTo: userId)
          .get();
      double monthlyBudget = budgetSnapshot.docs.isNotEmpty
          ? budgetSnapshot.docs.first['monthlyBudget'] as double
          : 0.0;

      setState(() {
        income = totalIncome;
        expense = totalExpense;
        budget = monthlyBudget;
      });
    }
  }

  LineChartData _buildChartData(double value, List<String> xLabels, String title) {
    return LineChartData(
      lineBarsData: [
        LineChartBarData(
          isCurved: true,
          spots: List.generate(
            xLabels.length,
            (index) => FlSpot(index.toDouble(), value + (index * 500)),
          ),
          color: Color(0xFFFD7014),
          dotData: FlDotData(show: true),
          belowBarData: BarAreaData(
            show: true,
            color: Color(0xFFFD7014).withOpacity(0.3),
          ),
        ),
      ],
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            getTitlesWidget: (value, meta) {
              final style = TextStyle(
                color: Color(0xFFFD7014),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              );
              final index = value.toInt();
              return SideTitleWidget(
                axisSide: meta.axisSide,
                child: Text(
                  index >= 0 && index < xLabels.length ? xLabels[index] : '',
                  style: style,
                ),
              );
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            interval: 1000,
            getTitlesWidget: (value, meta) {
              return Text(
                (value.toInt()).toString(),
                style: TextStyle(
                  color: Color(0xFFFD7014),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              );
            },
          ),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            getTitlesWidget: (value, meta) {
              final style = TextStyle(
                color: Color(0xFFFD7014),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              );
              return SideTitleWidget(
                axisSide: meta.axisSide,
                child: Text(
                  title,
                  style: style,
                ),
              );
            },
          ),
        ),
      ),
      gridData: FlGridData(show: true),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: Color(0xFFFD7014), width: 1),
      ),
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((spot) {
              return LineTooltipItem(
                '${spot.y.toStringAsFixed(2)}',
                TextStyle(color: Color(0xFFFD7014)),
              );
            }).toList();
          },
        ),
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
          'Visualization Of Expenditure',
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
              Color(0xFFEEEEEE)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Cards displaying information
                Card(
                  color: Color(0xFF222831),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0), // Added padding here
                    child: Column(
                      children: [
                        ListTile(
                          title: Text('Total Income',
                              style: TextStyle(color: Colors.white)),
                        ),
                        Container(
                          width: double.infinity,
                          height: 350,
                          child: LineChart(
                            _buildChartData(income, [
                              'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                              'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
                            ], ''),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Card(
                  color: Color(0xFF393E46),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0), // Added padding here
                    child: Column(
                      children: [
                        ListTile(
                          title: Text('Total Expense',
                              style: TextStyle(color: Colors.white)),
                        ),
                        Container(
                          width: double.infinity,
                          height: 350,
                          child: LineChart(
                            _buildChartData(expense, [
                              'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'
                            ], ''),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Card(
                  color: Color(0xFF222831),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0), // Added padding here
                    child: Column(
                      children: [
                        ListTile(
                          title: Text('Budgets',
                              style: TextStyle(color: Colors.white)),
                        ),
                        Container(
                          width: double.infinity,
                          height: 350,
                          child: LineChart(
                            _buildChartData(budget, [
                              'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                              'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
                            ], ''),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Card(
                  color: Color(0xFF393E46),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0), // Added padding here
                    child: Column(
                      children: [
                        ListTile(
                          title: Text('Income and Expenses over the year',
                              style: TextStyle(color: Colors.white)),
                        ),
                        Container(
                          width: double.infinity,
                          height: 350,
                          child: LineChart(
                            _buildChartData(expense - income, [
                              'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                              'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
                            ], ''),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
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
       
          });
        },
      ),
    );
  }
}
