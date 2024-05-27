import 'package:flutter/material.dart';

import 'colors.dart';


class CustomItem extends StatefulWidget {
  const CustomItem({Key? key, required this.index, required this.isSelected, required this.profileDetail, required this.address, required this.selectItem}) : super(key: key);
  final int index;
  final bool isSelected;
  final String profileDetail;
  final String address;
  final Function(int) selectItem;
  @override
  State<CustomItem> createState() => _CustomItemState();
}

class _CustomItemState extends State<CustomItem> {

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return GestureDetector(
        onTap: () {
          widget.selectItem(widget.index);
        },
        child: Container(
            width: width,
            margin: EdgeInsets.all(width * .04),
            padding: EdgeInsets.symmetric(
                vertical: width * .02, horizontal: width * .02),
            decoration: BoxDecoration(
              border: Border.all(
                  color: widget.isSelected ? green : color1.withOpacity(.2),
                  width: width * .008),
              borderRadius: BorderRadius.circular(width * .04),
            ),
            child: Column(
              children: <Widget>[
                widget.isSelected
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Container(
                            decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(width * .04),
                                color: green),
                            padding: EdgeInsets.symmetric(
                                horizontal: width * .04, vertical: width * .01),
                            child: Text(
                              "Selected",
                              style: Theme.of(context)
                                  .textTheme
                                  .caption
                                  ?.copyWith(
                                      color: white, fontSize: width * .04),
                            ),
                          ),
                        ],
                      )
                    : Container(),
                SizedBox(height: 10),
                Row(
                  children: <Widget>[
                    Container(
                      width: width * .4,
                      padding: EdgeInsets.all(03),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            widget.profileDetail,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 6,
                            textScaleFactor: 01,
                            style: Theme.of(context)
                                .textTheme
                                .caption
                                ?.copyWith(fontSize: width * .04),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: height * .13,
                      child: VerticalDivider(
                        color: color1.withOpacity(.2),
                        thickness: 2,
                      ),
                    ),
                    Container(
                      width: width * .4,
                      padding: EdgeInsets.all(03),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            widget.address,
                            textScaleFactor: 01,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 10,
                            style: Theme.of(context)
                                .textTheme
                                .caption
                                ?.copyWith(fontSize: width * .04),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              ],
            )));
  }
}
