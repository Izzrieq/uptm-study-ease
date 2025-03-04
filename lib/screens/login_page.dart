import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import 'signup_page.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  DatabaseHelper _dbHelper = DatabaseHelper();

  void _forgotPassword() {
    // Add your forgot password logic here
    print("Forgot Password clicked");
  }

  void _login() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    var user = await _dbHelper.getUser(email, password);
    if (user != null) {
      int userId = user['id'];
      String userName = user['name'];
      String userType = user['user_type'];

      Navigator.pushReplacementNamed(
        context,
        '/home',
        arguments: {
          'userId': userId,
          'userName': userName,
          'userType': userType,
        },
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Invalid email or password")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('UPTM Study Ease')),
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
              'Login',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),

            SizedBox(height: 20),
            ElevatedButton(onPressed: _login, child: Text('Login')),
            TextButton(
              onPressed: _forgotPassword,
              child: Text('Forgot Password?'),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignupPage()),
                );
              },
              child: Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}
