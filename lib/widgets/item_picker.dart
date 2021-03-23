import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../helpers/i18n.dart';
import '../theme.dart';

final t = I18n.t;

class ItemPicker extends StatefulWidget {
  ItemPicker({
    @required this.items,
    @required this.onTap,
    @required this.notifyParent,
    this.selectedItem,
    this.constraints,
    this.dialogConstraints,
    this.child,
    this.barrierDismissible,
    this.title,
    this.initialItem,
    Key key,
  }) : super(key: key);

  // String hintText;
  final BoxConstraints constraints;
  final BoxConstraints dialogConstraints;
  final List<dynamic> items;
  final Function onTap;
  final Function notifyParent;
  int initialItem;
  String title;
  bool barrierDismissible;
  dynamic selectedItem;
  Widget child;

  @override
  _ItemPickerState createState() => _ItemPickerState();
}

class _ItemPickerState extends State<ItemPicker> {
  // String selectedItem = '';
  int itemIndex = 0;
  Future<void> buildShowDialog(
    BuildContext context,
  ) {
    final Brightness brightnessValue =
        MediaQuery.of(context).platformBrightness;
    bool isDark = brightnessValue == Brightness.dark;

    double screenHeight = MediaQuery.of(context).size.height;

    return showDialog<void>(
        context: context,
        barrierDismissible:
            widget.barrierDismissible ?? false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: widget.title != null
                ? Center(
                    child: Text(
                      widget.title,
                    ),
                  )
                : null,
            contentPadding: EdgeInsets.only(top: 15),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))),
            backgroundColor: Theme.of(context).dialogBackgroundColor,
            content: Container(
              constraints: widget.dialogConstraints ??
                  BoxConstraints(
                    maxHeight: screenHeight * 0.3,
                    // maxWidth: screenWidth * 0.5,
                  ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  // Spacer(),
                  SizedBox(height: 15),
                  Flexible(
                    flex: 1,
                    child: CupertinoPicker(
                      scrollController: FixedExtentScrollController(
                          initialItem: widget.initialItem ?? 0),
                      backgroundColor: Colors.transparent,
                      looping: false,
                      onSelectedItemChanged: (index) {
                        itemIndex = index;
                      },
                      itemExtent: 50,
                      children: widget.items
                          ?.map(
                            (item) => FlatButton(
                              child: Text(
                                  item.runtimeType != String ? item.name : item,
                                  style: Theme.of(context).textTheme.subtitle2),
                              onPressed: () {},
                            ),
                          )
                          ?.toList(),
                    ),
                  ),
                  SizedBox(height: 15),
                  Container(
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                            color: isDark ? Colors.grey : Colors.black12),
                        // bottom: BorderSide(color: Colors.black12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        if (widget.barrierDismissible != null &&
                            !widget.barrierDismissible)
                          Flexible(
                            flex: 1,
                            child: GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 15),
                                decoration: BoxDecoration(
                                    border: Border(
                                        right: BorderSide(
                                  color: isDark ? Colors.grey : Colors.black12,
                                ))),
                                alignment: Alignment.center,
                                child: Text(
                                  t('cancel'),
                                  style: Theme.of(context)
                                      .textTheme
                                      .button
                                      .copyWith(
                                          color: Colors.blue, fontSize: 16),
                                ),
                              ),
                              onTap: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ),
                        Flexible(
                          flex: 1,
                          child: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 15),
                              alignment: Alignment.center,
                              child: Text(
                                t('ok'),
                                style: Theme.of(context)
                                    .textTheme
                                    .button
                                    .copyWith(
                                        color: Colors.blue,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400),
                              ),
                            ),
                            onTap: () {
                              Navigator.of(context).pop();
                              if (widget.selectedItem != null &&
                                  widget.items.isNotEmpty)
                                setState(() {
                                  widget.selectedItem = widget.items[itemIndex];
                                });
                              if (widget.items.isNotEmpty)
                                // widget.notifyParent(widget.items[itemIndex]);
                                widget.notifyParent(
                                    index: itemIndex,
                                    value: widget.items[itemIndex]);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      child: widget.child ??
          Container(
            alignment: Alignment.centerLeft,
            margin: EdgeInsets.symmetric(vertical: 10),
            padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
            decoration: BoxDecoration(
              color: MyColors
                  .secondary_05, //Theme.of(context).inputDecorationTheme.fillColor,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              widget.selectedItem.runtimeType != String
                  ? widget.selectedItem.name
                  : widget.selectedItem, //'Select initializing method',
              style: Theme.of(context).textTheme.caption.copyWith(fontSize: 16),
            ),
          ),
      onTap: () {
        itemIndex = 0;
        widget.onTap();
        buildShowDialog(
          context,
        );
      },
    );
  }
}
