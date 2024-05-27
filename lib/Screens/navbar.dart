import 'dart:convert';

import 'package:my_gallery_book/Components/flushbar.dart';
import 'package:my_gallery_book/Components/sharedpref.dart';
import 'package:my_gallery_book/Components/urls.dart';
import 'package:my_gallery_book/Screens/settings.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../Components/Routes.dart';
import '../Components/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'profie.dart';
import 'homepage.dart';

class BottomBar extends StatefulWidget {
  @override
  _BottomBarState createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  int currentIndex = 0;
  final List<Widget> screens = [
    Home(),
    Settings(),
  ];
  Widget currentScreen = Home();

  @override
  void initState() {
    super.initState();
    getcid().then(updateid);
  }

  late String _cid, pack = "0";

  var packs;

  updateid(String id) {
    setState(() {
      _cid = id;
      print(_cid);
      myPack();
    });
  }

  myPack() async {
    var url = Uri.parse(Urls.productionHost + Urls.myPacks);
    var request = new http.MultipartRequest("POST", url);
    request.fields['cId'] = _cid;
    var response = await request.send();
    var data = await response.stream.transform(utf8.decoder).join();
    if (data != "[]") {
      setState(() {
        packs = jsonDecode(data);
        pack = packs[packs.length - 1]["sRemainAlbums"];
        print(pack);
      });
    }
  }

  DateTime? currentBackPressTime;
  Future<bool> onWillPop() {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime!) > Duration(seconds: 2)) {
      currentBackPressTime = now;
      Fluttertoast.showToast(
          msg: "Press Again to Exit",
          backgroundColor: darkBlue,
          textColor: white,
          gravity: ToastGravity.BOTTOM);
      return Future.value(false);
    }
    return Future.value(true);
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: currentIndex,
        children: screens,
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        child: Icon(Icons.add),
        elevation: 0,
        backgroundColor: blue,
        splashColor: darkBlue,
        onPressed: pack == "0"
            ? () {
                Feedback.forTap(context);
                HapticFeedback.mediumImpact();
                Navigator.of(context).push(subscriptionpacks());
              }
            : () async {
                Feedback.forTap(context);
                HapticFeedback.lightImpact();
               Navigator.of(context).push(pickimages());
              },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 10,
        clipBehavior: Clip.antiAlias,
        color: Colors.transparent,
        elevation: 0,
        child: Container(
          height: width * .15,
          decoration: BoxDecoration(
              color: blue,
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(width * .08))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              ClipRRect(
                borderRadius:
                    BorderRadius.only(topLeft: Radius.circular(width * .08)),
                child: MaterialButton(
                  minWidth: width * .5,
                  height: width * .15,
                  splashColor: Colors.transparent,
                  onPressed: () {
                    setState(() {
                      currentScreen = Home();
                      currentIndex = 0;
                    });
                  },
                  child: Icon(
                    Icons.business,
                    size: currentIndex == 0 ? 35 : 20,
                    color: currentIndex == 0 ? white : white.withOpacity(.2),
                  ),
                ),
              ),
              Flexible(
                child: ClipRRect(
                  borderRadius:
                      BorderRadius.only(topRight: Radius.circular(width * .08)),
                  child: MaterialButton(
                    minWidth: width * .5,
                    height: width * .15,
                    onPressed: () {
                      setState(() {
                        currentScreen = Settings();
                        currentIndex = 1;
                      });
                    },
                    child: Icon(
                      Icons.business_center,
                      size: currentIndex == 1 ? 35 : 20,
                      color: currentIndex == 1 ? white : white.withOpacity(.2),
                    ),
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
