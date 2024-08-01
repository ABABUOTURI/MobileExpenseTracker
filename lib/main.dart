import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:expense_legend/pages/add_expense_page.dart';
import 'package:expense_legend/pages/add_income_page.dart';
import 'package:expense_legend/pages/income_list_page.dart';
import 'package:expense_legend/pages/login_page.dart';
import 'package:expense_legend/pages/reset_password_page.dart';
import 'package:expense_legend/pages/profile_page.dart';
import 'package:expense_legend/pages/notification_page.dart';
import 'package:expense_legend/pages/budget_page.dart';
import 'package:expense_legend/pages/DashboardPage.dart';
import 'package:expense_legend/pages/ChartsPage.dart';
import 'package:expense_legend/pages/security_settings_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyBfhHbo68kQBTYcywwVR8lK9KxsR2qZiMI",
      authDomain: "contactportfolio-ea6bf.firebaseapp.com",
      projectId: "contactportfolio-ea6bf",
      storageBucket: "contactportfolio-ea6bf.appspot.com",
      messagingSenderId: "440719674261",
      appId: "1:440719674261:android:ba2de03a3c7056d61c449c",
    ),
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Expense Tracker',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginPage(),
        '/reset_password': (context) => ResetPasswordPage(),
        '/add_expense': (context) => AddExpensePage(),
        '/add_income': (context) => AddIncomePage(),
        '/income_list_page': (context) => IncomeListPage(),
        '/profile': (context) => ProfilePage(),
        '/notifications': (context) => NotificationsPage(),
        '/budget': (context) => BudgetPage(),
        '/dashboard': (context) => DashboardPage(),
        '/charts': (context) => ChartsPage(),
        '/security_settings': (context) => SecuritySettingsPage(),
        // Add more routes as needed
      },
    );
  }
}
