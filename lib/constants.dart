import 'package:flutter/material.dart';

import 'dart:ui';

const Color kPrimaryColor = Color(0xFF40DFAF);

final ButtonStyle signinBtnStyle = OutlinedButton.styleFrom(
  shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(2))),
  foregroundColor: kPrimaryColor,
);

class RoundIconButton extends StatelessWidget {
  RoundIconButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      child: Icon(icon),
      onPressed: onPressed,
      shape: CircleBorder(side: BorderSide.none, eccentricity: 0.0),
      fillColor: kPrimaryColor,
      constraints: BoxConstraints.tightFor(
        width: 46.0,
        height: 36.0,
      ),
      elevation: 6.0,
    );
  }
}

const kActive_card_color = Color(0x4440DFAF);
const kInactive_card_color = Colors.white;
final ButtonStyle kStartScanBtnStyle = OutlinedButton.styleFrom(
  foregroundColor: kPrimaryColor,
  disabledForegroundColor: Colors.black,
  elevation: 10,
);

const open_AIP_Key = "sk-proj-ZiR1Mk1oPWubD32vXIlMT3BlbkFJCBfROj9toKBbZR7uehh7";

//Nutritionix application id=1d3b5abb
// application key- d1c69ecb688349ed62330d5622b80fcb	—

//open api - 'sk-proj-BZuPVZZ81GFfOKjyp4dRT3BlbkFJIdH8K42jf46Q9krhMIVa'

const upslashKey = "tBLbubCfB4AGh4DthnSDlWR7jPOgc-J6jROj0CHnpWU";
const upslashSecKey = "3nsYtwzeKDjkVgmKZkhuwOzMhn20ktJdxecBKVn3htE";
