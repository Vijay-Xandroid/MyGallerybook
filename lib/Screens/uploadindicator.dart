import 'package:my_gallery_book/Components/colors.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class UploadIndicator extends StatefulWidget {
  final uploadtext;

  final percentage;

  final sentbytes;

  final totalbytes;

  UploadIndicator(
      {this.uploadtext, this.percentage, this.sentbytes, this.totalbytes});
  @override
  _UploadIndicatorState createState() => _UploadIndicatorState();
}

class _UploadIndicatorState extends State<UploadIndicator> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: CircularPercentIndicator(
              radius: 100.0,
              lineWidth: 30.0,
              animation: true,
              animateFromLastPercent: true,
              linearGradient: LinearGradient(
                  colors: [blue.withOpacity(.6), darkBlue],
                  begin: Alignment.bottomLeft,
                  end: Alignment.bottomRight,
                  tileMode: TileMode.mirror),
              arcType: ArcType.FULL,
              addAutomaticKeepAlive: true,
              arcBackgroundColor: color1.withOpacity(.1),
              backgroundWidth: 0.0,
              curve: Curves.slowMiddle,
              circularStrokeCap: CircularStrokeCap.round,
              percent: widget.percentage,
              header: Text(widget.uploadtext,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(fontSize: 23)),
              footer: Text(
                "${(widget.sentbytes * 0.00000095367432).toStringAsFixed(2)} MB / ${(widget.totalbytes * 0.00000095367432).toStringAsFixed(2)} MB",
                style:
                    Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 18),
              ),
              center: widget.percentage == 1.0
                  ? Icon(
                      Icons.cloud_done,
                      color: darkBlue.withOpacity(.6),
                      size: 80,
                    )
                  : Text((widget.percentage * 100).toStringAsFixed(1) + "%",
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(fontSize: 23)),
              backgroundColor: Colors.transparent),
        ),
      ),
    );
  }
}
