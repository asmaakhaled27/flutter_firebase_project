import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      try {
        UserCredential userCredential =
            await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // Retrieve the user ID from the userCredential
        String userId = userCredential.user?.uid ?? '';
        Navigator.pushReplacementNamed(context, '/home', arguments: userId);
      } on FirebaseAuthException catch (e) {
        String message = "An error occurred";
        if (e.code == 'user-not-found') {
          message = 'No user found for that email.';
        } else if (e.code == 'wrong-password') {
          message = 'Wrong password provided.';
        }
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message)));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("An unexpected error occurred")),
        );
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      final result =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final user = result.user!;
      await _saveUserToFirestore(user);
      Navigator.pushReplacementNamed(context, '/home', arguments: user.uid);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Google Sign-In Failed: $e")),
      );
    }
  }

  Future<void> _signInWithFacebook() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login();
      if (result.status == LoginStatus.success) {
        final OAuthCredential credential =
            FacebookAuthProvider.credential(result.accessToken!.token);
        final authResult =
            await FirebaseAuth.instance.signInWithCredential(credential);
        final user = authResult.user!;
        await _saveUserToFirestore(user);
        Navigator.pushReplacementNamed(context, '/home', arguments: user.uid);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Facebook Sign-In Failed: ${result.message}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Facebook Sign-In Failed: $e")),
      );
    }
  }

  Future<void> _saveUserToFirestore(User user) async {
    final userDoc =
        FirebaseFirestore.instance.collection('users').doc(user.uid);
    final doc = await userDoc.get();

    // فقط أضف المستخدم لو مش موجود
    if (!doc.exists) {
      await userDoc.set({
        'displayName': user.displayName ?? '',
        'email': user.email ?? '',
        'phone': user.phoneNumber ?? '',
        'address': '',
        'gender': '',
        'photoUrl': user.photoURL ?? '',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Blue Planet Login")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter your email'
                    : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter your password'
                    : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _login, child: const Text('Login')),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/register');
                },
                child: const Text('Create an account'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _signInWithGoogle,
                child: const Text('Sign in with Google'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _signInWithFacebook,
                child: const Text('Sign in with Facebook'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
