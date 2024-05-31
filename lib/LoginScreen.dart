import 'package:farm_app/RegisterScreen.dart';
import 'package:farm_app/UploadScreen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _authenticate(BuildContext context) async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    try {
      UserCredential userCredential;
      try {
        // Try signing in
        userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        print('Signed in: ${userCredential.user!.uid}');
      } on FirebaseAuthException catch (signInError) {
        if (signInError.code == 'user-not-found') {
          // If sign-in fails due to user not found, try registering
          userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: email,
            password: password,
          );
          print('Registered and signed in: ${userCredential.user!.uid}');
        } else if (signInError.code == 'wrong-password') {
          // Handle wrong password error
          print('Wrong password provided.');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Wrong password provided.')),
          );
          return; // Exit the function to prevent navigation
        } else {
          throw signInError; // Re-throw the error to handle it outside the nested try-catch
        }
      }

      // Navigate to the UploadScreen upon successful authentication
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => UploadScreen(userEmail: email)),
      );
    } on FirebaseAuthException catch (error) {
      // Handle sign-in and registration errors
      if (error.code == 'email-already-in-use') {
        print('Email is already in use.');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Email is already in use.')),
        );
      } else if (error.code == 'wrong-password') {
        print('Wrong password provided.');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Wrong password provided.')),
        );
      } else if (error.code == 'user-not-found') {
        print('No user found for that email.');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No user found for that email.')),
        );
      } else {
        print('Authentication failed: ${error.message}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to authenticate. Please check your credentials.')),
        );
      }
    } catch (error) {
      // Handle any other errors
      print('Authentication failed: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to authenticate. Please check your credentials.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: () => _authenticate(context),
              child: Text('Sign In / Register'),
            ),
            SizedBox(height: 16.0),
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => RegisterScreen()),
                );
              },
              child: Text(
                'Don\'t have an account? Register here',
                style: TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
