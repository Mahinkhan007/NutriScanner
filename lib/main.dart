import 'package:flutter/material.dart';
import 'package:nutri_scan/screens/BMIpage.dart';
import 'package:nutri_scan/screens/login_screen.dart';
import 'package:nutri_scan/screens/welcome_screen.dart';
import 'package:nutri_scan/screens/registration_screen.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(nutriScan());
}

class nutriScan extends StatelessWidget {
  const nutriScan({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: WelcomeScreen.id,
      routes: {
        WelcomeScreen.id: (context) => WelcomeScreen(),
        LoginScreen.id: (context) => LoginScreen(),
        RegistrationScreen.id: (context) => RegistrationScreen(),
      },
    );
  }
}
