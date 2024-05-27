import 'dart:io';

import 'package:my_gallery_book/Components/Routes.dart';
import 'package:my_gallery_book/Components/mybutton.dart';
import 'package:my_gallery_book/Components/popup.dart';
import 'package:my_gallery_book/Components/profilemodel.dart';
import 'package:my_gallery_book/Screens/createaddress.dart';
import 'package:my_gallery_book/Screens/createprofile.dart';
import 'package:my_gallery_book/Screens/login.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Components/flushbar.dart';
import '../Components/sharedpref.dart';
import '../Components/urls.dart';
import '../Components/colors.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  Future? getMetaDataFuture;
  @override
  void initState() {
    super.initState();
    getMetaDataFuture = getMetaData();
  }

  File? _image;

  var details, addresses;
  final GlobalKey<FormState> formData = GlobalKey<FormState>();

  var urls = Uri.parse(Urls.productionHost + Urls.profileimages);

  getMetaData() async {
    cid = await getcid();
    _phone = await getcphone();
    await getProfile();
    await getAddress();
  }

  ProfileModel profile = ProfileModel();

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  String? cid, _phone;
  var address = [];
  bool isenable = false;

  getAddress() async {
    var url = Uri.parse(Urls.productionHost + Urls.getAddress);
    var request = new http.MultipartRequest("POST", url);
    request.fields['cId'] = cid!;
    var response = await request.send();
    var data = await response.stream.transform(utf8.decoder).join();
    if (data != "[]") {
      setState(() {
        address = jsonDecode(data);
      });
    } else {
      setState(() {
        details = null;
      });
      // Navigator.of(context).push(createaddressroute());
    }
  }

  getProfile() async {
    var url = Uri.parse(Urls.productionHost + Urls.getProfile);
    var request = new http.MultipartRequest("POST", url);
    request.fields['cId'] = cid!;
    var response = await request.send();
    var data = await response.stream.transform(utf8.decoder).join();
    print(data);
    if (data != null) {
      setState(() {
        details = jsonDecode(data);
      });
      setUserName(details);
    } else {
      flushBarshow("Something went Wrong", context, red);
    }
  }

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

  getAddressListUI() {
    List<Widget> addresses = [];
    print(address);
    if (address != null) {
      for (var index = 0; index < address.length; index++) {
        addresses.add(Card(
          elevation: 6,
          color: blue,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              child: ListTile(
                leading: Icon(Icons.location_city, size: 30, color: white),
                title: Text(
                  "${address[index]["cDoorNo"]}, ${address[index]["cStreet"]}, ${address[index]["cLandMark"].trim()}, ${address[index]["cCity"]},${address[index]["cPincode"]} ",
                  style: TextStyle(fontSize: 17, color: white),
                ),
              ),
            ),
          ),
        ));
      }
    }
    if (addresses.length == null || addresses.length == 0) {
      addresses.add(Container());
    }
    return addresses;
  }

  updateProfile() async {
    if (formData.currentState!.validate()) {
      formData.currentState!.save();
      var url = Uri.parse(Urls.productionHost + Urls.createProfile);
      var request = MultipartRequest(
        "POST",
        url,
        onProgress: (int bytes, int total) {
          final progress = bytes / total;
          print('progress: $progress ($bytes/$total)');
        },
      );
      request.fields['cId'] = await getcid();
      request.fields['cFName'] = profile.fName!;
      request.fields['cLName'] = profile.lName!;
      request.fields['cGender'] = details["cGender"];
      request.fields['cEmail'] = profile.emailId!;
      if (_image != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'cPicture',
          _image!.path,
        ));
      }

      var response = await request.send();
      var data = await response.stream.transform(utf8.decoder).join();
      print(data);
      if (data != null) {
        var details;
        setState(() {
          details = jsonDecode(data);
        });
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString("pId", details["pId"]);
        prefs.setString("eMail", details["cEmail"]);
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (BuildContext context) => super.widget));
      } else {
        flushBarshow("Something went Wrong", context, red);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        backgroundColor: white,
        body: FutureBuilder(
            future: getMetaDataFuture,
            builder: (BuildContext context, AsyncSnapshot snp) {
              if (snp.hasError) {
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
              } else if (snp.connectionState == ConnectionState.done) {
                return ListView(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(top: 30),
                      height: height * .16,
                      width: width,
                      decoration: BoxDecoration(
                          color: blue,
                          borderRadius: BorderRadius.vertical(
                              bottom: Radius.circular(30))),
                      child: Center(
                        child: Text(
                          "My Profile",
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(
                                  color: white,
                                  fontSize: width * .07,
                                  fontWeight: FontWeight.w100,
                                  letterSpacing: .5),
                        ),
                      ),
                    ),
                    details == null
                        ? Center(
                            child: Padding(
                            padding: const EdgeInsets.only(top: 20.0),
                            child: Container(
                                margin: EdgeInsets.only(top: 20),
                                child: LinearProgressIndicator(
                                  minHeight: 5,
                                )),
                          ))
                        : Column(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 10.0, right: 30),
                                child: Container(
                                  alignment: Alignment.centerRight,
                                  child: IconButton(
                                    icon: Icon(Icons.edit),
                                    color: isenable ? Colors.blue : Colors.grey,
                                    onPressed: () {
                                      setState(() {
                                        isenable = !isenable;
                                      });
                                    },
                                  ),
                                ),
                              ),
                              Form(
                                key: formData,
                                child: Wrap(
                                  children: <Widget>[
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          vertical: width * 0.15,
                                          horizontal: 8),
                                      child: InkWell(
                                        onTap: isenable
                                            ? () async {
                                                var image = await ImagePicker()
                                                    .pickImage(
                                                        source: ImageSource
                                                            .gallery);
                                                setState(() {
                                                  _image = File(image!.path);
                                                });
                                              }
                                            : () {},
                                        child: Container(
                                          width: width * 0.25,
                                          height: height * 0.18,
                                          decoration: BoxDecoration(
                                              color: white,
                                              image: DecorationImage(
                                                  fit: BoxFit.cover,
                                                  image: AssetImage(
                                                      "assets/profile.png")),
                                              border: Border.all(
                                                  color: blue, width: 2),
                                              boxShadow: [
                                                BoxShadow(
                                                    color:
                                                        black.withOpacity(.2),
                                                    offset: Offset(5, 5),
                                                    blurRadius: 10)
                                              ]),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 35.0),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Container(
                                              width: width * 0.6,
                                              child: TextFormField(
                                                enabled: isenable,
                                                initialValue: details["cFName"],
                                                validator: (value) {
                                                  if (value == "") {
                                                    return "Pleae enter the first name";
                                                  }
                                                },
                                                onSaved: (value) {
                                                  profile.fName = value;
                                                },
                                                decoration: InputDecoration(
                                                  border: isenable
                                                      ? OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                                  width: 1))
                                                      : InputBorder.none,
                                                  labelText: "First Name",
                                                ),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Container(
                                              width: width * 0.6,
                                              child: TextFormField(
                                                enabled: isenable,
                                                initialValue: details["cLName"],
                                                validator: (value) {
                                                  if (value == "") {
                                                    return "Pleae enter the last name";
                                                  }
                                                },
                                                onSaved: (value) {
                                                  profile.lName = value;
                                                },
                                                decoration: InputDecoration(
                                                  border: isenable
                                                      ? OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                                  width: 1))
                                                      : InputBorder.none,
                                                  labelText: "Last Name",
                                                ),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Container(
                                              width: width * 0.6,
                                              child: TextFormField(
                                                enabled: isenable,
                                                initialValue: details["cEmail"],
                                                validator: (value) {
                                                  if (value == "") {
                                                    return "Pleae enter the email";
                                                  }
                                                },
                                                onSaved: (value) {
                                                  profile.emailId = value;
                                                },
                                                decoration: InputDecoration(
                                                  border: isenable
                                                      ? OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                                  width: 1))
                                                      : InputBorder.none,
                                                  labelText: "Email",
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 20),
                              isenable
                                  ? Container(
                                      height: 50,
                                      width: width * 0.6,
                                      child: ElevatedButton(
                                        // shape: StadiumBorder(),

                                        style: ElevatedButton.styleFrom(
                                          shape: StadiumBorder(),
                                          backgroundColor: blue,
                                        ),
                                        onPressed: () {
                                          updateProfile();
                                        },
                                        child: Text("Update",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 18)),
                                      ),
                                    )
                                  : Container(),
                              SizedBox(height: 15),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Text(
                                      "My Addresses",
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0),
                                    child: Container(
                                      height: 40,
                                      padding:
                                          EdgeInsets.only(left: 20, right: 20),
                                      child: ElevatedButton(
                                        // shape: StadiumBorder(),

                                        style: ElevatedButton.styleFrom(
                                          shape: StadiumBorder(),
                                          backgroundColor: blue,
                                        ),
                                        onPressed: () {
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      CreateAddress()));
                                        },
                                        child: Text("Add Address",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 18)),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.max,
                                  children: getAddressListUI(),
                                ),
                              )
                            ],
                          )
                  ],
                );
              } else {
                return Wrap(
                  children: [
                    Center(
                        child: LinearProgressIndicator(
                      minHeight: 10,
                    ))
                  ],
                );
              }
            }),
      ),
    );
  }
}

String? validateEmail(String value) {
  var pattern =
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
  RegExp regex = RegExp(pattern);
  if (!regex.hasMatch(value))
    return 'Enter Valid Email';
  else
    return null;
}
