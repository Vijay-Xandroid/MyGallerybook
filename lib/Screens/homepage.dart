import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../Components/card.dart';
import '../Components/colors.dart';
import '../Components/mybutton.dart';
import '../Components/urls.dart';
import 'orderdetails.dart';
import '../Components/Routes.dart';
import '../Components/orderCard.dart';
import '../Components/sharedpref.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Future? getMetaData;
  Future? list;
  @override
  void initState() {
    super.initState();
    getMetaData = updateid();
  }

  String? _cid, date, expiredate;
  List orders = [];
  var packs;
  updateid() async {
    _cid = await getcid();
    await myOrders();
    list = myPack();
  }

  days() {
    final date2 = DateTime.parse('$expiredate');
    final date1 = DateTime.now();
    final differenceInDays = date2.difference(date1).inDays;
    setState(() {
      date = ((differenceInDays / 30).round()).toString();
    });
  }

  myOrders() async {
    var url = Uri.parse(Urls.productionHost + Urls.myOrder);
    var request = new http.MultipartRequest("POST", url);
    request.fields['cId'] = _cid!;
    var response = await request.send();
    var data = await response.stream.transform(utf8.decoder).join();
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setBool("initial", false);
    if (data != "[]") {
      try {
        orders = jsonDecode(data);
        print(orders);
      } catch (e) {
        print(e);
        orders = ["Error"];
      }
    } else {
      setState(() {
        print(data);
        orders = [];
      });
    }
  }

  Future<List?> myPack() async {
    var url = Uri.parse(Urls.productionHost + Urls.myPacks);
    var request = new http.MultipartRequest("POST", url);
    request.fields['cId'] = _cid!;
    var response = await request.send();
    String data1 = await response.stream.transform(utf8.decoder).join();
    var data = jsonDecode(data1);
    print(data);
    if (data != "[]") {
      setState(() {
        packs = data;
        expiredate = packs[packs.length - 1]["sEndDate"].split(' ')[0];
        days();
      });
      SharedPreferences pref = await SharedPreferences.getInstance();
      pref.setInt(
          "albumCount", int.parse(packs[packs.length - 1]["sRemainAlbums"]));
    } else {
      setState(() {
        packs = null;
      });
    }
  }

  late DateTime current;
  Future<bool> _onBackPressed() async {
    DateTime now = DateTime.now();
    if (current == null || now.difference(current) > Duration(seconds: 3)) {
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

  orderAlbums() {
    List<Widget> listOrdersUI = [];
    print(orders);
    for (var index = 0;
        index < (orders.length > 2 ? 2 : orders.length);
        index++) {
      listOrdersUI.add(OrderCard(
        album: orders[index]["albumId"],
        color: orders[index]["oStatus"] == "1"
            ? color1
            : orders[index]["oStatus"] == "5"
                ? green
                : color3,
        status: orders[index]["oStatus"] == "1"
            ? "Ordered"
            : orders[index]["oStatus"] == "2"
                ? "Received"
                : orders[index]["oStatus"] == "3"
                    ? "Printed"
                    : orders[index]["oStatus"] == "4"
                        ? "Dispatched"
                        : "Delivered",
        timages: orders[index]["NofoImages"],
        onPress: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => OrderDetails(
                        aid: orders[index]["aId"],
                        albumId: orders[index]["albumId"],
                        cid: _cid ?? "",
                        feedback: orders[index]["feedback"] ?? "",
                        pid: orders[index]["pId"],
                      )));
        },

        image1: orders[index]["UploadImages"].asMap().containsKey(0)
            ? orders[index]["UploadImages"][0]
            : "",
        //image1: orders[index]["UploadImages"][0],
        image2: orders[index]["UploadImages"].asMap().containsKey(1)
            ? orders[index]["UploadImages"][1]
            : "",
        // image2: orders[index]["UploadImages"][1],
        image3: orders[index]["UploadImages"].length > 2
            ? orders[index]["UploadImages"][2]
            : null,
      ));
    }

    return listOrdersUI;
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
          body: SafeArea(
        child: packs == null
            ? Center(child: CircularProgressIndicator())
            : ListView(
                children: [
                  FutureBuilder(
                      future: getMetaData,
                      builder: (context, snp) {
                        if (snp.hasError) {
                          //print("================================>${snp.hasError}");
                          //print(snp.hashCode);
                          return Wrap(
                            children: [
                              Center(
                                child: Container(
                                  alignment: Alignment.center,
                                  height: height * 1,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.signal_wifi_off,
                                        size: 80,
                                        color: blue,
                                      ),
                                      SizedBox(
                                        height: 30,
                                      ),
                                      Text(
                                        'Failed To Load the Data Please connect to internet and try again',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Colors.blue,
                                            fontSize: 20,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        } else {
                          if (snp.connectionState == ConnectionState.done) {
                            return Wrap(
                              children: <Widget>[
                                Container(
                                  width: width,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      SizedBox(
                                        height: height * .02,
                                      ),
                                      Text(
                                        'My Gallerybook 2.0',
                                        textScaleFactor: 01,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.copyWith(fontSize: width * .07),
                                      ),
                                      Text(
                                        'Things End but Memories Last Forever',
                                        textScaleFactor: 01,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(fontSize: width * .04),
                                      ),
                                      HomeCard(
                                        description:
                                            "${int.parse(date!) > 1 ? date! + " Months" : date! + " Month"} and ${packs[packs.length - 1]["sRemainAlbums"] == "1" ? packs[packs.length - 1]["sRemainAlbums"] + " Photobook" : packs[packs.length - 1]["sRemainAlbums"] + " Photobooks"} left",
                                        color: blue,
                                        expiredate: "$expiredate",
                                        onPress: () {
                                          Navigator.of(context)
                                              .push(templates());
                                        },
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Text(
                                              "My Recent Orders",
                                              textScaleFactor: 01,
                                              overflow: TextOverflow.ellipsis,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.copyWith(
                                                      fontSize: width * .055,
                                                      fontWeight:
                                                          FontWeight.bold),
                                            ),
                                            TextButton(
                                                onPressed: () {
                                                  Navigator.of(context)
                                                      .push(allOrders());
                                                },
                                                child: Text(
                                                  "All Orders",
                                                  textScaleFactor: 01,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall
                                                      ?.copyWith(
                                                          fontSize:
                                                              width * .04),
                                                ))
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                FutureBuilder(
                                    future: list,
                                    builder: (context, snapshot) {
                                      if (snapshot.hasError) {
                                        return PacksNotFound(height);
                                      } else if (snapshot.connectionState !=
                                          ConnectionState.done) {
                                        return LinearProgressIndicator();
                                      } else if (snapshot.connectionState ==
                                          ConnectionState.done) {
                                        return Column(
                                          children: [
                                            orders.isEmpty
                                                ? Center(
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 25.0),
                                                      child: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: <Widget>[
                                                          Image.asset(
                                                            "assets/empty.png",
                                                            width: width * .4,
                                                          ),
                                                          Text(
                                                            "No Photobooks Ordered Yet",
                                                            style: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .bodySmall
                                                                ?.copyWith(
                                                                    fontSize:
                                                                        width *
                                                                            .04,
                                                                    color: color1
                                                                        .withOpacity(
                                                                            .5)),
                                                          ),
                                                          SizedBox(
                                                              height:
                                                                  height * .02),
                                                          MyButton(
                                                            btntext:
                                                                "Start Creating",
                                                            color: blue,
                                                            textcolor: white,
                                                            onPress: packs[packs
                                                                            .length -
                                                                        1]["sRemainAlbums"] ==
                                                                    "0"
                                                                ? () {
                                                                    Navigator.of(
                                                                            context)
                                                                        .push(
                                                                            subscriptionpacks());
                                                                  }
                                                                : () {
                                                                    Feedback.forTap(
                                                                        context);
                                                                    HapticFeedback
                                                                        .lightImpact();
                                                                    Navigator.of(
                                                                            context)
                                                                        .push(
                                                                            pickimages());
                                                                  },
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  )
                                                : Column(
                                                    children:
                                                        orders[0] == "Error"
                                                            ? [
                                                                PacksNotFound(
                                                                  height,
                                                                )
                                                              ]
                                                            : orderAlbums()),
                                          ],
                                        );
                                      } else
                                        return IgnorePointer();
                                    }),
                              ],
                            );
                          } else {
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                        }
                      }),
                ],
              ),
      )),
    );
  }
}

PacksNotFound(height) => Container(
      alignment: Alignment.center,
      height: height * 0.5,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error,
            size: 80,
            color: red,
          ),
          SizedBox(
            height: 30,
          ),
          Text(
            'Failed To Load the Photobooks Data',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.red, fontSize: 20, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
