import 'dart:convert';
import 'dart:io';
import 'package:my_gallery_book/Components/Routes.dart';
import 'package:my_gallery_book/Components/colors.dart';
import 'package:my_gallery_book/Components/flushbar.dart';
import 'package:my_gallery_book/Components/mybutton.dart';
import 'package:my_gallery_book/Components/sharedpref.dart';
import 'package:my_gallery_book/Components/urls.dart';
import 'package:my_gallery_book/Screens/navbar.dart';
import 'package:my_gallery_book/Screens/orderdetails.dart';
import 'package:my_gallery_book/Screens/uploadindicator.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http_parser/http_parser.dart';
import '../Components/flushbar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class ReuploadImages extends StatefulWidget {
  var timages;
  var pid;
  var album;
  var aid;
  ReuploadImages(
      {@required this.timages,
      @required this.album,
      @required this.pid,
      @required this.aid});
  @override
  ReuploadImagesState createState() => new ReuploadImagesState();
}

class ReuploadImagesState extends State<ReuploadImages> {
  List<File> images = [];
  List<File> fileImageArray = [];
  List<Widget> imagesListUI = [];
  var isLoading = false;
  int sentbytes = 0;
  var aid;
  int totalbytes = 0;
  var album;
  double percentage = 1.0;
  int? _selectedItem;
  var details = [];
  String? uploadtext;
  @override
  void initState() {
    super.initState();
  }

  getLatestAlbum() async {
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

  buildGridView(context, images) {
    if (imagesListUI.length <= 20) {
      for (var i = 0; i < images.length; i++) {
        imagesListUI.add(Padding(
            padding: const EdgeInsets.all(1.0),
            child: InkWell(
              onTap: () {
                showDialog<void>(
                  context: context,
                  barrierDismissible: false, // user must tap button!
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('${basename(images[i].path)}'),
                      content: SingleChildScrollView(
                        child: ListBody(
                          children: <Widget>[
                            Image.file(
                              images[i],
                              height: 400,
                              width: 400,
                              fit: BoxFit.contain,
                            ),
                          ],
                        ),
                      ),
                      actions: <Widget>[
                        TextButton(
                          child: Text('Close'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              },
              child: Card(
                color: blue,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListTile(
                    leading: Icon(Icons.image, color: white),
                    title: Text(
                      "${basename(images[i].path)}",
                      style: TextStyle(color: white),
                    ),
                  ),
                ),
              ),
            )));
      }
      setState(() {
        imagesListUI = imagesListUI;
      });
    }
  }

  bool show = true;

  loadAssets(context) async {
    try {
      if (fileImageArray.length > 0 &&
          fileImageArray.length <= 25 &&
          (widget.timages + fileImageArray.length) < 100) {
        var result = await FilePicker.platform
            .pickFiles(allowMultiple: true, type: FileType.image);
        var files = result!.files.toList();
        for (var i = 0; i < result.files.length; i++) {
          fileImageArray.add(File(files[i].path!));
        }
      }

      if (fileImageArray.length == 0) {
        var result = await FilePicker.platform.pickFiles(
          allowMultiple: true,
          withData: true,
          type: FileType.image,
        );
        var files = result!.files.toList();
        if (files.length > 25) {
          flushBarshow("Uploading 25 Images is the Limit removing Extra Images",
              context, Colors.red);
          files.removeRange(25, files.length);
        }
        for (var i = 0; i < files.length; i++) {
          fileImageArray.add(File(files[i].path!));
        }
      }

      if ((widget.timages + fileImageArray.length) > 100) {
        var extraimages = (widget.timages + fileImageArray.length) - 100;
        extraimages = fileImageArray.length - extraimages;
        fileImageArray.removeRange(extraimages, fileImageArray.length);
        flushBarshow("Uploading 25 Images is the Limit removing Extra Images",
            context, Colors.red);
      }
      if (fileImageArray != null) {
        setState(() {
          images = fileImageArray;
          fileImageArray = fileImageArray;
          buildGridView(context, images);
        });

        return fileImageArray;
      }
    } on Exception catch (e) {
      print("cannot select the images $e");
    }
  }

  showConfirmationAlert(context1) {
    showDialog(
        context: context1,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Confirm Upload"),
            content: Text(
                "Are you sure do you want to continue to upload the images?"),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    uploadImages(context1);
                  },
                  child: Text("Confirm")),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("Cancel"))
            ],
          );
        });
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

  uploadImages(context) async {
    var url = Uri.parse(Urls.productionHost + Urls.albumOrder).toString();

    Dio dio = Dio();
    List filesarray = [];
    for (var i = 0; i < fileImageArray.length; i++) {
      filesarray.add(MultipartFile.fromFileSync(fileImageArray[i].path,
          filename: fileImageArray[i].path.split('/').last,
          contentType: MediaType(
              "image", fileImageArray[i].path.split('/').last.split(".")[1])));
    }
    var cid = await getcid();
    var pid = widget.pid;
    var formData = FormData.fromMap({
      "albumId": widget.album,
      "cId": cid,
      "aId": aid,
      "pId": pid,
      "image": filesarray,
    });
    print(formData.fields.toString());
    print(formData.files.toString());
    var response = await dio.post(url, data: formData,
        onSendProgress: (int sent, int total) {
      final progress = sent / total;
      setState(() {
        isLoading = true;
        sentbytes = sent;
        totalbytes = total;
        percentage = progress;
        percentage == 1.0
            ? uploadtext = "Please Wait, Accepting Order..."
            : uploadtext = "Uploading Images...";
      });
      print(progress);
    });
    if ((response.data)
        .toString()
        .toLowerCase()
        .contains("next month".toLowerCase())) {
      flushBarshow(response.data, context, color3);
      Future.delayed(const Duration(milliseconds: 2500), () {
        Navigator.of(context).pushReplacement(homepageroute());
      });
    } else if ((response.data)
        .toString()
        .toLowerCase()
        .contains("closed".toLowerCase())) {
      flushBarshow(response.data, context, color3);

      Future.delayed(const Duration(milliseconds: 2500), () {
        Navigator.of(context).pushReplacement(homepageroute());
      });
    } else if ((response.data)
        .toString()
        .contains(RegExp(r'Success', caseSensitive: false))) {
      flushBarshow(
          response.data.toString() + "Images Uploaded", context, green);
      Future.delayed(const Duration(milliseconds: 2000), () async {
        await _deleteAppDir();
        await _deleteCacheDir();
        var count = 0;
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => BottomBar()),
            (route) => route.settings.name == 'BottomBar');
      });
    } else {
      print(response.data);
      flushBarshow("Something Went Wrong", context, red);
    }
  }

  @override
  Widget build(BuildContext context) {
    album = widget.album;
    aid = widget.aid;
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop(true);
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("Order Album"),
          leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.of(context).pop(true);
              }),
        ),
        body: SafeArea(
            child: !isLoading
                ? ListView(
                    children: <Widget>[
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Center(
                              child: Column(
                                children: <Widget>[
                                  fileImageArray.length > 0
                                      ? Container()
                                      : MyButton(
                                          onPress: () async {
                                            loadAssets(context);
                                          },
                                          btntext: (widget.timages +
                                                      fileImageArray.length) >
                                                  0
                                              ? "Select More"
                                              : "Select images",
                                          color: blue,
                                          textcolor: white,
                                        ),
                                  SizedBox(height: 20),
                                  MyButton(
                                    onPress: fileImageArray.length > 0 &&
                                            (widget.timages +
                                                    fileImageArray.length) >=
                                                1
                                        ? () {
                                            showConfirmationAlert(context);
                                          }
                                        : () {
                                            flushBarshow(
                                                "Please Select Min. 1 Image, Max. of ${25} Images allowed",
                                                context,
                                                red);
                                          },
                                    btntext: "Order Album",
                                    color: blue,
                                    border: false,
                                    textcolor: blue,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          fileImageArray.length > 0
                              ? Column(children: [
                                  Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: RichText(
                                        text: TextSpan(
                                            style: TextStyle(
                                                fontSize: 25.0,
                                                color: Colors.black),
                                            children: <TextSpan>[
                                              TextSpan(
                                                  text: " Selected ",
                                                  style: TextStyle(
                                                      fontSize: 25,
                                                      color: Colors.blue)),
                                              TextSpan(
                                                  text:
                                                      "${fileImageArray.length} ",
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 30,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              TextSpan(
                                                  text: "Images",
                                                  style: TextStyle(
                                                      color: Colors.blue,
                                                      fontSize: 25.0))
                                            ]),
                                      ),
                                    ),
                                  ),
                                  Wrap(children: imagesListUI)
                                ])
                              : Container(),
                        ],
                      ),
                    ],
                  )
                : UploadIndicator(
                    uploadtext: uploadtext,
                    sentbytes: sentbytes,
                    percentage: percentage,
                    totalbytes: totalbytes)),
      ),
    );
  }
}
