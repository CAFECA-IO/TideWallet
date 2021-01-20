import 'package:flutter/material.dart';
import 'package:tidewallet3/widgets/inputs/password_input.dart';

class VerifyPasswordDialog extends StatefulWidget {
  final Function _cancel;
  final Function _confirm;

  VerifyPasswordDialog(this._confirm, this._cancel);

  @override
  _VerifyPasswordDialogState createState() => _VerifyPasswordDialogState();
}

class _VerifyPasswordDialogState extends State<VerifyPasswordDialog> {
  TextEditingController _controller = new TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget btn(String _text, Function _onClick) => InkWell(
        child: Container(
          child: Text(
            _text,
            style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 16.0),
            textAlign: TextAlign.center,
            
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 18.0),
        ),
        onTap: () {
          _onClick(_controller.text);
        },
      );

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: dialogContent(context),
    );
  }

  Widget dialogContent(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 0.0, right: 0.0),
      child: Stack(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(
              top: 18.0,
            ),
            margin: EdgeInsets.only(top: 13.0, right: 8.0),
            decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 0.0,
                    offset: Offset(0.0, 0.0),
                  ),
                ]),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Text(
                    "請輸入密碼",
                    style: TextStyle(fontSize: 14.0, color: Colors.white),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18.0),
                  child: PasswordInput(
                    label: '',
                    validator: (String v) {},
                    onChanged: (String v) {},
                    controller: _controller,
                    showBtn: false,
                    textStyle: TextStyle(color: Colors.white, fontSize: 27.0),
                    autofocus: true,
                  ),
                ),
                SizedBox(height: 24.0),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(8.0),
                      bottomRight: Radius.circular(8.0),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      btn('Cancel', widget._cancel),
                      btn('OK', widget._confirm),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
