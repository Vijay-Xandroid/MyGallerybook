import 'dart:io';
import 'package:my_gallery_book/Components/colors.dart';
import 'package:my_gallery_book/Components/flushbar.dart';
import 'package:my_gallery_book/Components/mybutton.dart';
import 'package:my_gallery_book/Screens/orderAlbum.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:file_picker/file_picker.dart';
import '../Components/flushbar.dart';
import 'package:system_info/system_info.dart';
import 'package:path_provider/path_provider.dart';

class ImagesPicker extends StatefulWidget {
  @override
  ImagesPickerState createState() => new ImagesPickerState();
}

class ImagesPickerState extends State<ImagesPicker> {
  List<File> images = [];
  List<File> fileImageArray = [];
  List<Widget> imagesListUI = [];
  var isLoading = false;
  late int ram;

  @override
  void initState() {
    super.initState();
    showDeviceLowSpecAlert();
  }

  showDeviceLowSpecAlert() async {
    ram = SysInfo.getTotalPhysicalMemory();
    ram = ram ~/ 1024;
    ram = ram ~/ 1024;
    ram = ram ~/ 1024;
    await _deleteCacheDir();
    await _deleteAppDir();
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

  alertDialogOfLowSpecUI(context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Phone Low Specification"),
            content: Text(
                "Your phone has the less system requirement at running this app. so upload the images 25 at a time"),
            actions: [
              TextButton(
                  onPressed: () {
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
                  child: Text('No')),
              SizedBox(
                width: 10,
              ),
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    loadAssets(context);
                  },
                  child: Text('Yes'))
            ],
          );
        });
  }

  buildGridView(context) {
    imagesListUI = [];
    print("inside the fileupload");
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
    // List<Asset> resultList = List<Asset>();
    // String error = 'No Error Dectected';
    // try {
    //   resultList = await MultiImagePicker.pickImages(
    //     maxImages: 100,
    //     enableCamera: true,
    //     selectedAssets: images,
    //     cupertinoOptions: CupertinoOptions(takePhotoIcon: "chat"),
    //     materialOptions: MaterialOptions(
    //       actionBarColor: "#006DFB",
    //       actionBarTitle: "My Gallery Book",
    //       allViewTitle: "All Photos",
    //       useDetailsView: false,
    //       selectCircleStrokeColor: "#006DFB",
    //     ),
    //   );
    // } on Exception catch (e) {
    //   error = e.toString();
    // }
    // if (!mounted) return;

    // resultList.forEach((imageAsset) async {
    //   setState(() {
    //     fileImageArray = [];
    //   });
    //   final filePath =
    //       await FlutterAbsolutePath.getAbsolutePath(imageAsset.identifier);

    //   File tempFile = File(filePath);
    //   if (tempFile.existsSync()) {
    //     fileImageArray.add(tempFile);
    //   }

    //   return fileImageArray;
    // });

    // setState(() {
    //   images = resultList;
    //   error = error;
    // });
    try {
      if (fileImageArray.length > 0 && fileImageArray.length < 25) {
        var result = await FilePicker.platform.pickFiles(
          allowMultiple: true,
          type: FileType.image,
        );
        // var files = result.paths.map((path) => File(path));
        var files = result!.files.toList();
        for (var i = 0; i < result.files.length; i++) {
          fileImageArray.add(File(files[i].path!));
        }
      }

      if (fileImageArray.length == 0) {
        var result = await FilePicker.platform.pickFiles(
          allowMultiple: true,
          type: FileType.image,
        );
        var files = result!.files.toList();
        for (var i = 0; i < files.length; i++) {
          fileImageArray.add(File(files[i].path!));
        }
      }

      if (fileImageArray.length > 25) {
        fileImageArray.removeRange(25, fileImageArray.length);
        flushBarshow(
            "Uploading 25 Images is the limit for uploading at a time removing the extra images",
            context,
            Colors.red);
      }

      //var i = 0;
      // fileImageArray.map((e) async {
      //   var name = basename(e.path);
      //   var ext = name.split(".")[1];
      //   if (ext.toLowerCase() == "heic") {
      //     // String jpegPath = await HeicToJpg.convert(e.path);
      //     //var file = File(jpegPath);
      //  //  fileImageArray[i] = file;
      //   } else {
      //     fileImageArray[i] = e;
      //   }
      //  i++;
      // });
      if (fileImageArray != null) {
        setState(() {
          images = fileImageArray;
          fileImageArray = fileImageArray;
          buildGridView(context);
        });

        return fileImageArray;
      }
    } on Exception catch (e) {
      print("cannot select the images $e");
    }
  }

  showConfirmationAlert(context) {

    showDialog(
        context: context,

        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Confirm Upload"),
            content: Text(
                "Are you sure do you want to continue to upload the images?"),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => OrderAlbum(
                                  images: fileImageArray,
                                )));
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop(true);
        return true;
      },
      child: new Scaffold(
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
          child: ListView(
            children: <Widget>[
              Center(
                  child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("Upload Images 25 out of 100 at a time"),
              )),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Center(
                      child: Column(
                        children: <Widget>[
                          MyButton(
                            onPress: () {
                              if (ram < 4) {
                                alertDialogOfLowSpecUI(context);
                              } else {
                                loadAssets(context);
                              }
                            },
                            btntext: fileImageArray.length > 0
                                ? "Select More"
                                : "Select images",
                            color: blue,
                            textcolor: white,
                          ),
                          SizedBox(height: 20),
                          if(fileImageArray.length > 0)  MyButton(
                            onPress: fileImageArray.length >= 1
                                ? () {
                                    showConfirmationAlert(context);
                                  }
                                : () {
                                    flushBarshow(
                                        "Please Select Min. 1 Image, Max. of 25 Images alloweda at a time",
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
                                        fontSize: 25.0, color: Colors.black),
                                    children: <TextSpan>[
                                      TextSpan(
                                          text: " Selected ",
                                          style: TextStyle(
                                              fontSize: 25,
                                              color: Colors.blue)),
                                      TextSpan(
                                          text: "${fileImageArray.length} ",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 30,
                                              fontWeight: FontWeight.bold)),
                                      TextSpan(
                                          text: "Images",
                                          style: TextStyle(
                                              color: Colors.blue,
                                              fontSize: 25.0))
                                    ]),
                              ),
                            ),
                          ),
                          isLoading
                              ? CircularProgressIndicator()
                              : Wrap(children: imagesListUI)
                        ])
                      : Container(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
