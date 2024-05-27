import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:my_gallery_book/Components/Routes.dart';
import 'package:my_gallery_book/Components/addresscard.dart';
import 'package:my_gallery_book/Components/colors.dart';
import 'package:my_gallery_book/Components/flushbar.dart';
import 'package:my_gallery_book/Components/mybutton.dart';
import 'package:my_gallery_book/Components/sharedpref.dart';
import 'package:my_gallery_book/Components/textfeild.dart';
import 'package:my_gallery_book/Components/urls.dart';
import 'package:my_gallery_book/Screens/navbar.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';

class OrderAlbum extends StatefulWidget {
  const OrderAlbum({Key? key, required this.images}) : super(key: key);
  final List<File> images;
  @override
  State<OrderAlbum> createState() => _OrderAlbumState();
}

class _OrderAlbumState extends State<OrderAlbum> {
  var quantity = 1;
  var notes = TextEditingController();
  var count = 1;
  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((value) {
      setState(() {
        count = value.getInt("albumCount") ?? 1;
      });
    });
    setState(() {
      files = widget.images;
      print("fileimage array is $files");
    });
    getcid().then(updatecid);
    getcphone().then(updatephone);
  }

  updatephone(String id) {
    setState(() {
      phone = id;
    });
  }

  updatecid(String id) async {
    setState(() {
      cid = id;
      getProfile();
      getAddress();
      getsubscription();
    });
  }

  int? _selectedItem;

  Future<List<dynamic>> getLatestAlbum() async {
    var url = Uri.parse(Urls.productionHost + Urls.myOrder);
    var request = new http.MultipartRequest("POST", url);
    var _cid = await getcid();
    request.fields['cId'] = _cid;
    var response = await request.send();
    var data = await response.stream.transform(utf8.decoder).join();
    List orders = json.decode(data);
    return orders;
  }

  selectItem(index) {
    setState(() {
      _selectedItem = index;
      aid = details[index]["aId"];
      print("aid ==== $aid");
    });
  }

  bool _isLoading = false;
  double percentage = 0.0;
  int sentbytes = 0, totalbytes = 0;
  String? aid,
      pid,
      cid,
      profileDetail,
      phone,
      uploadtext = "Uploading Images...";

  var files;

  imagegs(context) async {
    if (aid == null) {
      flushBarshow("Please Select Delivery Address", context, red);
    } else {
      setState(() {
        _isLoading = true;
      });
      var url = Uri.parse(Urls.productionHost + Urls.albumOrder).toString();

      Dio dio = new Dio();
      List filesarray = [];
      for (var i = 0; i < files.length; i++) {
        filesarray.add(MultipartFile.fromFileSync(files[i].path,
            filename: files[i].path.split('/').last,
            contentType: new MediaType(
                "image", files[i].path.split('/').last.split(".")[1])));
        print(files[i].path.split('/').last);
        print(files[i].path.split('/').last.split(".")[1]);
      }

      var formData = FormData.fromMap({
        "cId": cid,
        "aId": aid,
        "pId": pid,
        "image": filesarray,
        "oQuantity": quantity,
        "oNote": notes.text == null ? "" : notes.text
      });
      var response = await dio.post(url, data: formData,
          onSendProgress: (int sent, int total) {
        final progress = sent / total;
        setState(() {
          sentbytes = sent;
          totalbytes = total;
          percentage = progress;
          percentage == 1.0
              ? uploadtext = "Please Wait, Accepting Order..."
              : uploadtext = "Uploading Images...";
        });
        print(progress);
      });
      print(response.data);
      if ((response.data)
          .toString()
          .toLowerCase()
          .contains("next month".toLowerCase())) {
        flushBarshow(response.data, context, color3);
        setState(() {
          _isLoading = false;
          uploadtext = response.data;
        });
        Future.delayed(const Duration(milliseconds: 2500), () {
          Navigator.of(context).pushReplacement(homepageroute());
        });
      } else if ((response.data)
          .toString()
          .toLowerCase()
          .contains("closed".toLowerCase())) {
        flushBarshow(response.data, context, color3);
        setState(() {
          _isLoading = false;
          uploadtext = response.data;
        });
        Future.delayed(const Duration(milliseconds: 2500), () {
          Navigator.of(context).pushReplacement(homepageroute());
        });
      } else if ((response.data)
          .toString()
          .contains(new RegExp(r'Success', caseSensitive: false))) {
        flushBarshow(
            response.data.toString() + "Images Uploaded", context, green);
        setState(() {
          _isLoading = false;
          uploadtext = response.data;
        });
        Future.delayed(const Duration(milliseconds: 2000), () async {
          await _deleteAppDir();
          await _deleteCacheDir();
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => BottomBar()),
              (route) => route.settings.name == 'BottomBar');
        });
      } else {
        print(response.data);
        flushBarshow("Something Went Wrong", context, red);
        setState(() {
          uploadtext = response.data;
        });
      }
    }
  }

  Future<void> _deleteCacheDir() async {
    final cacheDir = await getTemporaryDirectory();

    if (cacheDir.existsSync()) {
      cacheDir.deleteSync(recursive: true);
    }
  }

  Future<void> _deleteAppDir() async {
    final appDir = await getApplicationSupportDirectory();

    if (appDir.existsSync()) {
      appDir.deleteSync(recursive: true);
    }
  }

  var details = [], profile;

  getAddress() async {
    var url = Uri.parse(Urls.productionHost + Urls.getAddress);
    var request = new http.MultipartRequest("POST", url);
    request.fields['cId'] = cid!;
    var response = await request.send();
    var data = await response.stream.transform(utf8.decoder).join();
    if (data != "[]") {
      setState(() {
        details = jsonDecode(data);
      });
    } else {
      setState(() {
        details = [];
      });
      Navigator.of(context).push(createaddressroute());
    }
  }

  getsubscription() async {
    var url = Uri.parse(Urls.productionHost + Urls.myPacks);
    var request = new http.MultipartRequest("POST", url);
    request.fields['cId'] = cid!;
    var response = await request.send();
    var data = await response.stream.transform(utf8.decoder).join();
    if (data != "[]") {
      setState(() {
        var details = jsonDecode(data);
        pid = details[details.length - 1]["pId"];
      });
    }
  }

  getProfile() async {
    var url = Uri.parse(Urls.productionHost + Urls.getProfile);
    var request = new http.MultipartRequest("POST", url);
    request.fields['cId'] = cid!;
    var response = await request.send();
    var data = await response.stream.transform(utf8.decoder).join();
    if (data != null) {
      setState(() {
        profile = jsonDecode(data);
        profileDetail =
            "${profile["cFName"]} ${profile["cLName"]},\n$phone,\n${profile["cEmail"]}";
      });
    }
  }

  getAddressListUI() {
    List<Widget> listUI = [];
    for (var index = 0; index < details.length; index++) {
      listUI.add(CustomItem(
        selectItem: selectItem, // callback function, setstate for parent
        index: index,
        profileDetail: profileDetail ?? "",
        address:
            "${details[index]["cDoorNo"]},\n${details[index]["cStreet"]},\n${details[index]["cLandMark"]},\n${details[index]["cCity"]},\n${details[index]["cPincode"]} ",
        isSelected: _selectedItem == index ? true : false,
      ));
    }
    return listUI;
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: profile == null
          ? Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                SafeArea(
                  child: Container(
                    child: !_isLoading
                        ? Center(
                            child: Wrap(
                              children: <Widget>[
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Text(
                                      "Total Selected Images " +
                                          (widget.images.length).toString(),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                              color: black,
                                              fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 20),
                                Wrap(
                                  children: <Widget>[
                                    Center(
                                      child: Text(
                                        "Select Delivery Address",
                                        style: Theme.of(context)
                                            .textTheme
                                            .caption
                                            ?.copyWith(color: black),
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    details == null
                                        ? Center(
                                            child: GestureDetector(
                                            onTap: () {
                                              getAddress();
                                            },
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Container(
                                                  height: 50,
                                                  width: 50,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: black,
                                                  ),
                                                  child: Icon(Icons.refresh,
                                                      color: white),
                                                ),
                                                SizedBox(height: 10),
                                                Text(
                                                  "Click here to Load Address",
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .caption,
                                                )
                                              ],
                                            ),
                                          ))
                                        : Column(children: getAddressListUI()),
                                    SizedBox(height: 10),
                                    Center(
                                      child: MyButton(
                                        btntext: "Add New Address",
                                        border: false,
                                        color: blue,
                                        textcolor: blue,
                                        onPress: () {
                                          Navigator.of(context)
                                              .push(createaddressroute())
                                              .then((value) {
                                            getAddress();
                                          });
                                        },
                                      ),
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text("Quantity"),
                                        Text((count ?? 1).toString()),
                                        // Counter(
                                        //   initialValue: quantity,
                                        //   minValue: 1,
                                        //   maxValue: count ,
                                        //   step: 1,
                                        //   onChanged: (value) {
                                        //     setState(() {
                                        //       quantity = value.toInt();
                                        //     });
                                        //   },
                                        //   decimalPlaces: 0,
                                        // ),
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: MyTextFormField(
                                    icon: Icon(
                                      Icons.description,
                                      size: 30,
                                    ),
                                    hintText: "Description",
                                    maxlines: 4,
                                    controller: notes,
                                  ),
                                ),
                                SizedBox(
                                  height: 30,
                                ),
                                Center(
                                  child: MyButton(
                                    onPress: () {
                                      imagegs(context);
                                    },
                                    btntext: "Place Order",
                                    color: blue,
                                    textcolor: white,
                                  ),
                                ),
                                SizedBox(height: height * .1),
                                Center(
                                  child: MyButton(
                                    onPress: () {
                                      var count = 0;
                                      Navigator.popUntil(context, (route) {
                                        if (count == 2) {
                                          return true;
                                        } else {
                                          count++;
                                          return false;
                                        }
                                      });
                                    },
                                    btntext: "Cancel Order",
                                    border: false,
                                    color: Colors.transparent,
                                    textcolor: color1.withOpacity(.5),
                                  ),
                                ),
                                SizedBox(height: height * .12)
                              ],
                            ),
                          )
                        : Container(
                            height: MediaQuery.of(context).size.height * 0.95,
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  new CircularPercentIndicator(
                                      radius: 200.0,
                                      lineWidth: 30.0,
                                      animation: true,
                                      animateFromLastPercent: true,
                                      linearGradient: LinearGradient(
                                          colors: [
                                            blue.withOpacity(.6),
                                            darkBlue
                                          ],
                                          begin: Alignment.bottomLeft,
                                          end: Alignment.bottomRight,
                                          tileMode: TileMode.mirror),
                                      arcType: ArcType.FULL,
                                      addAutomaticKeepAlive: true,
                                      arcBackgroundColor:
                                          color1.withOpacity(.1),
                                      backgroundWidth: 0.0,
                                      curve: Curves.slowMiddle,
                                      circularStrokeCap:
                                          CircularStrokeCap.round,
                                      percent: percentage,
                                      header: new Text(uploadtext ?? "",
                                          style: Theme.of(context)
                                              .textTheme
                                              .caption
                                              ?.copyWith(fontSize: 23)),
                                      footer: Text(
                                        "${(sentbytes * 0.00000095367432).toStringAsFixed(2)} MB / ${(totalbytes * 0.00000095367432).toStringAsFixed(2)} MB",
                                        style: Theme.of(context)
                                            .textTheme
                                            .caption
                                            ?.copyWith(fontSize: 18),
                                      ),
                                      center: percentage == 1.0
                                          ? Icon(
                                              Icons.cloud_done,
                                              color: darkBlue.withOpacity(.6),
                                              size: 80,
                                            )
                                          : Text(
                                              (percentage * 100)
                                                      .toStringAsFixed(1) +
                                                  "%",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .caption
                                                  ?.copyWith(fontSize: 23)),
                                      backgroundColor: Colors.transparent),
                                ]),
                          ),
                  ),
                ),
              ],
            ),
    );
  }
}

class MultipartRequest extends http.MultipartRequest {
  MultipartRequest(
    String method,
    Uri url, {
    required this.onProgress,
  }) : super(method, url);

  final void Function(int bytes, int totalBytes) onProgress;

  http.ByteStream finalize() {
    final byteStream = super.finalize();
    if (onProgress == null) return byteStream;

    final total = this.contentLength;
    int bytes = 0;

    final t = StreamTransformer.fromHandlers(
      handleData: (List<int> data, EventSink<List<int>> sink) {
        bytes += data.length;
        onProgress(bytes, total);
        sink.add(data);
      },
    );
    final stream = byteStream.transform(t);
    return http.ByteStream(stream);
  }
}
