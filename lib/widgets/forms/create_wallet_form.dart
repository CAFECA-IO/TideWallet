import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/create_wallet/create_wallet_bloc.dart';
import '../inputs/input.dart';
import '../inputs/password_input.dart';

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
              Input(
                labelText: '錢包名稱',
                autovalidate: AutovalidateMode.disabled,
                controller: _nameController,
              ),
              SizedBox(height: 16.0),
              PasswordInput(
                label: '密碼',
                onChange: () {},
                controller: _pwdController,
                validator: (String v) => '',
              ),
              SizedBox(height: 16.0),
              PasswordInput(
                label: '再次確認密碼',
                onChange: () {},
                controller: _repwdController,
                validator: (String v) => '',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
