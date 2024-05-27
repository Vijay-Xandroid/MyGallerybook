import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../Components/card.dart';
import '../Components/colors.dart';
import '../Components/urls.dart';
import 'payment.dart';
import 'package:carousel_slider/carousel_slider.dart';


class SubscriptionPacks extends StatefulWidget {
  const SubscriptionPacks({Key? key}) : super(key: key);

  @override
  State<SubscriptionPacks> createState() => _SubscriptionPacksState();
}

class _SubscriptionPacksState extends State<SubscriptionPacks> {
  Future? packs;
  List<Widget> templateCards = [];
  var isLoaded = false;
  @override
  void initState() {
    packs = getpacks();
    super.initState();
  }

  var details;
  List<Widget> subscriptionCards = [];

  getpacks() async {
    var url = Uri.parse(Urls.productionHost + Urls.packs);
    var request = new http.MultipartRequest("GET", url);
    var response = await request.send();
    var data = await response.stream.transform(utf8.decoder).join();
    if (data != null) {
      details = jsonDecode(data);
      getTemplateImages();
      subscriptionPackCards();
    }
    setState(() {
      subscriptionCards = subscriptionCards;
      templateCards = templateCards;
    });
  }

  subscriptionPackCards() {
    for (var index = 0; index < details["SubscriptionData"].length; index++) {
      subscriptionCards.add(Container(
        width: double.infinity,
        child: SubscriptionCards(
          month: details["SubscriptionData"][index]["sMonths"],
          title: details["SubscriptionData"][index]["sName"],
          offer: details["SubscriptionData"][index]["sOfferCost"],
          amount: (int.parse(details["SubscriptionData"][index]["sCost"]) /
                  int.parse(details["SubscriptionData"][index]["sMonths"]))
              .round()
              .toString(),
          albums: details["SubscriptionData"][index]["sAlbums"],
          color: index == 0
              ? color1
              : index == 1
                  ? color2
                  : color3,
          onPress: () {
            Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => Payment(
                    data: details["SubscriptionData"],
                    index: index,
                    color: index == 0
                        ? color1
                        : index == 1
                            ? color2
                            : color3)));
          },
        ),
      ));
    }
  }

  getTemplateImages() {
    for (var i = 0; i < details["TemplateData"].length; i++) {
      templateCards.add(InkWell(
        onTap: () async {
          if (await canLaunch(details["TemplateData"][i]["tURL"])) {
            launch(details["TemplateData"][i]["tURL"]);
          }
        },
        child: Card(
          elevation: 4,
          child: Container(
            width: MediaQuery.of(context).size.width,
            child: CachedNetworkImage(imageUrl:
              Urls.productionHost +
                  Urls.templateimages +
                  details["TemplateData"][i]["tImage"],
              fit: BoxFit.fill,
              height: 500,
              width: 500,
            ),
          ),
        ),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
            title: Text('Subscriptions'),
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            )),
        body: Container(
          height: height,
          width: width,
          color: white,
          child: ListView(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(
                  top: 20.0,
                ),
                child: buildCarouselSlider(),
              ),
              SizedBox(height: 20),
              Center(
                child: Text(
                  "Select Subscription Pack",
                  style: Theme.of(context).textTheme.bodyText1,
                ),
              ),
              Center(
                child: Container(
                  width: width * .7,
                  child: Text(
                    "Select your Subscription Pack to get activated and order the books",
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .bodyText2
                        ?.copyWith(fontSize: 18),
                  ),
                ),
              ),
              SizedBox(height: 20),
              FutureBuilder(
                  future: packs,
                  // ignore: missing_return
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return LinearProgressIndicator();
                    } else if (snapshot.connectionState ==
                        ConnectionState.done) {
                      print("inside the done state");
                      return Padding(
                        padding: EdgeInsets.only(
                            left: width * 0.05, right: width * 0.05),
                        child: Column(
                          children: subscriptionCards,
                        ),
                      );
                    } else if (snapshot.hasError) {
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
                    }
                    else return IgnorePointer();
                  })
            ],
          ),
        ),
      ),
    );
  }

  CarouselSlider buildCarouselSlider() {
    return CarouselSlider(
      options: CarouselOptions(
        initialPage: 0,
        height: 200.0,
        autoPlay: true,
        viewportFraction: 0.8,
        enlargeCenterPage: true,
        aspectRatio: 0.5,
      ),
      items: templateCards,
    );
  }
}
