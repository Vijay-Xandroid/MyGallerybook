import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Components/Routes.dart';
import '../Components/colors.dart';
import '../Components/flushbar.dart';
import '../Components/mybutton.dart';
import '../Components/sharedpref.dart';
import '../Components/urls.dart';

class Payment extends StatefulWidget {
  const Payment({Key? key, this.data, required this.index, required this.color})
      : super(key: key);
  final data;
  final int index;
  final Color color;
  @override
  State<Payment> createState() => _PaymentState();
}

class _PaymentState extends State<Payment> {
  int totalamount = 0;
  Razorpay? _razorpay;
  var selectedpack, pack;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay?.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay?.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay?.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    setState(() {
      selectedpack = widget.data;
      pack = widget.index;
      mycolor = widget.color;
      print(pack);
      print(selectedpack[pack]["sId"]);
    });
    getcphone().then(updatecphone);
    getcemail().then(updatecemail);
    getcid().then(updatecid);
  }

  String? _phone, _email, _cid, btntext = "Pay Securly";
  Color? mycolor;

  updatecid(String id) {
    setState(() {
      _cid = id;
    });
  }

  updatecphone(String phone) {
    setState(() {
      _phone = phone;
    });
  }

  updatecemail(String email) {
    setState(() {
      _email = email;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _razorpay?.clear();
  }

  void openCheckout(amount) async {
    var options = {
      'key': 'rzp_live_auFW5yy8TzDkPk',
      'amount': amount * 100,
      'name': 'My Gallerybook!',
      'description': 'My Gallerybook Subscription',
      'prefill': {'contact': _phone, 'email': _email},
      'extrenal': {
        'wallets': ['paytm']
      }
    };
    try {
      _razorpay?.open(options);
    } catch (e) {
      // debugPrint(e);
    }
  }

  bool pay = false;

  buySubscription(String payid) async {
    print(payid);
    var url = Uri.parse(Urls.productionHost + Urls.payment);
    print(url);

    var request = new http.MultipartRequest("POST", url);
    request.fields['cId'] = _cid!;
    request.fields['sId'] = selectedpack[pack]["sId"];
    request.fields['sMonths'] = selectedpack[pack]["sMonths"];
    request.fields['sRemainAlbums'] = selectedpack[pack]["sAlbums"];
    request.fields['amountPaid'] =
        int.parse(selectedpack[pack]["sOfferCost"]) > 0
            ? selectedpack[pack]["sOfferCost"]
            : selectedpack[pack]["sCost"];
    request.fields['transactionID'] = payid;
    print(request.fields.toString());
    var response = await request.send();
    var data = await response.stream.transform(utf8.decoder).join();
    print(data);
    print("StatusCode:" + response.statusCode.toString());
    if (response.statusCode == 200) {
      var details;
      setState(() {
        details = jsonDecode(data);
      });
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString("payment", details["payment"]["pId"]);
    } else {
      setState(() {
        var datai = jsonDecode(data);
        print(datai);
      });
      print(response.statusCode);
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    print(response.paymentId);
    buySubscription(response.paymentId!);
    flushBarshow("Success:" + response.paymentId!, context, green);
    setState(() {
      mycolor = green;
      btntext = "Please Wait";
      pay = true;
    });
    Future.delayed(const Duration(milliseconds: 5000), () {
      Navigator.of(context).pushReplacement(homepageroute());
    });
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    flushBarshow("ERROR:" + response.code.toString() + "-" + response.message!,
        context, red);
    setState(() {
      mycolor = red;
      btntext = "Try Again";
    });
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    flushBarshow("External Wallet" + response.walletName!, context, color3);
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
        body: Container(
      height: height,
      width: width,
      color: mycolor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            "${selectedpack[pack]["sName"]}",
            style: Theme.of(context)
                .textTheme
                .bodyText1
                ?.copyWith(fontSize: width * .17, color: white),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(
                "Rs. ",
                style: Theme.of(context)
                    .textTheme
                    .caption
                    ?.copyWith(color: white, fontSize: 36, height: 3),
              ),
              int.parse(selectedpack[pack]["sOfferCost"]) > 0
                  ? Text(
                      "${selectedpack[pack]["sOfferCost"]}",
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: white, fontSize: width * .2, height: 1.2),
                    )
                  : Text(
                      "${selectedpack[pack]["sCost"]}",
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: white, fontSize: width * .2, height: 1.2),
                    ),
            ],
          ),
          SizedBox(height: 30),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                "${int.parse(selectedpack[pack]["sMonths"]) > 1 ? selectedpack[pack]["sMonths"] + " Months" : selectedpack[pack]["sMonths"] + " Month"} validity",
                style: TextStyle(color: white, fontSize: 30),
              ),
              SizedBox(height: 10),
              Text(
                "${int.parse(selectedpack[pack]["sAlbums"]) > 1 ? selectedpack[pack]["sAlbums"] + " Photobooks" : selectedpack[pack]["sAlbums"] + " Photobook"}",
                style: TextStyle(color: white, fontSize: 30),
              ),
              SizedBox(height: 10),
              Text(
                "1 Photobook per Month",
                style: TextStyle(color: white, fontSize: 30),
              ),
              SizedBox(height: 50),
              MyButton(
                btntext: btntext ?? "",
                onPress: pay
                    ? () {}
                    : () {
                        setState(() {
                          totalamount =
                              int.parse(selectedpack[pack]["sOfferCost"]) > 0
                                  ? int.parse(selectedpack[pack]["sOfferCost"])
                                  : int.parse(selectedpack[pack]["sCost"]);
                        });
                        openCheckout(totalamount);
                      },
                color: white,
                textcolor: mycolor!,
              ),
              SizedBox(
                height: 20,
              ),
              MyButton(
                btntext: "Change Pack",
                onPress: () {
                  Navigator.of(context).pushReplacement(subscriptionpacks());
                },
                color: mycolor!,
                textcolor: white,
              ),
              // FlatButton(
              //     onPressed: () async {
              //       SharedPreferences prefs = await SharedPreferences.getInstance();
              //       prefs.setString("payment", "35");
              //       Navigator.of(context).pushReplacement(homepageroute());
              //     },
              //     child: Text("Skip for Now"))
            ],
          ),
        ],
      ),
    ));
  }
}
