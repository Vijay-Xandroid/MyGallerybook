import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';

import 'colors.dart';

flushBarshow(String _errorText, context, Color color) {
  Flushbar(
    messageText: Text(
      _errorText,
      textScaleFactor: 01,
      style: TextStyle(
          fontSize: 16, color: Colors.white70, fontWeight: FontWeight.bold),
    ),
    margin: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
    borderRadius: BorderRadius.circular(20),
    padding: EdgeInsets.all(20),
    flushbarPosition: FlushbarPosition.TOP,
    flushbarStyle: FlushbarStyle.FLOATING,
    reverseAnimationCurve: Curves.decelerate,
    forwardAnimationCurve: Curves.elasticInOut,
    backgroundColor: color,
    boxShadows: [
      BoxShadow(
          color: Colors.black.withOpacity(.2),
          offset: Offset(0.0, 2.0),
          blurRadius: 6.0)
    ],
    borderColor: Colors.white70,
    borderWidth: 5,
    isDismissible: true,
    dismissDirection: FlushbarDismissDirection.HORIZONTAL,
    icon: color == red
        ? Icon(
            Icons.error,
            color: Colors.white70,
          )
        : Icon(
            Icons.check_circle,
            color: Colors.white70,
          ),
    duration: Duration(seconds: 5),
  ).show(context);
}
