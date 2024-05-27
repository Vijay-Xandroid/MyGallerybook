import 'package:flutter/material.dart';

class SpinnerWidget extends StatelessWidget {
  const SpinnerWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container();
  }

  static Widget getSpinnerWidget() {
    return Center(
      child: Container(
        width: 40.0,
        height: 40.0,
        child: const CircularProgressIndicator(
          backgroundColor: Colors.green,
          strokeWidth: 6,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
        ),
      ),
    );
  }
}
