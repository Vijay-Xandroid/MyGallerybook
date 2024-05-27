import 'dart:convert';

import 'package:my_gallery_book/Components/colors.dart';
import 'package:my_gallery_book/Components/sharedpref.dart';
import 'package:my_gallery_book/Components/urls.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';

class PaymentHistory extends StatefulWidget {
  @override
  _PaymentHistoryState createState() => _PaymentHistoryState();
}

class _PaymentHistoryState extends State<PaymentHistory> {
  late Future<List> paymentHistoryFuture;
  List paymentHistory = [];

  Future<List> getPaymentHistoryDetails() async {
    var request = await http.MultipartRequest(
        'POST', Uri.parse(Urls.productionHost + Urls.myPacks));
    request.fields["cId"] = await getcid();
    http.StreamedResponse response = await request.send();
    String data = await response.stream.transform(utf8.decoder).join();
    print(data);
    paymentHistory = jsonDecode(data);
    return paymentHistory;
  }

  @override
  void initState() {
    paymentHistoryFuture = getPaymentHistoryDetails();
  }

  getPaymentHistoryListUI() {
    List<Widget> paymentHisoryListUI = [];
    if (paymentHistory != null) {
      for (var i = 0; i < paymentHistory.length; i++) {
        var date = paymentHistory[i]["paymentAt"].split(" ")[0].split("-");
        var formatedDate = date[2] + "-" + date[1] + "-" + date[0];
        paymentHisoryListUI.add(Padding(
          padding: const EdgeInsets.only(top: 20.0, left: 10, right: 10),
          child: Card(
            elevation: 6,
            color: blue,
            shape: ContinuousRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Container(
                child: Column(
                  children: [
                    ListTile(
                      title: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Text("${paymentHistory[i]["sName"]}",
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: white)),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Text(
                          "${paymentHistory[i]["sDescription"]}",
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              color: Colors.grey[200]),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding:
                              const EdgeInsets.only(left: 20.0, bottom: 10),
                          child: Container(
                              alignment: Alignment.centerRight,
                              child: Text(
                                "Payment Date $formatedDate",
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.blue[50]),
                              )),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.only(right: 20.0, bottom: 10),
                          child: Container(
                              alignment: Alignment.centerRight,
                              child: Row(
                                children: [
                                  Text(
                                    "Rs ",
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white),
                                  ),
                                  Text(
                                    " ${paymentHistory[i]["amountPaid"]}",
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white),
                                  ),
                                ],
                              )),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ));
      }
      return paymentHisoryListUI;
    } else {
      return [Container()];
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
        body: ListView(
          children: [
            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.only(top: 10, bottom: 10),
              height: height * .10,
              width: width,
              decoration: BoxDecoration(
                  color: blue,
                  borderRadius:
                      BorderRadius.vertical(bottom: Radius.circular(30))),
              child: Text(
                "Payment History",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: white,
                    fontSize: width * .07,
                    fontWeight: FontWeight.w100,
                    letterSpacing: .5),
              ),
            ),
            FutureBuilder(
              future: paymentHistoryFuture,
              builder: (BuildContext context, AsyncSnapshot snp) {
                if (snp.hasError) {
                  print(snp.error);
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
                } else if (snp.connectionState != ConnectionState.done) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: LinearProgressIndicator(),
                  );
                } else {
                  return Column(
                    children: getPaymentHistoryListUI(),
                  );
                }
              },
            )
          ],
        ),
      ),
    );
  }
}
