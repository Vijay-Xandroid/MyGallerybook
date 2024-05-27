import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';

import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../Components/Routes.dart';
import '../Components/popup.dart';
import '../Components/sharedpref.dart';
import '../Components/urls.dart';
import '../Components/colors.dart';
import '../Components/mybutton.dart';
import '../Components/flushbar.dart';

class OTPScreen extends StatefulWidget {
  const OTPScreen({Key? key}) : super(key: key);

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  @override
  void initState() {
    super.initState();

    print("otp.dart screen initstate/start ");
    getcid().then(updateid);
    getaId().then(updateaid);
    getcphone().then(updatephone);
    print("otp.dart screen initstate/end ");
  }

  updateid(String id) {
    setState(() {
      cid = id;
    });
  }

  updateaid(String id) {
    setState(() {
      aid = id;
    });
  }

  updatephone(String phone) {
    setState(() {
      cphone = phone;
    });
  }

  verify() async {
    poPup(context);
    var url = Uri.parse(Urls.productionHost + Urls.verifyotp);
    var request = new http.MultipartRequest("POST", url);
    request.fields['cId'] = cid!;
    request.fields['cOTP'] = otp!;
    var response = await request.send();
    var data = await response.stream.transform(utf8.decoder).join();
    print(data);
    if (data == "No Customer") {
      Navigator.of(context).pop(true);
      flushBarshow("OTP do not Match, Please Try again", context, red);
    } else if (data == "null") {
      Navigator.of(context).pushReplacement(createprofileroute());
    } else {
      var details;
      setState(() {
        details = jsonDecode(data);
      });
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString("eMail", details["cEmail"]);
      prefs.setString("pId", details["pId"]);
      setUserName(details);

      getmypack();
    }
  }

  getmypack() async {
    var url = Uri.parse(Urls.productionHost + Urls.myPacks);
    var request = new http.MultipartRequest("POST", url);
    request.fields['cId'] = cid!;
    var response = await request.send();
    var data = await response.stream.transform(utf8.decoder).join();
    if (data != "[]") {
      var details = jsonDecode(data);
      if (details[0]["pStatus"] == "1") {
        Navigator.of(context).pushReplacement(homepageroute());
      } else {
        Navigator.of(context).pushReplacement(subscriptionpacks());
      }
    } else {
      Navigator.of(context).pushReplacement(subscriptionpacks());
    }
  }

  resendotp() async {
    poPup(context);
    var url = Uri.parse(Urls.productionHost + Urls.getotp);
    var request = new http.MultipartRequest("POST", url);
    request.fields['cPhone'] = cphone!;
    var response = await request.send();
    var data = await response.stream.transform(utf8.decoder).join();
    if (data != null) {
      Navigator.of(context).pop(true);
      flushBarshow("OTP Sent to $cphone", context, green);
    } else {
      Navigator.of(context).pop(true);
      flushBarshow("Something Went Wrong", context, red);
    }
  }

  String? otp = "", cid, cphone, aid;

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        backgroundColor: white,
        body: Column(
          children: <Widget>[
            Container(
              height: height * .45,
              width: width,
              color: blue,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Transform.translate(
                    offset: Offset(-width * .4, 0),
                    child: IconButton(
                        icon: Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          Navigator.of(context).pushReplacement(loginroute());
                        }),
                  ),
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
                          .bodyLarge
                          ?.copyWith(fontSize: 26, color: white)),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(height: height * .1),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          "OTP Sent to ",
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(fontSize: 16, color: black),
                        ),
                        Text(
                          cphone ?? "",
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(
                                  fontSize: 16,
                                  color: blue,
                                  decoration: TextDecoration.underline),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    OtpTextField(
                      numberOfFields: 4,
                      borderColor: Colors.grey,
                      //set to true to show as box or false to show as dash
                      showFieldAsBox: true,
                      //runs when a code is typed in
                      onCodeChanged: (String code) {
                        //handle validation or checks here
                      },
                      //runs when every textfield is filled
                      onSubmit: (String verificationCode) {
                        setState(() {
                          otp = verificationCode;
                        });
                      }, // end onSubmit
                    ),
                    SizedBox(height: 30),
                    MyButton(
                      onPress: () {
                        if (otp == "") {
                          flushBarshow("Please Enter OTP", context, red);
                        } else {
                          verify();
                        }
                      },
                      btntext: "Verify OTP",
                      color: blue,
                      textcolor: white,
                    ),
                    SizedBox(height: height * .1),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          "Didn't Receive OTP, ",
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(fontSize: 16, color: black),
                        ),
                        GestureDetector(
                          onTap: resendotp,
                          child: Text(
                            "Resend",
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(
                                    fontSize: 16,
                                    color: red,
                                    decoration: TextDecoration.underline),
                          ),
                        ),
                      ],
                    ),
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
