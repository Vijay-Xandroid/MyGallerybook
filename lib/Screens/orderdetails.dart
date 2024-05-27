import 'dart:async';
import 'dart:convert';
import 'package:my_gallery_book/Components/addresscard.dart';
import 'package:my_gallery_book/Components/flushbar.dart';
import 'package:my_gallery_book/Components/sharedpref.dart';
import 'package:my_gallery_book/Screens/reuploadimages.dart';
import 'package:my_gallery_book/widgets/directly_used_packages/flutter_counter/flutter_counter.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
//import 'package:flutter_counter/flutter_counter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../Components/colors.dart';
import '../Components/urls.dart';

class OrderDetails extends StatefulWidget {
  const OrderDetails(
      {Key? key,
      required this.cid,
      required this.aid,
      required this.albumId,
      required this.feedback,
      required this.pid})
      : super(key: key);
  final String cid;
  final String aid;
  final String albumId;
  final String feedback;
  final String pid;
  @override
  State<OrderDetails> createState() => _OrderDetailsState();
}

class _OrderDetailsState extends State<OrderDetails> {
  var count = 1;
  updatephone(String id) {
    SharedPreferences.getInstance().then((value) {
      setState(() {
        count = value.getInt("albumCount")!;
      });
    });
    setState(() {
      phone = id;
    });
  }

  late List images;
  var pid;
  var aid;
  late String oStatus, phone;
  var orders, address, profile;
  Dio dio = Dio();
  late int length;
  var quantity = 1;
  final String url =
      Uri.parse(Urls.productionHost + Urls.orderimages).toString();

  Future? orderDetailsFuture;
  Future? profileDetailsFuture;
  Future? deliveryDetailsFuture;

  @override
  void initState() {
    super.initState();
    orderDetailsFuture = orderDetails();
    deliveryDetailsFuture = deliveryDetails();
    profileDetailsFuture = profileDetails();
    getcphone().then(updatephone);
  }

  getImages() {
    String html = """
    <head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    </head>
    <div style="display:flex;flex-direction:row;flex-wrap:wrap;justify-content:space-evenly;">
    """;
    for (var i = 0; i < images.length; i++) {
      html = html +
          "<img src='$url/${images[i]}' height='120' width='120' style='padding:3px'/>";
    }
    html = html + '</div>';
    return html;
  }

  Widget buildGridView() {
    // return GridView.count(
    //   crossAxisCount: 4,
    //   crossAxisSpacing: 5,
    //   mainAxisSpacing: 5,
    //   padding: EdgeInsets.symmetric(horizontal: 10),
    //   children: List.generate(images.length, (index) {
    //     return Image.network(
    //       "$url/${images[index]}",
    //       width: 200,
    //       height: 200,
    //       fit: BoxFit.cover,
    //     );
    //   }),
    // );

    return InAppWebView(
      initialData: InAppWebViewInitialData(data: getImages()),
    );
  }

  showWidgets(height, width, context, status, album) {
    var widget;
    if (status == "Delivered") {
      widget = Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Quantity"),
                  Counter(
                    initialValue: quantity,
                    minValue: 1,
                    maxValue: count,
                    color: blue,
                    step: 1,
                    onChanged: (value) {
                      quantity = value.toInt();
                      (context as Element).markNeedsBuild();
                    },
                    decimalPlaces: 0,
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: width * 0.28,
              height: 40,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: ContinuousRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  elevation: 6,
                  backgroundColor: blue,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Text(
                    "Reorder",
                    style: TextStyle(fontSize: 17, color: Colors.white),
                  ),
                ),
                onPressed: () async {
                  var pid = await getpId();
                  var formData = FormData.fromMap({
                    "pId": pid,
                    "oReorder": quantity,
                    "albumId": widget.album
                  });
                  try {
                    var response = await dio.post(
                        Urls.productionHost + Urls.reOrder,
                        data: formData);
                    if (response.data.toString().trim() == "Reorder Success") {
                      flushBarshow(
                          "Photobook reorder is successfull", context, green);
                    } else {
                      flushBarshow(
                          "Photobook reorder is failed because your leftover albums are low",
                          context,
                          red);
                    }
                  } catch (e) {
                    flushBarshow(
                        "Something went wrong while reordering the photobook",
                        context,
                        red);
                  }
                },
              ),
            ),
          ),
        ],
      );
    } else if (status == "Ordered") {
      widget = images.length < 100
          ? Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                height: 40,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: ContinuousRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                    elevation: 6,
                    backgroundColor: blue,
                  ),
                  child: Text(
                    "Add More Images",
                    style: TextStyle(fontSize: 15, color: Colors.white),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => ReuploadImages(
                            pid: pid,
                            aid: aid,
                            timages: images.length,
                            album: album)));
                  },
                ),
              ),
            )
          : Container();
    } else if (status == "Dispatched") {
      widget = Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          height: 40,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: ContinuousRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
              elevation: 6,
              backgroundColor: blue,
            ),
            child: Text(
              "Track Order",
              style: TextStyle(fontSize: 15, color: Colors.white),
            ),
            onPressed: () async {
              try {
                var formdata = FormData.fromMap({"albumId": album});
                Response response = await dio.post(
                    Urls.productionHost + Urls.orderTracking,
                    data: formdata);
                var data = jsonDecode(response.toString());
                print(data.toString());
                if (await canLaunch(Urls.courierUrl + data["courierTI"])) {
                  await launch(Urls.courierUrl + data["courierTI"]);
                } else {
                  flushBarshow(
                      "Cannot able to launch the browser please try again later",
                      context,
                      red);
                }
              } catch (e) {
                print(e);
                flushBarshow("Cannot able to track the order try again later",
                    context, red);
              }
            },
          ),
        ),
      );
    }
    return widget;
  }

  orderDetails() async {
    var url = Uri.parse(Urls.productionHost + Urls.myOrderDetails);
    var request = new http.MultipartRequest("POST", url);
    request.fields['cId'] = widget.cid;
    request.fields['albumId'] = widget.albumId;
    var response = await request.send();
    var data = await response.stream.transform(utf8.decoder).join();
    if (data != null) {
      setState(() {
        orders = jsonDecode(data);
        oStatus = orders["oStatus"];
        images = orders["UploadImages"];
      });
    }
  }

  selectItem(index) {}
  getStatus(status) {
    print(status);
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

  deliveryDetails() async {
    var url = Uri.parse(Urls.productionHost + Urls.addressdetail);
    var request = new http.MultipartRequest("POST", url);
    request.fields['aId'] = widget.aid;
    var response = await request.send();
    var data = await response.stream.transform(utf8.decoder).join();
    if (data != null) {
      setState(() {
        address = jsonDecode(data);
      });
    }
  }

  profileDetails() async {
    var url = Uri.parse(Urls.productionHost + Urls.getProfile);
    var request = new http.MultipartRequest("POST", url);
    request.fields['cId'] = widget.cid;
    var response = await request.send();
    var data = await response.stream.transform(utf8.decoder).join();
    if (data != null) {
      print(data);
      setState(() {
        profile = jsonDecode(data);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    pid = widget.pid;
    aid = widget.aid;
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop(true);
        return true;
      },
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
          title: Text(widget.albumId,
              textScaleFactor: 01,
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(fontSize: 20, color: white)),
        ),
        backgroundColor: white,
        body: FutureBuilder(
            future: Future.wait([
              orderDetailsFuture,
              profileDetailsFuture,
              deliveryDetailsFuture,
            ].cast()), // listOfFutures.cast<Future<dynamic>>()
            builder: (context, snp) {
              if (snp.connectionState == ConnectionState.done) {
                return Column(
                  children: <Widget>[
                    orders == null
                        ? Expanded(
                            child: Center(child: CircularProgressIndicator()))
                        : Column(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.all(15),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          widget.albumId,
                                          textScaleFactor: 01,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w600),
                                        ),
                                        Container(
                                          margin: EdgeInsets.only(top: 3),
                                          child: Text(
                                            "${images.length} Uploaded",
                                            textScaleFactor: 01,
                                            style: Theme.of(context)
                                                .textTheme
                                                .caption,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 15, vertical: 05),
                                          decoration: BoxDecoration(
                                              color: oStatus == "1"
                                                  ? color1
                                                  : oStatus == "5"
                                                      ? green
                                                      : color3,
                                              borderRadius:
                                                  BorderRadius.circular(20)),
                                          child: Center(
                                            child: Text(
                                              getStatus(oStatus),
                                              textScaleFactor: 01,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .caption
                                                  ?.copyWith(color: white),
                                            ),
                                          ),
                                        ),

                                        Container(
                                          margin: EdgeInsets.only(top: 3),
                                          child: Text(
                                            "${100 - images.length} remaining",
                                            textScaleFactor: 01,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall,
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                              profile == null || address == null
                                  ? CircularProgressIndicator()
                                  : CustomItem(
                                      selectItem: selectItem,
                                      index: 1,
                                      isSelected: true,
                                      profileDetail:
                                          "${profile["cFName"]} ${profile["cLName"]},\n$phone,\n${profile["cEmail"]}",
                                      address:
                                          "${address["cDoorNo"]},\n${address["cStreet"]},\n${address["cLandMark"]},\n${address["cCity"]},\n${address["cPincode"]} ",
                                    )
                            ],
                          ),
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Container(
                        child: showWidgets(height, width, context,
                            getStatus(oStatus), widget.albumId),
                      ),
                    ),
                    orders != null
                        ? Expanded(child: buildGridView())
                        : Container(),
                  ],
                );
              } else if (snp.connectionState == ConnectionState.waiting) {
                return LinearProgressIndicator(
                  minHeight: 7,
                );
              } else if (snp.hasError) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      alignment: Alignment.center,
                      height: height * 0.5,
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
                  ],
                );
              } else
                return Container();
            }),
      ),
    );
  }
}
