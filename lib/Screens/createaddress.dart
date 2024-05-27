import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../Components/colors.dart';
import '../Components/mybutton.dart';
import '../Components/popup.dart';
import '../Components/profilemodel.dart';
import '../Components/sharedpref.dart';
import '../Components/textfeild.dart';
import '../Components/urls.dart';

class CreateAddress extends StatefulWidget {
  const CreateAddress({Key? key}) : super(key: key);

  @override
  State<CreateAddress> createState() => _CreateAddressState();
}

class _CreateAddressState extends State<CreateAddress> {
  @override
  void initState() {
    super.initState();
    getcid().then(updateid);
  }

  updateid(String id) {
    setState(() {
      cid = id;
      print(cid);
    });
  }

  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  ProfileModel profile = ProfileModel();
  String? cid;

  createAddress() async {
    poPup(context);
    var url = Uri.parse(Urls.productionHost + Urls.createAddress);
    var request = new http.MultipartRequest("POST", url);
    request.fields['cId'] = cid!;
    request.fields['cDoorNo'] = profile.doorNo!;
    request.fields['cStreet'] = profile.street!;
    request.fields['cLandMark'] = profile.landMark!;
    request.fields['cCity'] = profile.city!;
    request.fields['cPincode'] = profile.pinCode!;
    var response = await request.send();
    var data = await response.stream.transform(utf8.decoder).join();
    if (data != null) {
      Navigator.of(context).pop(true);
      Navigator.pop(context, () {
        setState(() {});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: white,
      body: Column(
        children: <Widget>[
          Container(
            height: height * .2,
            width: width,
            color: blue,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Transform.translate(
                  offset: Offset(-width * .4, -height * .005),
                  child: IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop(true);
                      }),
                ),
                Center(
                  child: Text(
                    "Add Address",
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: white,
                        fontWeight: FontWeight.w300,
                        letterSpacing: .5),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(height: 30),
                    MyTextFormField(
                      hintText: "Door No. / House No.",
                      lable: "Enter House No.",
                      icon: Icon(Icons.home),
                      validator: (String? value) {
                        if (value!.isEmpty) {
                          return 'Enter House No.';
                        }
                        return null;
                      },
                      onSaved: (String? value) {
                        profile.doorNo = value;
                      },
                    ),
                    MyTextFormField(
                      hintText: "Street",
                      lable: "Enter Street",
                      icon: Icon(Icons.local_convenience_store),
                      validator: (String? value) {
                        if (value!.isEmpty) {
                          return 'Enter Street Name';
                        }
                        return null;
                      },
                      onSaved: (String? value) {
                        profile.street = value;
                      },
                    ),
                    MyTextFormField(
                      hintText: "LandMark",
                      lable: "Enter LandMark",
                      icon: Icon(Icons.business),
                      validator: (String? value) {
                        if (value!.isEmpty) {
                          return 'Enter LandMark';
                        }
                        return null;
                      },
                      onSaved: (String? value) {
                        profile.landMark = value;
                      },
                    ),
                    MyTextFormField(
                      hintText: "City",
                      lable: "Enter City Name",
                      icon: Icon(Icons.location_city),
                      validator: (String? value) {
                        if (value!.isEmpty) {
                          return 'Enter City Name';
                        }
                        return null;
                      },
                      onSaved: (String? value) {
                        profile.city = value;
                      },
                    ),
                    MyTextFormField(
                      hintText: "PinCode",
                      lable: "Enter PinCode",
                      isNumber: true,
                      number: 6,
                      icon: Icon(Icons.fiber_pin),
                      validator: (String? value) {
                        if (value!.isEmpty || value.length < 6) {
                          return 'Enter PinCode Number';
                        }
                        return null;
                      },
                      onSaved: (String? value) {
                        profile.pinCode = value;
                      },
                    ),
                    SizedBox(height: 30),
                    MyButton(
                      onPress: () {
                        if (formKey.currentState!.validate()) {
                          formKey.currentState!.save();
                          createAddress();
                        }
                      },
                      btntext: "Continue",
                      color: blue,
                      textcolor: white,
                    ),
                    SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
