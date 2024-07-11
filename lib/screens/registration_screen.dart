import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:nutri_scan/auth.dart';
import 'package:nutri_scan/constants.dart';
import 'package:nutri_scan/screens/login_screen.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'dart:developer';

import '../utils/dialogueBuilder.dart';
import '../utils/exceptions.dart';
import 'BMIpage.dart';

enum GenderType { male, female, none }

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});
  static const id = 'registration_screen';
  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _auth = AuthService();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _rePassword = TextEditingController();
  String eMessage = "";

  Color maleCardColor = kInactive_card_color;
  Color femaleCardColor = kInactive_card_color;
  int _height = 160;
  int _weight = 60;
  int _age = 20;

  GenderType selectedGender = GenderType.none;
  Color genderColorMale = kPrimaryColor;
  Color genderColorFemale = kPrimaryColor;

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _email.dispose();
    _password.dispose();
    _rePassword.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Row(
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Padding(
                        padding:
                            const EdgeInsets.only(left: 0, right: 7, bottom: 2),
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
                        'Register a new account',
                        textAlign: TextAlign.center,
                        style:
                            TextStyle(fontFamily: 'Montserrat', fontSize: 21),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 5,
                      child: TextField(
                        controller: _firstName,
                        style: TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.person),
                          focusColor: kPrimaryColor,
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: kPrimaryColor),
                              borderRadius: BorderRadius.circular(10.0)),
                          labelText: "First name",
                          hintText: '',
                          labelStyle: TextStyle(color: kPrimaryColor),
                          border: OutlineInputBorder(
                              borderSide: BorderSide(color: kPrimaryColor),
                              borderRadius: BorderRadius.circular(10.0)),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      flex: 4,
                      child: TextField(
                        controller: _lastName,
                        style: TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          focusColor: kPrimaryColor,
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: kPrimaryColor),
                              borderRadius: BorderRadius.circular(10.0)),
                          labelText: "Last name",
                          hintText: '',
                          labelStyle: TextStyle(color: kPrimaryColor),
                          border: OutlineInputBorder(
                              borderSide: BorderSide(color: kPrimaryColor),
                              borderRadius: BorderRadius.circular(10.0)),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                TextField(
                  controller: _email,
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
                  height: 10,
                ),
                TextField(
                  controller: _rePassword,
                  obscureText: true,
                  style: TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.password_rounded),
                    focusColor: kPrimaryColor,
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: kPrimaryColor),
                        borderRadius: BorderRadius.circular(10.0)),
                    labelText: "Re-type Secret Key",
                    hintText: 'Re-type your password',
                    labelStyle: TextStyle(color: kPrimaryColor),
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: kPrimaryColor),
                        borderRadius: BorderRadius.circular(10.0)),
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                Row(
                  children: [
                    Container(
                      child: Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedGender = GenderType.male;
                              genderColorMale = Colors.black;
                              genderColorFemale = kPrimaryColor;
                            });
                          },
                          child: Container(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.male,
                                  size: 60,
                                ),
                                SizedBox(
                                  height: 2,
                                ),
                                Text(
                                  'Male',
                                  style: TextStyle(
                                      fontSize: 15, color: genderColorMale),
                                ),
                              ],
                            ),
                            margin: EdgeInsets.all(3.0),
                            padding: EdgeInsets.only(top: 10, bottom: 10),
                            decoration: BoxDecoration(
                                color: selectedGender == GenderType.male
                                    ? kActive_card_color
                                    : kInactive_card_color,
                                borderRadius: BorderRadius.circular(10.0),
                                border: Border.all(color: Colors.black)),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Container(
                      child: Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedGender = GenderType.female;
                              genderColorFemale = Colors.black;
                              genderColorMale = kPrimaryColor;
                            });
                          },
                          child: Container(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.female,
                                  size: 60,
                                ),
                                SizedBox(
                                  height: 2,
                                ),
                                Text(
                                  'Female',
                                  style: TextStyle(
                                      fontSize: 15, color: genderColorFemale),
                                ),
                              ],
                            ),
                            margin: EdgeInsets.all(3.0),
                            padding: EdgeInsets.only(top: 10, bottom: 10),
                            decoration: BoxDecoration(
                                color: selectedGender == GenderType.female
                                    ? kActive_card_color
                                    : kInactive_card_color,
                                borderRadius: BorderRadius.circular(10.0),
                                border: Border.all(color: Colors.black)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                GestureDetector(
                  child: Container(
                    margin: EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(color: Colors.black)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: <Widget>[
                            Text(
                              'Height',
                              style: TextStyle(
                                fontSize: 20.0,
                                color: kPrimaryColor,
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(_height.toString(),
                                style: TextStyle(
                                    fontSize: 30.0,
                                    fontWeight: FontWeight.w900)),
                            Text(
                              'cm',
                              style: TextStyle(
                                fontSize: 12.0,
                                color: kPrimaryColor,
                              ),
                            )
                          ],
                        ),
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                              thumbShape: RoundSliderThumbShape(
                                  enabledThumbRadius: 10.0),
                              overlayShape:
                                  RoundSliderOverlayShape(overlayRadius: 20.0),
                              thumbColor: kPrimaryColor,
                              overlayColor: Color(0x29FCFFE0),
                              activeTrackColor: kPrimaryColor,
                              inactiveTrackColor: Color(0xFF8D8E98),
                              trackHeight: 1.0),
                          child: Slider(
                            value: _height.toDouble(),
                            onChanged: (double newValue) {
                              setState(() {
                                _height = newValue.round();
                              });
                            },
                            min: 120.0,
                            max: 220.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {},
                        child: Container(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                mainAxisAlignment: MainAxisAlignment.center,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    "Weight",
                                    style: TextStyle(
                                        fontSize: 15, color: kPrimaryColor),
                                  ),
                                  SizedBox(
                                    width: 6,
                                  ),
                                  Text(_weight.toString(),
                                      style: TextStyle(
                                          fontSize: 30.0,
                                          fontWeight: FontWeight.w900)),
                                  Text(
                                    'kg',
                                    style: TextStyle(
                                      fontSize: 12.0,
                                      color: kPrimaryColor,
                                    ),
                                  )
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  RoundIconButton(
                                    icon: Icons.remove,
                                    onPressed: () {
                                      setState(() {
                                        _weight--;
                                      });
                                    },
                                  ),
                                  SizedBox(
                                    width: 1.0,
                                  ),
                                  RoundIconButton(
                                    icon: Icons.add,
                                    onPressed: () {
                                      setState(() {
                                        _weight++;
                                      });
                                    },
                                  )
                                ],
                              )
                            ],
                          ),
                          margin: EdgeInsets.all(0.0),
                          padding: EdgeInsets.all(15),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10.0),
                              border: Border.all(color: Colors.black)),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {},
                        child: Container(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                mainAxisAlignment: MainAxisAlignment.center,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    "Age",
                                    style: TextStyle(
                                        fontSize: 15, color: kPrimaryColor),
                                  ),
                                  SizedBox(
                                    width: 6,
                                  ),
                                  Text(_age.toString(),
                                      style: TextStyle(
                                          fontSize: 30.0,
                                          fontWeight: FontWeight.w900)),
                                  Text(
                                    'years',
                                    style: TextStyle(
                                      fontSize: 12.0,
                                      color: kPrimaryColor,
                                    ),
                                  )
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  RoundIconButton(
                                    icon: Icons.remove,
                                    onPressed: () {
                                      setState(() {
                                        _age--;
                                      });
                                    },
                                  ),
                                  SizedBox(
                                    width: 1.0,
                                  ),
                                  RoundIconButton(
                                    icon: Icons.add,
                                    onPressed: () {
                                      setState(() {
                                        _age++;
                                      });
                                    },
                                  )
                                ],
                              )
                            ],
                          ),
                          margin: EdgeInsets.all(0.0),
                          padding: EdgeInsets.all(15),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10.0),
                              border: Border.all(color: Colors.black)),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                OutlinedButton(
                    style: signinBtnStyle,
                    onPressed: () async {
                      await _signUP();
                    },
                    child: Text('Register account',
                        style: TextStyle(color: kPrimaryColor)))
              ],
            ),
          ),
        ),
      ),
    );
  }

  _signUP() async {
    try {
      final user = await _auth.createUserWithEmailandPassword(
        email: _email.text,
        password: _password.text,
        confirmedPass: _rePassword.text,
        firstName: _firstName.text,
        lastName: _lastName.text,
        gender: selectedGender == GenderType.male ? "male" : "female",
        age: _age,
        weight: _weight,
        height: _height,
      );

      if (user != null) {
        log("User created successfulyy");
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  BMIPage(userId: user.uid)), // Pass the user ID to BMIPage
        );
      }
    } on exceptions catch (e) {
      dialogueBuilder(context, e.message);
    }
  }
}
