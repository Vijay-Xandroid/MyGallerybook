import 'dart:async';
import 'dart:convert';
import 'package:my_gallery_book/Screens/noconnection.dart';
import 'package:my_gallery_book/widgets/directly_used_packages/data_connection_checker/data_connection_checker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
// import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:connectivity/connectivity.dart';
import '../Components/Routes.dart';
import '../Components/colors.dart';
import '../Components/sharedpref.dart';
import '../Components/urls.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class Splash extends StatefulWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  Future<bool> isInternet() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      // I am connected to a mobile network, make sure there is actually a net connection.
      //
      if (await DataConnectionChecker().hasConnection) {
        // Mobile data detected & internet connection confirmed.
        return true;
      } else {
        // Mobile data detected but no internet connection found.
        return false;
      }
    } else if (connectivityResult == ConnectivityResult.wifi) {
      // I am connected to a WIFI network, make sure there is actually a net connection.
      if (await DataConnectionChecker().hasConnection) {
        // Wifi detected & internet connection confirmed.
        return true;
      } else {
        // Wifi detected but no internet connection found.
        return false;
      }
    } else {
      // Neither mobile data or WIFI detected, not internet connection found.
      return false;
    }
  }

  startTime() async {
    var _duration = Duration(seconds: 3);
    return Timer(_duration, checkFirstSeen);
  }

  Future checkFirstSeen() async {
    _fetchSessionAndNavigate();
  }

  _fetchSessionAndNavigate() async {
    if (kIsWeb) {
      if (_cid == null) {
        Navigator.of(context).pushReplacement(loginroute());
      } else if (_mail == null) {
        Navigator.of(context).pushReplacement(otproute());
      } else {
        getmypack();
      }
    } else {
      var isInternetEnable = await isInternet();
      if (isInternetEnable) {
        if (_cid == null) {
          Navigator.of(context).pushReplacement(loginroute());
        } else if (_mail == null) {
          Navigator.of(context).pushReplacement(otproute());
        } else {
          getmypack();
        }
      } else {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => NoConnection()));
      }
    }
  }

  getmypack() async {
    var url = Uri.parse(Urls.productionHost + Urls.myPacks);
    var request = http.MultipartRequest("POST", url);
    request.fields['cId'] = _cid!;
    var response = await request.send();
    var data = await response.stream.transform(utf8.decoder).join();
    if (_pid == null) {
      Navigator.of(context).pushReplacement(createprofileroute());
    } else if (data != "[]") {
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

  @override
  void initState() {
    super.initState();

    startTime();

    getcid().then(updatecid);
    getpId().then(updatepid);
    getcemail().then(updatemail);
  }

  updatecid(String id) {
    setState(() {
      _cid = id;
    });
  }

  updatepid(String id) {
    setState(() {
      _pid = id;
    });
  }

  updatemail(String id) {
    setState(() {
      _mail = id;
    });
  }

  String? _cid, _pid, _mail;

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
              color: blue.withOpacity(.8),
              image: DecorationImage(
                  colorFilter: ColorFilter.mode(
                      blue.withOpacity(.9), BlendMode.srcOver),
                  image: AssetImage("assets/img.png"),
                  fit: BoxFit.cover)),
          child: Column(
            children: <Widget>[
              Spacer(),
              Image.asset(
                'assets/App_Icon.png',
                width: width * .6,
              ),
              SizedBox(
                height: 10,
              ),
              // Text('My Gallery Book',
              //     style: Theme.of(context)
              //         .textTheme
              //         .bodyText1
              //         .copyWith(color: white)),
              Spacer(),
              // Text('Things End, But Memories Last Forever',
              //     style: Theme.of(context)
              //         .textTheme
              //         .caption
              //         .copyWith(color: white.withOpacity(.6))),
              // SizedBox(height: 10),
              Text('Powered by Mygallerybook',
                  style: Theme.of(context)
                      .textTheme
                      .caption
                      ?.copyWith(fontSize: 14, color: white)),
              SizedBox(height: 10),
            ],
          )),
    );
  }
}
