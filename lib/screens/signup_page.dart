import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import 'login_page.dart';

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final DatabaseHelper dbHelper = DatabaseHelper();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void _signup() async {
    String email = emailController.text;

    // Check if the email is already registered
    final existingUser = await dbHelper.getUser(email, passwordController.text);
    if (existingUser != null) {
      _showEmailExistsError();
      return;
    }

    String userType =
        email.toLowerCase().contains('admin') ? 'Lecturer' : 'Student';

    await dbHelper.insertUser({
      'name': nameController.text,
      'email': email,
      'password': passwordController.text,
      'user_type': userType,
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  // Show error dialog if email already exists
  void _showEmailExistsError() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Email Already Registered'),
          content: Text(
            'This email is already associated with an account. Please try logging in or use a different email.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sign Up')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Center(
              child: Image.asset(
                'assets/logo.png',
                height: 100.0,
                width: 100.0,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Sign Up',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(onPressed: _signup, child: Text('Sign Up')),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
              child: Text('Already have an account? Login'),
            ),
          ],
        ),
      ),
    );
  }
}
