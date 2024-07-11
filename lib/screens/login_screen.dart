import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:nutri_scan/auth.dart';
import 'package:nutri_scan/constants.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nutri_scan/utils/exceptions.dart';

import '../utils/dialogueBuilder.dart';
import 'BMIpage.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  static const id = 'login_screen';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _auth = AuthService();
  FocusNode _emailF = FocusNode();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 150),
                child: Row(
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 0, right: 10, bottom: 2),
                      child: Hero(
                        tag: 'logo',
                        child: Image.asset(
                          'images/Nutri.png',
                          height: 40,
                          width: 40,
                        ),
                      ),
                    ),
                    Text(
                      'Login to your account',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontFamily: 'Montserrat', fontSize: 21),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 30,
              ),
              TextField(
                controller: _email,
                focusNode: _emailF,
                style: TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.email_rounded),
                  focusColor: kPrimaryColor,
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: kPrimaryColor),
                      borderRadius: BorderRadius.circular(10.0)),
                  labelText: "E-mail",
                  hintText: 'Enter your e-mail address',
                  labelStyle: TextStyle(color: kPrimaryColor),
                  border: OutlineInputBorder(
                      borderSide: BorderSide(color: kPrimaryColor),
                      borderRadius: BorderRadius.circular(10.0)),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              TextField(
                controller: _password,
                obscureText: true,
                style: TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.password),
                  focusColor: kPrimaryColor,
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: kPrimaryColor),
                      borderRadius: BorderRadius.circular(10.0)),
                  labelText: "Secret Key",
                  hintText: 'Enter your password',
                  labelStyle: TextStyle(color: kPrimaryColor),
                  border: OutlineInputBorder(
                      borderSide: BorderSide(color: kPrimaryColor),
                      borderRadius: BorderRadius.circular(10.0)),
                ),
              ),
              SizedBox(
                height: 30,
              ),
              OutlinedButton(
                  style: signinBtnStyle,
                  onPressed: () {
                    _login();
                  },
                  child:
                      Text('Sign in', style: TextStyle(color: kPrimaryColor)))
            ],
          ),
        ),
      ),
    );
  }

  _login() async {
    try {
      final user = await _auth.signInUserWithEmailandPassword(
          _email.text, _password.text);
      if (user != null) {
        log("User logged in successfully");
        await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  BMIPage(userId: user.uid)), // Pass the user ID to BMIPage
        );
        _email.text = '';
        _password.text = '';
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'invalid-email':
          errorMessage = 'The email address is not valid.';
          break;
        case 'user-not-found':
          errorMessage = 'No user found for that email.';
          break;
        case 'wrong-password':
          errorMessage = 'Wrong password provided for that user.';
          break;
        default:
          errorMessage = 'An error occurred. Please try again.';
      }
      _showErrorDialog(errorMessage);
    } catch (e) {
      _showErrorDialog('An error occurred. Please try again.');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
