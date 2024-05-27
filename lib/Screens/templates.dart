import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:my_gallery_book/Components/colors.dart';
import 'package:my_gallery_book/Components/mybutton.dart';
import 'package:flutter/material.dart';
import 'package:my_gallery_book/widgets/spinner_widget.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;

class MyTemplates extends StatefulWidget {
  const MyTemplates({Key? key}) : super(key: key);

  @override
  State<MyTemplates> createState() => _MyTemplatesState();
}

class _MyTemplatesState extends State<MyTemplates> {
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();

  final scaffoldKey = GlobalKey<ScaffoldState>();

  WebViewController? _webController;

  @override
  void initState() {
    super.initState();
    hey();
  }

  var getdata, url = "http://mygallerybook.com/templates";

  bool isLoading = true;

  hey() async {
    final response = await http.head(Uri.parse(url));
    print(response.statusCode);
    setState(() {
      getdata = response.statusCode;
      isLoading = false;
    });
  }

  bool isSpinnerLoading = false;

  void loadCircularProgressIndicator() {
    if (isSpinnerLoading == true) {
      setState(() {
        isSpinnerLoading = false;
      });
    } else {
      setState(() {
        isSpinnerLoading = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(),
      body: Stack(
        children: [
          Center(
            child: isLoading
                ? CircularProgressIndicator()
                : getdata > 200
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Image.asset(
                            "assets/soon.png",
                            width: width * .5,
                          ),
                          SizedBox(height: 10),
                          Text(
                            "Coming Soon",
                            style: Theme.of(context)
                                .textTheme
                                .caption
                                ?.copyWith(color: blue, fontSize: 23),
                          ),
                          SizedBox(height: 20),
                          MyButton(
                            btntext: "Go Back",
                            color: blue,
                            textcolor: white,
                            onPress: () {
                              Navigator.of(context).pop(true);
                            },
                          ),
                        ],
                      )
                    : Column(
                        children: [Expanded(child: getWebViewWidget())],
                      ),
          ),
          Visibility(
            maintainSize: true,
            maintainAnimation: true,
            maintainState: true,
            visible: isSpinnerLoading,
            child: SpinnerWidget.getSpinnerWidget(),
          ),
        ],
      ),
    );
  }

  Widget getWebViewWidget() {
    return Stack(
      children: <Widget>[
        _webController != null
            ? WebViewWidget(
                controller: _webController!,
                // Added gestureReconizers on 25th May, 2023 to fix scroll issue.
                gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                    Factory<OneSequenceGestureRecognizer>(
                      () => EagerGestureRecognizer(),
                    ),
                  })
            : Container(),
      ],
    );
  }
}
