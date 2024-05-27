import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'Components/colors.dart';
import 'screens/splash.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'widgets/directly_used_packages/screen/screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(statusBarColor: blue, systemNavigationBarColor: blue),
  );
  if (!kIsWeb) {
    Screen.keepOn(true);
  }
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(MyApp());
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "My Gallery Book 2.0",
      theme: ThemeData(
          primarySwatch: colorCustom,
          brightness: Brightness.light,
          textTheme: TextTheme(
              bodyLarge: GoogleFonts.nunito(
                  //muli
                  textStyle: TextStyle(
                inherit: true,
                fontSize: 23,
                fontWeight: FontWeight.w800,
              )),
              bodyMedium: GoogleFonts.nunito(
                  textStyle: TextStyle(
                inherit: true,
                fontSize: 20,
              )),
              bodySmall: GoogleFonts.lato(
                  textStyle: TextStyle(
                      inherit: true,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      fontStyle: FontStyle.italic)))),
      home: Splash(),
    );
  }
}
