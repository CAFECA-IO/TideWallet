import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/create_wallet/create_wallet_bloc.dart';
import '../inputs/input.dart';
import '../inputs/password_input.dart';
import '../buttons/secondary_button.dart';

class CreateWalletForm extends StatefulWidget {
  @override
  _CreateWalletFormState createState() => _CreateWalletFormState();
}

class _CreateWalletFormState extends State<CreateWalletForm> {
  CreateWalletBloc _bloc;

  @override
  void didChangeDependencies() {
    _bloc = CreateWalletBloc();

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
      cubit: _bloc,
      listener: (context, state) {
        CreateWalletCheck _state = state;
        if (_state.error != null && _state.error != CreateFormError.none) {
          String _text = '';

          switch (_state.error) {
            case CreateFormError.nameEmpty:
              _text = '未輸入錢包名稱';
              break;
            case CreateFormError.passwordInvalid:
              _text = '未達到密碼強度';
              break;
            case CreateFormError.passwordNotMatch:
              _text = '密碼不相同';
              break;
            default:
          }
          showDialog(
              barrierColor: Colors.transparent,
              context: context,
              builder: (context) {
                return Center(
                  child: AlertDialog(
                    backgroundColor: Theme.of(context).disabledColor.withOpacity(0.95),
                    content: Container(
                      width: 170.0,
                      height: 170.0,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Image.asset('assets/images/ic_fingerprint_error.png'),
                          Text(_text),
                        ],
                      ),
                    ),
                  ),
                );
              }).then((value) => _bloc.add(CleanCreateWalletError()));
        }

        if (_state.error == CreateFormError.none) {
          Navigator.of(context).pushReplacementNamed('/');
        }
      },
      // listenWhen: (CreateWalletState previous, CreateWalletState current) {
      //   if (previous is CreateWalletCheck && current is CreateWalletCheck) {
      //     return true;
      //   }

      //   return true;
      // },
      child: BlocBuilder<CreateWalletBloc, CreateWalletState>(
          cubit: _bloc,
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

  List<Widget> checkList(List<bool> rules) {
    List<Widget> list = [
      Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Text(
          '您的密碼必須包含：',
          style: TextStyle(fontSize: 12.0),
        ),
      )
    ];

    for (int i = 0; i < rules.length; i++) {
      String title = '';

      switch (i) {
        case 0:
          title = '8 ~ 20 個字元';
          break;
        case 1:
          title = '至少 1 個數字';
          break;
        case 2:
          title = '大寫與小寫英文字母';
          break;
        case 3:
          title = '與錢包名稱不同';
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
                '創建熱錢包',
                style: Theme.of(context).textTheme.headline1,
              ),
              Container(
                decoration: BoxDecoration(
                    color: Theme.of(context).accentColor,
                    borderRadius: BorderRadius.circular(4.0)),
                padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                margin: EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  '任何交易行為都將受到自訂密碼保護，請妥善保管密碼並請勿將您的密碼提供給他人，TideWallet 不存儲密碼，也無法幫您找回。',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              Input(
                labelText: '錢包名稱',
                autovalidate: AutovalidateMode.disabled,
                controller: _nameController,
                onChanged: (String v) {
                  widget._bloc.add(InputWalletName(v));
                },
              ),
              SizedBox(height: 16.0),
              PasswordInput(
                label: '密碼',
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
                label: '再次確認密碼',
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
                  '確認',
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
    ));
  }
}
