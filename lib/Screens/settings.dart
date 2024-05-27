import 'package:my_gallery_book/Components/Routes.dart';
import 'package:my_gallery_book/Screens/contactsupport.dart';
import 'package:my_gallery_book/Screens/login.dart';
import 'package:my_gallery_book/Screens/paymenthistory.dart';
import 'package:my_gallery_book/Screens/profie.dart';
import 'package:my_gallery_book/Screens/subscriptionpacks.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share/share.dart';
import 'dart:io' show Platform;
import '../Components/sharedpref.dart';
import '../Components/colors.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  var name;

  getName() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var cid = await getcid();
    print(cid);
    setState(() {
      // name = pref.getString("firstName") + " " + pref.getString("lastName")!;
      name = "${pref.getString("firstName")} ${pref.getString("lastName")!}";
    });
  }

  @override
  void initState() {
    super.initState();
    getName();
  }

  logOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove("cid");
    prefs.remove("eMail");
    prefs.remove('cPhone');
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (BuildContext context) => Login()),
      ModalRoute.withName('/'),
    );
  }

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  String? cid;

  DateTime? current;
  Future<bool> _onBackPressed() async {
    DateTime now = DateTime.now();
    if (current == null || now.difference(current!) > Duration(seconds: 3)) {
      current = now;
      Fluttertoast.showToast(
        msg: "Press Again to Exit",
        toastLength: Toast.LENGTH_SHORT,
        backgroundColor: black,
        fontSize: 14,
        textColor: Colors.white,
      );
      return Future.value(false);
    } else {
      Fluttertoast.cancel();
      SystemNavigator.pop();
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        backgroundColor: white,
        body: Center(
          child: ListView(
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(top: 30),
                height: height * .16,
                width: width,
                decoration: BoxDecoration(
                    color: blue,
                    borderRadius:
                        BorderRadius.vertical(bottom: Radius.circular(30))),
                child: Center(
                  child: Text(
                    "Settings",
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: white,
                        fontSize: width * .07,
                        fontWeight: FontWeight.w100,
                        letterSpacing: .5),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Center(
                  child: Container(
                      child: Text(
                    "Welcome $name",
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  )),
                ),
              ),
              Container(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Profile()));
                        },
                        child: Card(
                          elevation: 6,
                          color: blue,
                          shape: StadiumBorder(),
                          child: Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: ListTile(
                              leading: Icon(
                                Icons.account_circle,
                                color: Colors.white,
                                size: 40,
                              ),
                              title: Text("Profile",
                                  style: TextStyle(color: Colors.white)),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => PaymentHistory()));
                        },
                        child: Card(
                          elevation: 6,
                          color: blue,
                          shape: StadiumBorder(),
                          child: Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: ListTile(
                              leading: Icon(Icons.account_balance_wallet,
                                  color: Colors.white, size: 40),
                              title: Text("Payments",
                                  style: TextStyle(color: Colors.white)),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.of(context).push(allOrders());
                        },
                        child: Card(
                          elevation: 6,
                          color: blue,
                          shape: StadiumBorder(),
                          child: Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: ListTile(
                              leading: Icon(Icons.subscriptions,
                                  color: Colors.white, size: 40),
                              title: Text("Orders",
                                  style: TextStyle(color: Colors.white)),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => SubscriptionPacks()));
                        },
                        child: Card(
                          elevation: 6,
                          color: blue,
                          shape: StadiumBorder(),
                          child: Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: ListTile(
                              leading: Icon(Icons.account_balance_wallet,
                                  color: Colors.white, size: 40),
                              title: Text("Subscriptions",
                                  style: TextStyle(color: Colors.white)),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  ContactSupport()));
                        },
                        child: Card(
                          elevation: 6,
                          color: blue,
                          shape: StadiumBorder(),
                          child: Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: ListTile(
                              leading: Icon(Icons.help,
                                  color: Colors.white, size: 40),
                              title: Text("Contact Support",
                                  style: TextStyle(color: Colors.white)),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      InkWell(
                        onTap: () {
                          var invitationText =
                              "Hey,\n\nMygallerbook is a fast and secure app that I use to order photobook which has beautiful photobook designs and premium quality products.\n\nGet it for free at\n";

                          if (Platform.isIOS) {
                            Share.share(
                                "${invitationText}https://apps.apple.com/us/app/id1528348936");
                          } else {
                            Share.share(
                                "${invitationText}https://play.google.com/store/apps/details?id=com.vitasoft.Mygallerybook");
                          }
                        },
                        child: Card(
                          elevation: 6,
                          color: blue,
                          shape: StadiumBorder(),
                          child: Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: ListTile(
                              leading: Icon(Icons.person_add,
                                  color: Colors.white, size: 40),
                              title: Text("Invite a friend",
                                  style: TextStyle(color: Colors.white)),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      InkWell(
                        onTap: () {
                          logOut();
                        },
                        child: Card(
                          elevation: 6,
                          color: blue,
                          shape: StadiumBorder(),
                          child: Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: ListTile(
                              leading: Icon(
                                Icons.exit_to_app,
                                color: Colors.white,
                                size: 40,
                              ),
                              title: Text("Logout",
                                  style: TextStyle(color: Colors.white)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
