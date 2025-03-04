import 'package:flutter/material.dart';
import 'screens/login_page.dart';
import 'screens/home_page.dart';
import 'screens/inbox_page.dart';
import 'screens/download_page.dart';
import 'screens/profile_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Study Ease',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/', // Start with the login page
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (context) => LoginPage());

          case '/home':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder:
                  (context) => HomePage(
                    userId: args['userId'],
                    userName: args['userName'],
                    userType: args['userType'],
                  ),
            );

          case '/profile':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder:
                  (context) => ProfilePage(userId: args['userId']), // Corrected
            );

          case '/inbox':
            return MaterialPageRoute(builder: (context) => InboxPage());

          case '/download':
            return MaterialPageRoute(builder: (context) => DownloadPage());

          default:
            return MaterialPageRoute(builder: (context) => LoginPage());
        }
      },
    );
  }
}
