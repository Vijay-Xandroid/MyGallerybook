import 'dart:async';

import 'package:my_gallery_book/Components/Routes.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import '../Components/flushbar.dart';
import '../Components/mybutton.dart';
import '../Components/popup.dart';
import '../Components/profilemodel.dart';
import '../Components/sharedpref.dart';
import '../Components/textfeild.dart';
import '../Components/urls.dart';
import '../Components/colors.dart';

class CreateProfile extends StatefulWidget {
  const CreateProfile({Key? key}) : super(key: key);

  @override
  State<CreateProfile> createState() => _CreateProfileState();
}

class _CreateProfileState extends State<CreateProfile> {
  File? _image;
  @override
  void initState() {
    super.initState();
    getcid().then(updateid);
    addImage();
  }

  updateid(String id) {
    setState(() {
      cid = id;
      print(cid);
    });
  }

  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  ProfileModel profile = ProfileModel();
  String? genderSelected, cid;

  addImage() async {
    _image = await getImageFileFromAssets('profile.png');
  }

  final picker = ImagePicker();
  Future<File> getImageFileFromAssets(String path) async {
    final byteData = await rootBundle.load('assets/$path');

    final file = File('${(await getTemporaryDirectory()).path}/$path');
    await file.writeAsBytes(byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

    return file;
  }

  Future getImage() async {
    setState(() {
      _image = null;
    });

    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      _image = File(pickedFile!.path);
    });
  }

  createProfile() async {
    poPup(context);
    var url = Uri.parse(Urls.productionHost + Urls.createProfile);
    var request = MultipartRequest(
      "POST",
      url,
      onProgress: (int bytes, int total) {
        final progress = bytes / total;
        print('progress: $progress ($bytes/$total)');
      },
    );
    request.fields['cId'] = cid!;
    request.fields['cFName'] = profile.fName!;
    request.fields['cLName'] = profile.lName!;
    request.fields['cGender'] = profile.gender!;
    request.fields['cEmail'] = profile.emailId!;
    if (_image == null) {
      _image = await getImageFileFromAssets('profile.png');
    }
    request.files.add(await http.MultipartFile.fromPath(
      'cPicture',
      _image!.path,
    ));
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
      Navigator.of(context).pushReplacement(subscriptionpacks());
    } else {
      flushBarshow("Something went Wrong", context, red);
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        backgroundColor: white,
        body: Column(
          children: <Widget>[
            Container(
              height: height * .25,
              width: width,
              color: blue,
              child: Center(
                child: Text(
                  "Create Profile",
                  style: Theme.of(context).textTheme.bodyText1?.copyWith(
                      color: white,
                      fontWeight: FontWeight.w300,
                      letterSpacing: .5),
                ),
              ),
            ),
            Expanded(
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(height: 20),
                      GestureDetector(
                          onTap: getImage,
                          child: Container(
                            padding: EdgeInsets.all(05),
                            decoration: BoxDecoration(
                                color: white,
                                borderRadius: BorderRadius.circular(50),
                                border: Border.all(color: blue, width: 2),
                                boxShadow: [
                                  BoxShadow(
                                      color: black.withOpacity(.2),
                                      offset: Offset(5, 5),
                                      blurRadius: 10)
                                ]),
                            child: _image == null
                                ? Image.asset("assets/profile.png",
                                    width: 80, fit: BoxFit.cover)
                                : ClipRRect(
                                    borderRadius: BorderRadius.circular(50),
                                    child: Image.file(
                                      _image!,
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                    )),
                          )),
                      SizedBox(height: 10),
                      Text(
                        "Upload Profile Picture",
                        style: Theme.of(context)
                            .textTheme
                            .bodyText1
                            ?.copyWith(fontSize: 16),
                      ),
                      SizedBox(height: 30),
                      MyTextFormField(
                        hintText: "First Name",
                        lable: "First Name",
                        icon: Icon(Icons.account_circle),
                        validator: (String? value) {
                          if (value!.isEmpty) {
                            return 'Enter First Name';
                          }
                          return null;
                        },
                        onSaved: (String? value) {
                          profile.fName = value;
                        },
                      ),
                      MyTextFormField(
                        hintText: "Last Name",
                        lable: "Last Name",
                        icon: Icon(Icons.account_circle),
                        validator: (String? value) {
                          if (value!.isEmpty) {
                            return 'Enter Last Name';
                          }
                          return null;
                        },
                        onSaved: (String? value) {
                          profile.lName = value;
                        },
                      ),
                      Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 06, horizontal: 10),
                        child: DropdownButtonFormField<String>(
                          value: genderSelected,
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(
                                  fontSize: 16,
                                  letterSpacing: .8,
                                  color: Colors.black),
                          decoration: InputDecoration(
                            errorStyle: Theme.of(context)
                                .textTheme
                                .bodyText2
                                ?.copyWith(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w900,
                                    color: red),
                            prefixIcon: Icon(Icons.person_pin),
                            hintText: "Select Gender",
                            hintStyle: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(
                                    fontSize: 14,
                                    letterSpacing: .8,
                                    color: Colors.black.withOpacity(.4)),
                            contentPadding: EdgeInsets.all(20.0),
                            border: UnderlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide.none),
                            filled: true,
                            fillColor: blue.withOpacity(.1),
                          ),
                          items: [
                            "Male",
                            "Female",
                            "Other",
                          ]
                              .map((label) => DropdownMenuItem(
                                    child: Text(label),
                                    value: label,
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() => genderSelected = value!);
                          },
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Please Select your Gender';
                            } else
                              return null;
                          },
                          onSaved: (value) {
                            profile.gender = value;
                          },
                        ),
                      ),
                      MyTextFormField(
                        hintText: "Email",
                        lable: "Email",
                        icon: Icon(Icons.mail),
                        validator: validateEmail,
                        onSaved: (String? value) {
                          if(value!=null) {
                            profile.emailId = value!.trim();
                          }
                        },
                      ),
                      SizedBox(height: 30),
                      MyButton(
                        onPress: () {
                          if (_image == null) {
                            flushBarshow(
                                "Please Select Proile Image", context, red);
                          } else if (formKey.currentState!.validate()) {
                            formKey.currentState!.save();
                            createProfile();
                          }
                        },
                        btntext: "Continue",
                        color: blue,
                        textcolor: white,
                      )
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

String? validateEmail(String? value) {
  var pattern =
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
  RegExp regex = new RegExp(pattern);
  if (!regex.hasMatch(value!.trim()))
    return 'Enter Valid Email';
  else
    return null;
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
