import 'package:flutter/material.dart';

import '../helpers/i18n.dart';
import '../widgets/forms/update_password_form.dart';
import '../widgets/appBar.dart';

class UpdatePasswordScreen extends StatefulWidget {
  static const routeName = '/update_password';

  @override
  _UpdatePasswordScreenState createState() => _UpdatePasswordScreenState();
}

class _UpdatePasswordScreenState extends State<UpdatePasswordScreen> {
  final t = I18n.t;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GeneralAppbar(
        title: t('reset_password'),
        routeName: UpdatePasswordScreen.routeName,
      ),
      resizeToAvoidBottomInset: false,
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        child: UpdatePasswordForm(),
      ),
    );
  }
}
