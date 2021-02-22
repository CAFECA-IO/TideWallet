import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../../blocs/update_password/update_password_bloc.dart';
import '../../blocs/backup/backup_bloc.dart';
import '../inputs/password_input.dart';
import '../buttons/secondary_button.dart';
import '../dialogs/loading_dialog.dart';
import '../dialogs/dialog_controller.dart';
import '../dialogs/error_dialog.dart';
import '../dialogs/success_dialog.dart';
import '../../helpers/i18n.dart';
import '../../repositories/user_repository.dart';

class UpdatePasswordForm extends StatefulWidget {
  final double appBarHeight;

  const UpdatePasswordForm({Key key, this.appBarHeight}) : super(key: key);
  @override
  _UpdatePasswordFormState createState() => _UpdatePasswordFormState();
}

class _UpdatePasswordFormState extends State<UpdatePasswordForm> {
  UpdatePasswordBloc _bloc;
  BackupBloc _backupBloc;
  UserRepository _userRepo;

  final t = I18n.t;

  @override
  void didChangeDependencies() {
    _userRepo = Provider.of<UserRepository>(context);
    _backupBloc = BlocProvider.of<BackupBloc>(context);
    _bloc = UpdatePasswordBloc(_userRepo);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
    _bloc.close();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UpdatePasswordBloc, UpdatePasswordState>(
      cubit: _bloc,
      listener: (context, state) async {
        if (state is UpdatePasswordStateCheck) {
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
            DialogController.show(context, ErrorDialog(_text), onDismiss: () {
              _bloc.add(
                CleanUpdatePassword(),
              );
            });
          }

          if (_state.error == UpdateFormError.none) {
            _bloc.add(UpdatePassword());
          }
        }

        if (state is PasswordUpdating) {
          DialogController.showUnDissmissible(context, LoadingDialog());
        }
        if (state is PasswordUpdated) {
          DialogController.dismiss(context);
          DialogController.showUnDissmissible(
              context, SuccessDialog(t('success_update_password')));

          _backupBloc.add(CheckBackup());

          await Future.delayed(Duration(milliseconds: 300));
          DialogController.dismiss(context);
          Navigator.of(context).pop();
        }
        if (state is PasswordUpdateFail) {
          DialogController.dismiss(context);

          DialogController.show(
              context, ErrorDialog(t('error_update_password')), onDismiss: () {
            _bloc.add(
              CleanUpdatePassword(),
            );
          });
        }
      },
      child: BlocBuilder<UpdatePasswordBloc, UpdatePasswordState>(
          cubit: _bloc,
          builder: (BuildContext ctx, UpdatePasswordState state) {
            if (state is UpdatePasswordStateCheck) {
              return CheckingView(_bloc, state, widget.appBarHeight);
            }
            return SizedBox();
          }),
    );
  }
}

class CheckingView extends StatefulWidget {
  final UpdatePasswordBloc _bloc;
  final UpdatePasswordStateCheck _state;
  final double appBarHeight;

  CheckingView(this._bloc, this._state, this.appBarHeight);

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
    return Container(
      child: Form(
        key: _form,
        child: IntrinsicHeight(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                    color: Theme.of(context).primaryColorDark.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(4.0)),
                padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
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
                padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 15.0),
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
              Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 36.0, vertical: 48.0),
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
              )
            ],
          ),
        ),
      ),
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
