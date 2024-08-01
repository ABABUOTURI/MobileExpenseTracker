import 'package:flutter/material.dart';
import 'package:expense_legend/pages/profile_page.dart';

class SecuritySettingsPage extends StatefulWidget {
  @override
  _SecuritySettingsPageState createState() => _SecuritySettingsPageState();
}

class _SecuritySettingsPageState extends State<SecuritySettingsPage> {
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
        title: const Text(
          'Security Settings',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF222831), // Match ProfilePage AppBar color
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF222831), // Match ProfilePage gradient colors
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
            ListTile(
              title: const Text(
                'Two-Factor Authentication',
                style: TextStyle(color: Colors.white),
              ),
              subtitle: const Text(
                'Enable or disable two-factor authentication.',
                style: TextStyle(color: Colors.white),
              ),
              trailing: ElevatedButton(
                onPressed: () {
                  // Enable/Disable logic here
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Color(0xFF222831), // Match ProfilePage button color
                ),
                child: const Text(
                  'Enable/Disable',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            ListTile(
              title: const Text(
                'Password Management',
                style: TextStyle(color: Colors.white),
              ),
              subtitle: const Text(
                'Change your password and manage security.',
                style: TextStyle(color: Colors.white),
              ),
              trailing: ElevatedButton(
                onPressed: () {
                  // Navigate to change password page or dialog
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Color(0xFF222831), // Match ProfilePage button color
                ),
                child: const Text(
                  'Manage',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilePage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    Color(0xFF222831), // Match ProfilePage button color
              ),
              child: const Text(
                'Back to Profile',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
