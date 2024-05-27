import 'dart:async';
import 'dart:io';

import 'package:my_gallery_book/Components/colors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';

class TermsAndConditions extends StatefulWidget {
  @override
  _TermsAndConditionsState createState() => _TermsAndConditionsState();
}

class _TermsAndConditionsState extends State<TermsAndConditions> {
  var filepath;

  Future<File> createFileOfPdfUrl() async {
    Completer<File> completer = Completer();

    try {
      final url = "http://mygallerybook.com/uploads/tc.pdf";
      final filename = url.substring(url.lastIndexOf("/") + 1);
      var request = await HttpClient().getUrl(Uri.parse(url));
      var response = await request.close();
      var bytes = await consolidateHttpClientResponseBytes(response);
      var dir = await getApplicationDocumentsDirectory();
      print("${dir.path}/$filename");
      File file = File("${dir.path}/$filename");
      await file.writeAsBytes(bytes, flush: true);
      completer.complete(file);
    } catch (e) {
      throw Exception('Error parsing asset file!');
    }

    return completer.future;
  }

  setFilePath() async {
    filepath = await createFileOfPdfUrl();
    setState(() {
      filepath = filepath;
    });
  }

  @override
  void initState() {
    setFilePath();
    super.initState();
  }

  final Completer<PDFViewController> _controller =
      Completer<PDFViewController>();
  int pages = 0;
  int currentPage = 0;
  bool isReady = false;
  String errorMessage = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text("Terms And Conditions"),
          centerTitle: true,
          elevation: 6,
        ),
        body: Stack(
          children: [
            filepath != null
                ? PDFView(
                    fitEachPage: true,
                    filePath: filepath.path,
                    enableSwipe: true,
                    swipeHorizontal: false,
                    autoSpacing: false,
                    fitPolicy: FitPolicy.BOTH,
                    pageFling: true,
                    pageSnap: true,
                    onRender: (_pages) {
                      setState(() {
                        pages = _pages!;
                        isReady = true;
                      });
                    },
                    onError: (error) {
                      setState(() {
                        errorMessage = error.toString();
                      });
                      print(error.toString());
                    },
                    onPageError: (page, error) {
                      setState(() {
                        errorMessage = '$page: ${error.toString()}';
                      });
                      print('$page: ${error.toString()}');
                    },
                    onViewCreated: (PDFViewController pdfViewController) {
                      _controller.complete(pdfViewController);
                    },
                    // onLinkHandler: (String uri) {
                    //   print('goto uri: $uri');
                    // },
                    onPageChanged: (var page, var total) {
                      print('page change: $page/$total');
                      setState(() {
                        currentPage = page!;
                      });
                    },
                  )
                : LinearProgressIndicator(
                    semanticsLabel: "Loading",
                    minHeight: 10,
                  ),
            Positioned(
              bottom: 0,
              left: 20,
              right: 20,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: 50,
                  width: MediaQuery.of(context).size.width * 0.5,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: ContinuousRectangleBorder(
                          borderRadius: BorderRadius.circular(50)),
                      backgroundColor: blue,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Agree and Accept",
                        style: TextStyle(color: white, fontSize: 18),
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ));
  }
}
