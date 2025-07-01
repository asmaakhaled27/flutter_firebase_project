import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
final _photoUrlController = TextEditingController();
  String _gender = "female";

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      try {
        UserCredential credential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        final user = credential.user!;
        await user.updateDisplayName(_usernameController.text.trim());

        // 🔥 Add user data to Firestore
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'displayName': _usernameController.text.trim(),
          'email': _emailController.text.trim(),
          'phone': _phoneController.text.trim(),
          'address': _addressController.text.trim(),
          'gender': _gender,
          'photoUrl': _photoUrlController.text.trim(),
          'createdAt': FieldValue.serverTimestamp(),
        });

        Navigator.pushReplacementNamed(context, '/login');
      } on FirebaseAuthException catch (e) {
        String message = "An error occurred";
        if (e.code == 'weak-password') {
          message = 'The password provided is too weak.';
        } else if (e.code == 'email-already-in-use') {
          message = 'The account already exists for that email.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Unexpected error: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
                validator: (value) =>
                    value!.isEmpty ? 'Enter your username' : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) =>
                    value!.isEmpty ? 'Enter your email' : null,
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) =>
                    value!.length < 6 ? 'Password too short' : null,
              ),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone'),
                validator: (value) =>
                    value!.isEmpty ? 'Enter your phone number' : null,
              ),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Address'),
                validator: (value) =>
                    value!.isEmpty ? 'Enter your address' : null,
              ),
              const SizedBox(height: 10),
               TextFormField(
                controller: _photoUrlController,
                decoration: const InputDecoration(
                  labelText: "Profile Picture URL (Optional)",
                ),
               ),
                const SizedBox(height: 10),
              const Text("Gender"),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Female'),
                      value: "female",
                      groupValue: _gender,
                      onChanged: (value) {
                        setState(() {
                          _gender = value!;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Male'),
                      value: "male",
                      groupValue: _gender,
                      onChanged: (value) {
                        setState(() {
                          _gender = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _register,
                child: const Text("Register"),
              ),
                const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/login');
                },
                child: const Text(
                  "Already have an account? Log in",
                  style: TextStyle(color: Colors.blueGrey),
                ),
              ),


            ],
          ),
        ),
      ),
    );
  }
}
