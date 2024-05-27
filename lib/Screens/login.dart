import 'package:my_gallery_book/Screens/termsandconditions.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../Components/colors.dart';
import '../Components/textfeild.dart';
import '../Components/mybutton.dart';
import '../Components/urls.dart';
import '../Components/flushbar.dart';
import '../Components/Routes.dart';
import '../Components/popup.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final formKey = GlobalKey<FormState>();
  final phonenumber = TextEditingController();

  var termsandcondition = false;
  var showcheckbox = true;
  SharedPreferences? pref;
  @override
  initState() {
    super.initState();

    // phonenumber.text = "9963879607";
    getStateofLogin();
  }

  getStateofLogin() async {
    pref = await SharedPreferences.getInstance();
    if (pref?.getBool("initial") != null) {
      setState(() {
        termsandcondition = true;
        showcheckbox = false;
      });
    }
  }

  sendotp() async {
    var url = Uri.parse(Urls.productionHost + Urls.getotp);
    var request = http.MultipartRequest("POST", url);
    request.fields['cPhone'] = phonenumber.text;
    var response = await request.send();
    print("response/otp is $response");
    var data = await response.stream.transform(utf8.decoder).join();
    print("data/otp is $data");
    if (data != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString("cPhone", phonenumber.text);
      prefs.setString("cid", data);
      Navigator.of(context).pushReplacement(otproute());
    } else {
      Navigator.of(context).pop(true);
      flushBarshow("Something Went Wrong", context, red);
    }
  }

  check() async {
    if (termsandcondition) {
      if (phonenumber.text == "") {
        flushBarshow("Enter Phone Number", context, red);
      } else if (phonenumber.text.length != 10) {
        flushBarshow("Enter 10 Digit Valid Phone Number", context, red);
      } else if (double.parse(phonenumber.text[0]) < 6) {
        flushBarshow("Enter Valid Phone Number", context, red);
      } else {
        poPup(context);
        sendotp();
      }
    } else {
      print("else cond ...");
      flushBarshow(
          "Accept the terms and conditions to continue.", context, red);
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: white,
        body: Column(
          children: <Widget>[
            Center(
              child: Container(
                height: height * .40,
                width: width,
                color: blue,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image.asset(
                      'assets/App_Icon.png',
                      height: 150,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text('My Gallery Book',
                        style: Theme.of(context)
                            .textTheme
                            .bodyText1
                            ?.copyWith(fontSize: 26, color: white)),
                  ],
                ),
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(height: height * .1),
                    MyTextFormField(
                      controller: phonenumber,
                      hintText: "Enter Phone Number",
                      icon: Icon(
                        Icons.sim_card,
                        size: 25,
                      ),
                      number: 10,
                      isNumber: true,
                      lable: "Phone Number",
                    ),
                    SizedBox(height: 5),
                    showcheckbox
                        ? Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Checkbox(
                                    visualDensity: VisualDensity.compact,
                                    value: termsandcondition,
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    onChanged: (value) {
                                      setState(() {
                                        termsandcondition = value!;
                                      });
                                    }),
                                TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  TermsAndConditions()));
                                    },
                                    child: Text(
                                      "Terms and Conditions",
                                      style: TextStyle(color: blue, fontSize: 18),
                                    ))
                              ],
                            ),
                          )
                        : Container(),
                    MyButton(
                      onPress: check,
                      btntext: "Get OTP",
                      color: blue,
                      textcolor: white,
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
