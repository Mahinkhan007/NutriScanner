import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Firebase_firestore {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> CreateUser({
    required String email,
    required String firstName,
    required String lastName,
    required int age,
    required int height,
    required int weight,
    required String gender,
  }) async {
    await _firestore.collection('users').doc(_auth.currentUser!.uid).set(
      {
        'Email': email,
        'First-Name': firstName,
        'Last-Name': lastName,
        'Age': age,
        'Height': height,
        'Weight': weight,
        'Gender': gender,
        'History': [],
      },
    );
  }
}
