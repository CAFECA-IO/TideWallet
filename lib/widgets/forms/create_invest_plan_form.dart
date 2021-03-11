import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/invest_plan/invest_plan_bloc.dart';
import '../../blocs/user/user_bloc.dart';
import '../inputs/input.dart';
import '../inputs/password_input.dart';
import '../buttons/secondary_button.dart';
import '../dialogs/dialog_controller.dart';
import '../dialogs/error_dialog.dart';
import '../../helpers/i18n.dart';

class CreateInvestPlanForm extends StatefulWidget {
  @override
  _CreateInvestPlanFormState createState() => _CreateInvestPlanFormState();
}

class _CreateInvestPlanFormState extends State<CreateInvestPlanForm> {
  InvestPlanBloc _bloc = InvestPlanBloc();
  UserBloc _userBloc;

  final t = I18n.t;

  @override
  void didChangeDependencies() {
    _userBloc = BlocProvider.of<UserBloc>(context);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
    _bloc.close();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<InvestPlanBloc, InvestPlanState>(
      cubit: _bloc,
      listener: (context, state) {},
      child: BlocBuilder<InvestPlanBloc, InvestPlanState>(
          cubit: _bloc,
          builder: (BuildContext ctx, InvestPlanState state) {
            return SizedBox();
          }),
    );
  }
}
