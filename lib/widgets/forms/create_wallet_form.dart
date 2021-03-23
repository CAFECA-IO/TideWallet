import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/create_wallet/create_wallet_bloc.dart';
import '../../blocs/user/user_bloc.dart';
import '../inputs/input.dart';
import '../inputs/password_input.dart';
import '../buttons/secondary_button.dart';
import '../dialogs/dialog_controller.dart';
import '../dialogs/error_dialog.dart';
import '../../helpers/i18n.dart';

class CreateWalletForm extends StatefulWidget {
  @override
  _CreateWalletFormState createState() => _CreateWalletFormState();
}

class _CreateWalletFormState extends State<CreateWalletForm> {
  CreateWalletBloc _bloc = CreateWalletBloc();
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
    return BlocListener<CreateWalletBloc, CreateWalletState>(
      bloc: _bloc,
      listener: (context, state) {
        CreateWalletCheck _state = state;
        if (_state.error != null && _state.error != CreateFormError.none) {
          String _text = '';

          switch (_state.error) {
            case CreateFormError.nameEmpty:
              _text = t('create_wallet_name_empty');
              break;
            case CreateFormError.passwordInvalid:
              _text = t('create_wallet_invalid_password');
              break;
            case CreateFormError.passwordNotMatch:
              _text = t('create_wallet_password_unmatch');
              break;
            default:
          }
          DialogController.show(context, ErrorDialog(_text), onDismiss: () {
             _bloc.add(
              CleanCreateWalletError(),
            );
          });
        }

        if (_state.error == CreateFormError.none) {
          Navigator.of(context).pop();
          _userBloc.add(UserCreate(_state.password, _state.name));
        }
      },
      child: BlocBuilder<CreateWalletBloc, CreateWalletState>(
          bloc: _bloc,
          builder: (BuildContext ctx, CreateWalletState state) {
            if (state is CreateWalletCheck) {
              return CheckingView(_bloc, state);
            }

            return SizedBox();
          }),
    );
  }
}

class CheckingView extends StatefulWidget {
  final CreateWalletBloc _bloc;
  final CreateWalletCheck _state;
  CheckingView(this._bloc, this._state);

  @override
  _CheckingViewState createState() => _CheckingViewState();
}

class _CheckingViewState extends State<CheckingView> {
  final TextEditingController _nameController = TextEditingController();
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
          style: TextStyle(fontSize: 12.0),
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
          title = t('create_wallet_rule_4');
          break;
        default:
      }
      list.add(PasswordItem(title, rules[i]));
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        margin: EdgeInsets.only(top: 50.0),
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t('create_hot_wallet'),
                style: Theme.of(context).textTheme.headline1,
              ),
              Container(
                decoration: BoxDecoration(
                    color: Theme.of(context).accentColor,
                    borderRadius: BorderRadius.circular(4.0)),
                padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                margin: EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  t('create_wallet_message'),
                  style: TextStyle(color: Colors.white),
                ),
              ),
              Input(
                labelText: t('wallet_name'),
                autovalidate: AutovalidateMode.disabled,
                controller: _nameController,
                onChanged: (String v) {
                  widget._bloc.add(InputWalletName(v));
                },
              ),
              SizedBox(height: 16.0),
              PasswordInput(
                label: t('password'),
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
                label: t('re_password'),
                controller: _repwdController,
                validator: (String v) => '',
                onChanged: (String v) {
                  widget._bloc.add(InputRePassword(v));
                },
              ),
              SizedBox(height: 24.0),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 36.0),
                child: SecondaryButton(
                  t('confirm'),
                  () {
                    widget._bloc.add(SubmitCreateWallet());
                  },
                  borderColor: Theme.of(context).accentColor,
                  textColor: Theme.of(context).accentColor,
                ),
              ),
              SizedBox(height: 50.0)
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
    final _color = Theme.of(context).primaryColor;

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
          Text(this._title,
              style: TextStyle(
                color: _color,
              ))
        ],
      ),
    );
  }
}
