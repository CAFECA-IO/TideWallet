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

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _pwdController = TextEditingController();
  final TextEditingController _repwdController = TextEditingController();
  final _form = GlobalKey<FormState>();

  @override
  void didChangeDependencies() {
    _bloc = CreateWalletBloc();

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CreateWalletBloc, CreateWalletState>(
      cubit: _bloc,
      builder: (BuildContext ctx, CreateWalletState state) => Container(
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
                  borderRadius: BorderRadius.circular(4.0)
                ),
                padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                margin: EdgeInsets.symmetric(vertical: 16.0),
                child: Text('任何交易行為都將受到自訂密碼保護，請妥善保管密碼並請勿將您的密碼提供給他人，TideWallet 不存儲密碼，也無法幫您找回。', style: TextStyle(color: Colors.white),),
              ),
              Input(
                labelText: '錢包名稱',
                autovalidate: AutovalidateMode.disabled,
                controller: _nameController,
                onChanged: (String v) {
                   _bloc.add(InputWalletName(v));
                },
              ),
              SizedBox(height: 16.0),
              PasswordInput(
                label: '密碼',
                controller: _pwdController,
                validator: (String v) => '',
                onChanged: (String v) {
                  _bloc.add(InputPassword(v));
                },
              ),
              SizedBox(height: 16.0),
              PasswordInput(
                label: '再次確認密碼',
                controller: _repwdController,
                validator: (String v) => '',
                onChanged: (String v) {
                  _bloc.add(InputRePassword(v));
                },
              ),
              SizedBox(height: 24.0),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 36.0),
                child: SecondaryButton(
                  '確認',
                  () => {},
                  borderColor: Theme.of(context).accentColor,
                  textColor: Theme.of(context).accentColor,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
