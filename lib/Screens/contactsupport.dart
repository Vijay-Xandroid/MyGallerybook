import 'dart:convert';

import 'package:my_gallery_book/Components/colors.dart';
import 'package:my_gallery_book/Components/urls.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactSupport extends StatefulWidget {
  @override
  _ContactSupportState createState() => _ContactSupportState();
}

class _ContactSupportState extends State<ContactSupport> {
  Future<Map>? contactDetails;
  String? phone, email;

  @override
  void initState() {
    contactDetails = getContactDetails();
    super.initState();
  }

  Future<Map> getContactDetails() async {
    Dio dio = Dio();

    var res = await dio.get(Urls.productionHost + Urls.contactSupport);
    Map data = jsonDecode(res.toString());
    phone = data["phoneNo"];
    email = data["emailId"];
    return data;
  }

  List<Map<String, dynamic>> contactData = [
    {
      "title": "Visit us",
      "icon": FontAwesomeIcons.chrome,
      "color": Colors.teal,
      "subtitle": "http://mygallerybook.com",
      "url": "http://mygallerybook.com"
    },
    {
      "title": "Facebook",
      "icon": FontAwesomeIcons.facebook,
      "color": Colors.blue[400],
      "subtitle": "https://www.facebook.com/mgb.gallerybook.9",
      "url": "https://www.facebook.com/mgb.gallerybook.9"
    },
    {
      "title": "Twitter",
      "icon": FontAwesomeIcons.twitter,
      "color": Colors.blue,
      "subtitle": "https://twitter.com/mygallerybook1",
      "url": "https://twitter.com/mygallerybook1"
    },
    {
      "title": "Instagram",
      "icon": FontAwesomeIcons.instagram,
      "color": Colors.purple,
      "subtitle": "https://www.instagram.com/mygallery_book",
      "url": "https://www.instagram.com/mygallery_book"
    },
    {
      "title": "Youtube",
      "icon": FontAwesomeIcons.youtube,
      "color": Colors.red,
      "subtitle": "https://www.youtube.com/channel/UCr0nrvnDqAcbovNm67eHH1g",
      "url": "https://www.youtube.com/channel/UCr0nrvnDqAcbovNm67eHH1g"
    },
    {
      "title": "Linkedin",
      "icon": FontAwesomeIcons.linkedin,
      "color": Colors.blue[800],
      "subtitle": "https://www.linkedin.com/in/mygallery-book-3b63941b4",
      "url": "https://www.linkedin.com/in/mygallery-book-3b63941b4"
    }
  ];

  List<Widget> getContactList() {
    List<Widget> listUI = [];
    for (var i = 0; i < contactData.length; i++) {
      listUI.add(InkWell(
        onTap: () async {
          if (await canLaunch(contactData[i]["url"])) {
            await launch(contactData[i]["url"]);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(2.0),
          child: ListTile(
              title: Text(contactData[i]["title"]),
              leading: FaIcon(contactData[i]["icon"],
                  color: contactData[i]["color"]),
              subtitle: Text(
                contactData[i]["subtitle"],
                style: TextStyle(fontSize: 14),
              )),
        ),
      ));
    }
    return listUI;
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Scaffold(
          body: ListView(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                  height: 250,
                  width: 250,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(160),
                      boxShadow: [
                        BoxShadow(
                            offset: Offset(0, 1),
                            spreadRadius: 0.5,
                            blurRadius: 7,
                            color: Colors.black.withOpacity(0.3))
                      ]),
                  child: Image.asset(
                    "assets/App_Icon.png",
                    fit: BoxFit.fill,
                  )),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 25.0, top: 20),
            child: Container(
              child: Text(
                "Contact Us :",
                style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 1),
              ),
            ),
          ),
          FutureBuilder(
              future: contactDetails,
              builder: (context, AsyncSnapshot snp) {
                if (snp.hasError) {
                  return ContactError(height);
                } else if (snp.connectionState == ConnectionState.done) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: Column(
                      children: [
                        InkWell(
                          onTap: () async {
                            if (await canLaunch("mailto:" + (email ?? ""))) {
                              await launch("mailto:" + (email ?? ""));
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: ListTile(
                                title: Text("Mail us at"),
                                leading: FaIcon(FontAwesomeIcons.envelope,
                                    color: Colors.blueGrey),
                                subtitle: Text(
                                  email ?? "",
                                  style: TextStyle(fontSize: 14),
                                )),
                          ),
                        ),
                        InkWell(
                          onTap: () async {
                            if (await canLaunch("tel:" + (phone ?? ""))) {
                              await launch("tel:" + (phone ?? ""));
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: ListTile(
                                title: Text("Call us"),
                                leading: FaIcon(FontAwesomeIcons.phoneAlt,
                                    color: Colors.green),
                                subtitle: Text(
                                  phone ?? "",
                                  style: TextStyle(fontSize: 14),
                                )),
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              }),
          Padding(
            padding: const EdgeInsets.only(left: 20.0, bottom: 30),
            child: Column(
              children: getContactList(),
            ),
          ),
        ],
      )),
    );
  }
}

// ignore: non_constant_identifier_names
ContactError(height) => Container(
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
            'Failed To Load the Contact Data',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.red, fontSize: 20, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
