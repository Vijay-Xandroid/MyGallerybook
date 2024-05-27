import 'dart:convert';
import 'package:my_gallery_book/Screens/orderdetails.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../Components/orderCard.dart';
import '../Components/sharedpref.dart';
import '../Components/urls.dart';
import '../Components/colors.dart';

class AllOrders extends StatefulWidget {
  const AllOrders({Key? key}) : super(key: key);

  @override
  State<AllOrders> createState() => _AllOrdersState();
}

class _AllOrdersState extends State<AllOrders> {
  @override
  void initState() {
    super.initState();
    getcid().then(updateid);
  }

  String? _cid, oStatus;
  var orders;

  bool loading = true;

  updateid(String id) async {
    setState(() {
      _cid = id;
      myOrders();
    });
  }

  myOrders() async {
    var url = Uri.parse(Urls.productionHost + Urls.myOrder);
    var request = new http.MultipartRequest("POST", url);
    request.fields['cId'] = _cid!;
    var response = await request.send();
    var data = await response.stream.transform(utf8.decoder).join();
    if (data != "[]") {
      setState(() {
        orders = jsonDecode(data);
        oStatus = orders[0]["oStatus"];
      });
    } else {
      setState(() {
        orders = null;
      });
    }
    setState(() {
      loading = false;
    });
    print(orders);
  }

  getStatus(status) {
    switch (status) {
      case "1":
        return "Ordered";
      case "2":
        return "Received";
      case "3":
        return "Printed";
      case "4":
        return "Dispatched";
      case "5":
        return "Delivered";
      default:
        return "Ordered";
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop(true);
        return false;
      },
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white,
                ),
                onPressed: () {
                  Navigator.of(context).pop(true);
                }),
            title: Text('My Orders',
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(fontSize: 20, color: white)),
          ),
          backgroundColor: white,
          body: Column(
            children: <Widget>[
              Expanded(
                child: loading
                    ? Center(child: CircularProgressIndicator())
                    : orders == null
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Image.asset("assets/empty.png"),
                                Text(
                                  "No Albums Ordered Yet",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                          fontSize: 18,
                                          color: color1.withOpacity(.5)),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: orders.length,
                            itemBuilder: (BuildContext context, int index) {
                              var status = orders[index]["oStatus"];

                              // print(
                              //     "orders[index].length is ${orders[index]["UploadImages"].length}");
                              // print(
                              //     "img1 is ${orders[index]["UploadImages"][0]}");
                              // print(
                              //     "img2 is ${orders[index]["UploadImages"][1]}");
                              // print(
                              //     "img3 is ${orders[index]["UploadImages"][2]}");

                              return OrderCard(
                                album: orders[index]["albumId"],
                                color: orders[index]["oStatus"] == "1"
                                    ? color1
                                    : orders[index]["oStatus"] == "5"
                                        ? green
                                        : color3,
                                status: getStatus(status),
                                timages: orders[index]["NofoImages"],
                                onPress: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => OrderDetails(
                                                aid: orders[index]["aId"],
                                                pid: orders[index]["pId"],
                                                albumId: orders[index]
                                                    ["albumId"],
                                                cid: _cid ?? "",
                                                feedback: orders[index]
                                                        ["feedback"] ??
                                                    "",
                                              )));
                                },
                                image1: orders[index]["UploadImages"][0],
                                image2: orders[index]["UploadImages"].length> 1 ?orders[index]["UploadImages"][1]: null,
                                image3:  orders[index]["UploadImages"].length> 2 ?orders[index]["UploadImages"][2]: null,
                              );
                            }),
              )
            ],
          ),
        ),
      ),
    );
  }
}
