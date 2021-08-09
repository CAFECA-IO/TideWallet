import 'package:flutter/material.dart';

class ComputerKeyboard extends StatelessWidget {
  final _numbers = List<int>.generate(12, (i) => i + 1);
  final TextEditingController _controller;
  final FocusNode? focusNode;

  ComputerKeyboard(this._controller, {this.focusNode});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      padding: EdgeInsets.zero,
      childAspectRatio: 2,
      crossAxisCount: 3,
      shrinkWrap: true,
      children: _numbers.map((n) {
        TextStyle style = Theme.of(context)
            .textTheme
            .headline1!
            .copyWith(fontWeight: FontWeight.normal);
        Widget _widget = Text(
          n.toString(),
          style: style,
        );

        if (n == 10) {
          _widget = Text(
            '.',
            style: style,
          );
        }

        if (n == 11) {
          _widget = Text(
            '0',
            style: style,
          );
        }

        if (n == 12) {
          _widget = Icon(Icons.backspace, color: style.color!.withOpacity(0.6));
        }

        return InkWell(
          onTap: () {
            if (focusNode != null && !focusNode!.hasFocus) return;
            if (_controller.text.startsWith('0') &&
                _controller.text.length == 1) {
              if (n != 10) _controller.text = '';
            } else if (_controller.text.startsWith('.')) {
              _controller.text = '0.';
            }
            if (n < 10) {
              _controller.text += n.toString();
            }
            if (n == 10) {
              _controller.text += '.';
            }

            if (n == 11) {
              _controller.text += '0';
            }

            if (n == 12 && _controller.text.isNotEmpty) {
              _controller.text =
                  _controller.text.substring(0, _controller.text.length - 1);
            }
            if (!RegExp(r'(^\d*\.?\d*)$').hasMatch(_controller.text)) {
              _controller.text =
                  _controller.text.substring(0, _controller.text.length - 1);
            }
            if (_controller.text.isEmpty) _controller.text = '0';
          },
          child: Container(
            child: Center(child: _widget),
          ),
        );
      }).toList(),
    );
  }
}
