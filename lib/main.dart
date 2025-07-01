import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:my_app/HomeTab.dart';
import 'login.dart';
import 'register.dart';
import 'SplashTab.dart';
import 'createPost.dart';
import 'Profile.dart';
import 'package:firebase_auth/firebase_auth.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyCO0fv9-fZhAFt6FMUJGgLCt4gXFre3m1c",
        authDomain: "socialapp-f6b89.firebaseapp.com",
        projectId: "socialapp-f6b89",
        storageBucket: "socialapp-f6b89.firebasestorage.app",
        messagingSenderId: "693006326484",
        appId: "1:693006326484:web:0a17c0a36ee86162c43941",
        measurementId: "G-2KZND2G7B4"
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Blue Planet',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/home':
            return MaterialPageRoute(
              builder: (context) => HomePage(userId: settings.arguments as String),
            );
          case '/create_post':
            return MaterialPageRoute(builder: (context) => CreatePostPage());
          case '/':
            return MaterialPageRoute(builder: (context) => SplashPage());
          case '/login':
            return MaterialPageRoute(builder: (context) => LoginPage());
          case '/register':
            return MaterialPageRoute(builder: (context) => RegisterPage());
          case '/profile':
            return MaterialPageRoute(builder: (context) => UserProfilePage());
     
          default:
            return null;
        }
      },
    );
  }
}


