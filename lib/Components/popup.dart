import 'package:flutter/material.dart';


 poPup(context) {
  return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          elevation: 30,
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Container(
            decoration: new BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(20)),
            child: Row(
              children: <Widget>[
                CircularProgressIndicator(
                  strokeWidth: 3,
                  backgroundColor: Colors.black12,
                ),
                SizedBox(width: 30),
                Text('Please Wait.....')
              ],
            ),
          ),
        );
      });
}
