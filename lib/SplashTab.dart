import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Register.dart';
import 'HomeTab.dart'; // Make sure you have this import for the HomePage

class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    await Future.delayed(Duration(seconds: 3)); // Wait for 3 seconds

    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // User is logged in, navigate to home page with user ID
      Navigator.pushReplacementNamed(context, '/home', arguments: user.uid);
    } else {
      // User is not logged in, navigate to register page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => RegisterPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent[100],
      body: WelcomeSplash(),
    );
  }
}

class WelcomeSplash extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned.fill(
          child: Opacity(
            opacity: 0.7,
            child: Image.asset("assets/images/splash.jpeg", fit: BoxFit.cover),
          ),
        ),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Welcome to",
                style: TextStyle(
                  fontSize: 30,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                "Blue Planet",
                style: TextStyle(
                  fontSize: 40,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                ),
              ),
              SizedBox(height: 20),
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  const Color.fromARGB(255, 255, 255, 255),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
