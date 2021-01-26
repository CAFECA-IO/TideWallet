import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/update_password/update_password_bloc.dart';
import '../../blocs/user/user_bloc.dart';
import '../inputs/input.dart';
import '../inputs/password_input.dart';
import '../buttons/secondary_button.dart';
import '../dialogs/dialog_controller.dart';
import '../dialogs/error_dialog.dart';
import '../../helpers/i18n.dart';

class UpdatePasswordForm extends StatefulWidget {
  @override
  _UpdatePasswordFormState createState() => _UpdatePasswordFormState();
}

class _UpdatePasswordFormState extends State<UpdatePasswordForm> {
  UpdatePasswordBloc _bloc;
  UserBloc _userBloc;

  final t = I18n.t;

  @override
  void didChangeDependencies() {
    _bloc = BlocProvider.of<UpdatePasswordBloc>(context);
    _userBloc = BlocProvider.of<UserBloc>(context);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
    _bloc.close();
    _userBloc.close();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UpdatePasswordBloc, UpdatePasswordState>(
      cubit: _bloc,
      listener: (context, state) {
        UpdatePasswordStateCheck _state = state;
        if (_state.error != null && _state.error != UpdateFormError.none) {
          String _text = '';
          switch (_state.error) {
            case UpdateFormError.wrongPassword:
              _text = t('wrong_password');
              break;
            case UpdateFormError.passwordInvalid:
              _text = t('create_wallet_invalid_password');
              break;
            case UpdateFormError.passwordNotMatch:
              _text = t('create_wallet_password_unmatch');
              break;
            default:
          }
          DialogContorller.show(context, ErrorDialog(_text), onDismiss: () {
            _bloc.add(
              CleanUpdatePassword(),
            );
          });
        }

        if (_state.error == UpdateFormError.none) {
          Navigator.of(context).pop();
          _userBloc.add(UpdatePassword(_state.password));
        }
      },
      child: BlocBuilder<UpdatePasswordBloc, UpdatePasswordState>(
          cubit: _bloc,
          builder: (BuildContext ctx, UpdatePasswordState state) {
            if (state is UpdatePasswordStateCheck) {
              return CheckingView(_bloc, state);
            }

            return SizedBox();
          }),
    );
  }
}

class CheckingView extends StatefulWidget {
  final UpdatePasswordBloc _bloc;
  final UpdatePasswordStateCheck _state;
  CheckingView(this._bloc, this._state);

  @override
  _CheckingViewState createState() => _CheckingViewState();
}

class _CheckingViewState extends State<CheckingView> {
  final TextEditingController _currentPwdController = TextEditingController();
  final TextEditingController _pwdController = TextEditingController();
  final TextEditingController _repwdController = TextEditingController();
  final _form = GlobalKey<FormState>();

  final t = I18n.t;

  List<Widget> checkList(List<bool> rules) {
    List<Widget> list = [
      Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Text(
          t('create_wallet_rule'),
          style: Theme.of(context).textTheme.bodyText2,
        ),
      )
    ];

    for (int i = 0; i < rules.length; i++) {
      String title = '';

      switch (i) {
        case 0:
          title = t('create_wallet_rule_1');
          break;
        case 1:
          title = t('create_wallet_rule_2');
          break;
        case 2:
          title = t('create_wallet_rule_3');
          break;
        case 3:
          title = t('diff_with_curr_pwd');
          break;
        default:
      }
      list.add(PasswordItem(title, rules[i]));
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Form(
            key: _form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                      color:
                          Theme.of(context).primaryColorDark.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(4.0)),
                  padding:
                      EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                  margin: EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(
                    t('create_wallet_message'),
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                PasswordInput(
                  label: t('current_password'),
                  controller: _currentPwdController,
                  validator: (String v) => '',
                  onChanged: (String v) {
                    widget._bloc.add(InputWalletCurrentPassword(v));
                  },
                ),
                SizedBox(height: 16.0),
                PasswordInput(
                  label: t('new_password'),
                  controller: _pwdController,
                  validator: (String v) => '',
                  onChanged: (String v) {
                    widget._bloc.add(InputPassword(v));
                  },
                ),
                Container(
                  width: double.infinity,
                  padding:
                      EdgeInsets.symmetric(vertical: 12.0, horizontal: 15.0),
                  margin: EdgeInsets.only(top: 8.0),
                  decoration: BoxDecoration(
                      color: Theme.of(context).dividerColor,
                      borderRadius: BorderRadius.circular(4.0)),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: checkList(widget._state.rules)),
                ),
                SizedBox(height: 16.0),
                PasswordInput(
                  label: t('re_ew_password'),
                  controller: _repwdController,
                  validator: (String v) => '',
                  onChanged: (String v) {
                    widget._bloc.add(InputRePassword(v));
                  },
                ),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 36.0),
            margin: EdgeInsets.only(bottom: 48),
            width: MediaQuery.of(context).size.width * 0.9,
            child: SecondaryButton(
              t('confirm'),
              () {
                widget._bloc.add(SubmitUpdatePassword());
              },
              borderColor: Theme.of(context).accentColor,
              textColor: Theme.of(context).accentColor,
              isEnabled: (widget._state.currentPassword.isNotEmpty &&
                      widget._state.password.isNotEmpty &&
                      widget._state.rePassword.isNotEmpty)
                  ? true
                  : false,
            ),
          ),
        ),
      ],
    );
  }
}

class PasswordItem extends StatelessWidget {
  final String _title;
  final bool _isValid;
  PasswordItem(this._title, this._isValid);

  @override
  Widget build(BuildContext context) {
    final _color = Theme.of(context).primaryColorDark;

    return Container(
      child: Row(
        children: [
          Container(
            width: 16.0,
            child: this._isValid
                ? Icon(Icons.check_circle_sharp, color: _color, size: 16.0)
                : Icon(
                    Icons.circle,
                    color: _color,
                    size: 6.0,
                  ),
            margin: EdgeInsets.only(right: 4.0),
          ),
          Text(this._title, style: Theme.of(context).textTheme.bodyText2)
        ],
      ),
    );
  }
}
