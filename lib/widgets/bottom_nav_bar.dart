import 'package:flutter/material.dart';

class CBottomAppBarItem {
  CBottomAppBarItem(
      {required this.iconData, required this.text, required this.disable});
  IconData iconData;
  String text;
  bool disable;
}

class CBottomAppBar extends StatefulWidget {
  CBottomAppBar({
    required this.items,
    this.centerItemText: '',
    this.height: 50.0,
    this.iconSize: 20.0,
    required this.backgroundColor,
    this.color,
    required this.selectedColor,
    required this.notchedShape,
    required this.onTabSelected,
    required this.selectedIndex,
  }) {
    // assert(this.items.length == 2 || this.items.length == 4);
  }
  final List<CBottomAppBarItem> items;
  final String centerItemText;
  final double height;
  final double iconSize;
  final Color backgroundColor;
  final Color? color;
  final Color selectedColor;
  final NotchedShape notchedShape;
  final ValueChanged<int> onTabSelected;
  final int selectedIndex;

  @override
  State<StatefulWidget> createState() => CBottomAppBarState();
}

class CBottomAppBarState extends State<CBottomAppBar> {
  _updateIndex(int index) {
    widget.onTabSelected(index);
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> items = List.generate(widget.items.length, (int index) {
      return _buildTabItem(
        item: widget.items[index],
        index: index,
        onPressed: _updateIndex,
      );
    });
    items.insert(items.length >> 1, _buildMiddleTabItem());

    return BottomAppBar(
      shape: widget.notchedShape,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: items,
      ),
      color: widget.backgroundColor,
    );
  }

  Widget _buildMiddleTabItem() {
    return Expanded(
      child: SizedBox(
        height: widget.height,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: widget.iconSize),
            Text(
              widget.centerItemText,
              style: TextStyle(color: widget.color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem({
    required CBottomAppBarItem item,
    required int index,
    required ValueChanged<int> onPressed,
  }) {
    bool _isSelected = widget.selectedIndex == index;
    Color? color = _isSelected ? widget.selectedColor : widget.color;
    return Expanded(
      child: SizedBox(
        height: widget.height,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: () => onPressed(index),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(item.iconData,
                    color: item.disable ? Colors.grey.shade400 : color,
                    size: widget.iconSize),
                if (_isSelected)
                  Text(
                    item.text,
                    style: Theme.of(context).textTheme.subtitle2?.copyWith(
                        color: Theme.of(context).textTheme.bodyText2?.color),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
