import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

import 'package:nutri_scan/constants.dart';
import 'package:nutri_scan/screens/login_screen.dart';
import 'package:nutri_scan/screens/registration_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});
  static const id = 'welcome_screen';

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation _animation;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(seconds: 1));

    _animation = CurvedAnimation(parent: _controller, curve: Curves.decelerate);
    // animation = ColorTween(begin: Colors.blueGrey, end: Colors.white)
    //     .animate(controller);
    _controller.forward();

    //   animation.addStatusListener((status) {
    //     if(status == AnimationStatus.completed) {
    //       controller.reverse(from: 1.0);
    //     }else if(status ==AnimationStatus.dismissed) {
    // controller.forward();
    //     }
    //   });

    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24),
        child: Hero(
          tag: 'logo',
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 50, bottom: 90),
                  child: Image.asset(
                    'images/Nutri.png',
                    height: _animation.value * 200,
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: AnimatedTextKit(
                        animatedTexts: [
                          WavyAnimatedText(
                              'Start scanning your nutritional needs',
                              textAlign: TextAlign.center,
                              textStyle: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w300,
                                fontFamily: 'Montserrat',
                              ),
                              speed: const Duration(milliseconds: 150)),
                        ],
                        isRepeatingAnimation: false,
                      ),
                    ),
                    Icon(
                      Icons.app_shortcut_outlined,
                      color: kPrimaryColor,
                    ),
                  ],
                ),
                SizedBox(
                  height: 30,
                ),
                OutlinedButton(
                    style: signinBtnStyle,
                    onPressed: () {
                      Navigator.pushNamed(context, LoginScreen.id);
                    },
                    child: Text('Sign in',
                        style: TextStyle(color: kPrimaryColor))),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('New to NutriScan?'),
                    TextButton(
                      style:
                          TextButton.styleFrom(foregroundColor: kPrimaryColor),
                      onPressed: () {
                        Navigator.pushNamed(context, RegistrationScreen.id);
                      },
                      child: Text(
                        'Create an account',
                        style: TextStyle(color: kPrimaryColor),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
