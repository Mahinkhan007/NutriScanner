import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nutri_scan/utils/dialogueBuilder.dart';
import 'package:nutri_scan/utils/firestoreauth.dart';
import 'dart:developer';
import 'utils/exceptions.dart';
import 'package:nutri_scan/screens/registration_screen.dart';

class AuthService {
  String errorMessage = "";
  final _auth = FirebaseAuth.instance;
  Future<User?> createUserWithEmailandPassword(
      {required String email,
      required String password,
      required String confirmedPass,
      required String firstName,
      required String lastName,
      required int height,
      required int weight,
      required int age,
      required String gender}) async {
    try {
      if (email.isNotEmpty &&
          password.isNotEmpty &&
          confirmedPass.isNotEmpty &&
          firstName.isNotEmpty &&
          lastName.isNotEmpty) {
        if (password == confirmedPass) {
          final cred = await _auth.createUserWithEmailAndPassword(
              email: email.trim(), password: password.trim());
          await Firebase_firestore().CreateUser(
              email: email,
              firstName: firstName,
              lastName: lastName,
              age: age,
              height: height,
              weight: weight,
              gender: gender);
          return cred.user;
        } else {
          throw exceptions("Passwords must match");
        }
      } else {
        throw exceptions("complete all fields");
      }
    } on FirebaseException catch (e) {
      throw exceptions(e.message.toString());
    }
    return null;
  }

  Future<User?> signInUserWithEmailandPassword(
      String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return cred.user;
    } catch (e) {
      throw exceptions(e.toString());
    }
    return null;
  }

  Future<void> signOut() async {
    try {
      _auth.signOut();
    } catch (e) {
      throw exceptions(e.toString());
    }
  }
}
