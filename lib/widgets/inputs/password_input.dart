import 'package:flutter/material.dart';

class PasswordInput extends StatefulWidget {
  final String label;
  final Function validator;
  final Function onChanged;
  final TextEditingController controller;
  final bool showBtn;

  PasswordInput(
      {@required this.label,
      @required this.validator,
      @required this.onChanged,
      @required this.controller,
      this.showBtn = true});

  @override
  _PasswordInputState createState() => _PasswordInputState();
}

class _PasswordInputState extends State<PasswordInput> {
  bool show = false;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      // onFieldSubmitted: ,
      onChanged: (String v) {
        widget.onChanged(v);
      },
      obscureText: !show,
      textInputAction: TextInputAction.done,
      style: TextStyle(fontSize: 16.0),
      controller: widget.controller,
      validator: widget.validator,
      decoration: InputDecoration(
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).primaryColorLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).cursorColor),
        ),
        contentPadding: EdgeInsets.all(8.0),
        // labelStyle: widget.validator(widget.controller.text) == null
        //     ? TextStyle(fontSize: 14.0, color: Color(0xFF888888))
        //     : TextStyle(color: Colors.red, fontSize: 14.0),
        labelStyle: TextStyle(color: Theme.of(context).accentColor),
        labelText: widget.label,

        // errorStyle: TextStyle(color: Colors.red, fontSize: 10.0),
        suffixIcon: widget.showBtn ? GestureDetector(
            onTap: () {
              setState(() {
                show = !show;
              });
            },
            child: show
                ? ImageIcon(AssetImage('assets/images/icons/ic_openeye.png'))
                : ImageIcon(AssetImage('assets/images/icons/ic_closeeye.png'))) : null,
      ),
    );
  }
}
