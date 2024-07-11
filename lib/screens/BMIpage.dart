import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:nutri_scan/constants.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:nutri_scan/screens/ProductInfo.dart';

import '../auth.dart';
import 'openAIchat.dart';

class User {
  final String id;
  final String email;
  final double height;
  final double weight;
  final String Fname;
  final String gender;

  User(
      {required this.id,
      required this.email,
      required this.height,
      required this.weight,
      required this.Fname,
      required this.gender});
}

class BMIPage extends StatefulWidget {
  final String userId;

  BMIPage({required this.userId});

  @override
  _BMIPageState createState() => _BMIPageState();
}

class _BMIPageState extends State<BMIPage> {
  late double bmi = 0.0;
  late String fname = '';
  int _selectIndex = 0;
  final _auth = AuthService();
  String _scanBarcode = 'Unknown';
  late String _title = '';
  late String _gender = '';
  late String photo1 = 'images/WelcomePhotos/overWFemale/pbar.png';
  late String photo2 = 'images/WelcomePhotos/overWmale/Gymbars.png';
  late String photo3 = 'images/WelcomePhotos/UWFemale/WG.png';

  @override
  void initState() {
    super.initState();
    calculateBMI();
  }

  Future<void> startBarcodeScanStream() async {
    FlutterBarcodeScanner.getBarcodeStreamReceiver(
            '#ff6666', 'Cancel', true, ScanMode.BARCODE)!
        .listen((barcode) => print(barcode));
  }

  Future<void> scanQR() async {
    String barcodeScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.QR);
      print(barcodeScanRes);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _scanBarcode = barcodeScanRes;
    });
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> scanBarcodeNormal() async {
    String barcodeScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.BARCODE);
      print(barcodeScanRes);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _scanBarcode = barcodeScanRes;
    });
  }

  Future<void> calculateBMI() async {
    await Future.delayed(Duration(milliseconds: 500));
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .get();

    if (userSnapshot.exists) {
      Map<String, dynamic> userData =
          userSnapshot.data() as Map<String, dynamic>; // Cast to Map

      User user = User(
        id: widget.userId,
        email: userData['Email'] ?? '',
        height: userData['Height']?.toDouble() ?? 0.0,
        weight: userData['Weight']?.toDouble() ?? 0.0,
        Fname: userData['First-Name'] ?? '',
        gender: userData['Gender'] ?? '',
      );

      setState(() {
        bmi = calculateBMIValue(user.weight, user.height);
        fname = user.Fname.capitalize().toString();
        _gender = user.gender;
        getProducts();
      });
    }
  }

  void getProducts() {
    photo1 = "images/WelcomePhotos/UWFemale/ONBULK.png"; // Default image path
    photo2 =
        "images/WelcomePhotos/overWmale/Screenshot at Jun 18 23-37-50.png"; // Default image path
    photo3 =
        "images/WelcomePhotos/lean male/testmale.jpeg"; // Default image path
    if (_gender == "male" && bmi >= 25) {
      photo1 = "images/WelcomePhotos/overWmale/Gymbars.png";
      photo2 =
          "images/WelcomePhotos/overWmale/Screenshot at Jun 18 23-37-50.png";
      photo3 = "images/WelcomePhotos/overWmale/shopping.webp";
    } else if (_gender == "female" && bmi >= 25) {
      photo1 = "images/WelcomePhotos/overWFemale/pbar.png";
      photo2 =
          "images/WelcomePhotos/overWFemale/Screenshot at Jun 18 23-41-26.png";
      photo3 = "images/WelcomePhotos/overWFemale/slimmingmeds.png";
    } else if (_gender == "male" && bmi > 18.5 && bmi < 25) {
      photo1 = "images/WelcomePhotos/lean male/protein.jpeg";
      photo2 =
          "images/WelcomePhotos/lean male/Screenshot at Jun 18 23-33-21.png";
      photo3 = "images/WelcomePhotos/lean male/testmale.jpeg";
    } else if (_gender == "female" && bmi > 18.5 && bmi < 25) {
      photo1 = "images/WelcomePhotos/lean woman/fiber.png";
      photo2 = "images/WelcomePhotos/lean woman/Saving Account Statement.webp";
      photo3 =
          "images/WelcomePhotos/lean woman/Screenshot at Jun 18 23-35-03.png";
    } else if (_gender == "female" && bmi <= 18.5) {
      photo1 = "images/WelcomePhotos/UWFemale/ONBULK.png";
      photo2 =
          "images/WelcomePhotos/UWFemale/Screenshot at Jun 19 01-21-48.png";
      photo3 = "images/WelcomePhotos/UWFemale/WG.png";
    } else if (_gender == "male" && bmi <= 18.5) {
      photo1 = "images/WelcomePhotos/UWmale/ONBULK.png";
      photo2 = "images/WelcomePhotos/UWmale/onbulk2.png";
      photo3 = "images/WelcomePhotos/UWmale/PB.png";
    } else
      return;
    setState(() {});
  }

  String getResult() {
    if (bmi >= 25) {
      return 'Overweight';
    } else if (bmi > 18.5) {
      return 'Normal';
    } else {
      return 'UnderWeight';
    }
  }

  String getInterpretation() {
    if (bmi >= 25) {
      return 'We can suggest the perfect dietary supplements to help you achieve your fitness goals 🔽';
    } else if (bmi > 18.5) {
      return 'Looking good with those muscles! check out the products below to cover your needs 🔽';
    } else {
      return 'Here are some products that can help you bulk up fast! 🔽';
    }
  }

  double calculateBMIValue(double weight, double height) {
    // Convert height to meters if it's not already in meters
    double heightInMeters = height / 100; // Assuming height is in centimeters
    return weight / (heightInMeters * heightInMeters);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            _title,
            style: TextStyle(
                color: kPrimaryColor,
                fontWeight: FontWeight.w200,
                fontSize: 20),
          ),
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              ChatPage(Fname: fname, uid: widget.userId)));
                },
                icon: Icon(
                  Icons.chat_bubble_outline,
                  color: kPrimaryColor,
                )),
          ],
          automaticallyImplyLeading: false,
        ),
        bottomNavigationBar: NavigationBar(
          backgroundColor: kPrimaryColor,
          shadowColor: Colors.white,
          indicatorColor: Colors.white,
          selectedIndex: _selectIndex,
          onDestinationSelected: (int index) {
            setState(() {
              _selectIndex = index;
              if (_selectIndex == 0) {
                _title = "H O M E";
              } else if (_selectIndex == 1) {
                _title = "S C A N  P R O D U C T";
              } else if (_selectIndex == 2) {
                _title = "S E T T I N G S";
              }
            });
          },
          destinations: <NavigationDestination>[
            NavigationDestination(
                icon: Icon(CupertinoIcons.home), label: 'Home'),
            NavigationDestination(
                icon: Icon(
                  CupertinoIcons.camera_viewfinder,
                ),
                label: 'Scan'),
            NavigationDestination(
                icon: Icon(CupertinoIcons.settings), label: 'Settings')
          ],
        ),
        body: ListView(children: [
          SafeArea(
            child: IndexedStack(
              index: _selectIndex,
              children: [
                Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 15, top: 25),
                        child: Container(
                          alignment: Alignment.bottomLeft,
                          child: Row(
                            children: [
                              Image.asset(
                                'images/Nutri.png',
                                height: 80,
                                width: 80,
                              ),
                              Text(
                                'Welcome, ',
                                style: TextStyle(fontSize: 20),
                              ),
                              Text(
                                '${fname}',
                                style: TextStyle(
                                    fontSize: 30,
                                    color: kPrimaryColor,
                                    fontWeight: FontWeight.w300),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 40,
                      ),
                      Row(
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          SizedBox(
                            width: 20,
                          ),
                          Text(
                            'Your ',
                            style: TextStyle(fontSize: 20),
                          ),
                          Text(
                            'BMI ',
                            style: TextStyle(
                                fontSize: 40,
                                color: kPrimaryColor,
                                fontWeight: FontWeight.w200),
                          ),
                          Text('is  '),
                          Text('${bmi.toStringAsFixed(2)}',
                              style: TextStyle(
                                  fontSize: 40,
                                  color: kPrimaryColor,
                                  fontWeight: FontWeight.w200)),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                          padding: EdgeInsets.only(left: 20),
                          child: Row(
                            children: [
                              Text('-- Your BMI is considered '),
                              Text(
                                getResult(),
                                style: TextStyle(
                                    fontSize: 18,
                                    color: kPrimaryColor,
                                    fontWeight: FontWeight.w300),
                              ),
                            ],
                          )),
                      Container(
                          padding: EdgeInsets.only(left: 20),
                          child: Text('-- ' + getInterpretation())),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        child: Column(
                          children: [
                            Image.asset(photo1, fit: BoxFit.cover),
                            SizedBox(height: 10),
                            Image.asset(photo2, fit: BoxFit.cover),
                            SizedBox(height: 10),
                            Image.asset(photo3, fit: BoxFit.cover),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 100,
                      ),
                      Center(
                        child: Image.asset(
                          "images/Nutri.png",
                          height: 200,
                          width: 200,
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Center(
                        child: OutlinedButton(
                            style: kStartScanBtnStyle,
                            onPressed: () async {
                              Future.delayed(Duration(seconds: 1));
                              scanBarcodeNormal();

                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ProductInfoPage(
                                          barcode: _scanBarcode)));
                            },
                            child: Text('Start barcode scan')),
                      ),
                    ],
                  ),
                ),
                Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: SafeArea(
                          child: OutlinedButton(
                            child: Text(
                              'Logout',
                              style: TextStyle(color: kPrimaryColor),
                            ),
                            onPressed: () async {
                              await _auth.signOut();
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

extension Myextension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1).toLowerCase()}";
  }
}
