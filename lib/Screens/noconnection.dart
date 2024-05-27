import 'package:my_gallery_book/Components/colors.dart';
import 'package:my_gallery_book/Components/mybutton.dart';
import 'package:my_gallery_book/Screens/splash.dart';
import 'package:flutter/material.dart';

class NoConnection extends StatefulWidget {
  @override
  _NoConnectionState createState() => _NoConnectionState();
}

class _NoConnectionState extends State<NoConnection> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 100, color: red),
            SizedBox(
              height: 40,
            ),
            Text(
              "No Internet Connection",
              style: TextStyle(color: Colors.red),
            ),
            SizedBox(
              height: 20,
            ),
            MyButton(
              btntext: "Retry",
              textcolor: white,
              color: red,
              border: true,
              onPress: () {
                Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (context) => Splash()));
              },
            )
          ],
        ),
      )),
    );
  }
}
