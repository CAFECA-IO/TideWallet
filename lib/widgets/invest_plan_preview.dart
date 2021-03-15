import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/invest_plan/invest_plan_bloc.dart';
import '../blocs/user/user_bloc.dart';
import 'inputs/input.dart';
import 'inputs/password_input.dart';
import 'buttons/secondary_button.dart';
import 'dialogs/dialog_controller.dart';
import 'dialogs/error_dialog.dart';
import '../helpers/i18n.dart';

class InvestPlanPreview extends StatefulWidget {
  @override
  _InvestPlanPreviewState createState() => _InvestPlanPreviewState();
}

class _InvestPlanPreviewState extends State<InvestPlanPreview> {
  final t = I18n.t;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
    // _bloc.close();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox();
  }
}
