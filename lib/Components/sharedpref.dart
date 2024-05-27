import 'package:shared_preferences/shared_preferences.dart';

Future<String> getcid() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? cid = prefs.getString('cid');
  return cid!;
}

Future<String> getcphone() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? cPhone = prefs.getString('cPhone');
  return cPhone!;
}

Future<String> getcemail() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? cemail = prefs.getString('eMail');
  return cemail!;
}

Future<String> getpId() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? pId = prefs.getString('pId');
  return pId!;
}

Future<String> getaId() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? aId = prefs.getString('aId');
  return aId!;
}

Future<String> getpayId() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? payment = prefs.getString('payment');
  return payment!;
}

setUserName(data) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString("firstName", data["cFName"]);
  prefs.setString("lastName", data["cLName"]);
}
