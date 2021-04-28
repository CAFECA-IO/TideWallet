import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../widgets/appBar.dart';
import '../widgets/inputs/password_input.dart';
import '../widgets/buttons/primary_button.dart';
import '../widgets/dialogs/dialog_controller.dart';
import '../widgets/dialogs/error_dialog.dart';
import '../blocs/user/user_bloc.dart';
import '../blocs/mnemonic/mnemonic_bloc.dart';
import '../repositories/third_party_sign_in_repository.dart';
import '../helpers/i18n.dart';

class RecoverMemonicScreen extends StatefulWidget {
  static const routeName = '/recover-mnemonic';
  @override
  _RecoverMemonicScreenState createState() => _RecoverMemonicScreenState();
}

class _RecoverMemonicScreenState extends State<RecoverMemonicScreen> {
  final t = I18n.t;

  TextEditingController _controller = new TextEditingController();
  TextEditingController _pwdController = new TextEditingController();
  TextEditingController _rePwdController = new TextEditingController();
  MnemonicBloc _bloc = MnemonicBloc(ThirdPartySignInRepository());
  UserBloc _userBloc;

  @override
  void didChangeDependencies() {
    _userBloc = BlocProvider.of<UserBloc>(context);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _bloc.close();
    _controller.dispose();
    _pwdController.dispose();
    _rePwdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: GeneralAppbar(
        routeName: RecoverMemonicScreen.routeName,
      ),
      body: BlocListener<MnemonicBloc, MnemonicState>(
        listener: (context, state) {
          if (state is MnemonicSuccess) {
            Navigator.of(context).popUntil(
              (ModalRoute.withName('/')),
            );
            _userBloc
                .add(UserCreateWithSeed(state.userIndentifier, state.seed));
          }

          if (state is MnemonicTyping) {
            if (state.error == MNEMONIC_ERROR.MNEMONIC_INVALID) {
              DialogController.show(
                context,
                ErrorDialog(
                  t('error_mnemonic'),
                ),
              );
            } else if (state.error == MNEMONIC_ERROR.PASSWORD_NOT_MATCH) {
              DialogController.show(
                context,
                ErrorDialog(
                  t('create_wallet_password_unmatch'),
                ),
              );
            } else if (state.error == MNEMONIC_ERROR.LOGIN) {
              DialogController.show(
                context,
                ErrorDialog(
                  t('error_login'),
                ),
              );
            }
          }
        },
        bloc: _bloc,
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: BlocBuilder<MnemonicBloc, MnemonicState>(
            bloc: _bloc,
            builder: (context, state) {
              var submit;

              if (state is MnemonicTyping) {
                if (state.error == MNEMONIC_ERROR.NONE &&
                    state.mnemonic.isNotEmpty) {
                  submit = () => {_bloc.add(SubmitMnemonic())};
                }
              }

              return Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 10.0),
                    width: double.infinity,
                    decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.4)),
                    padding: const EdgeInsets.all(16.0),
                    child: Text(t('mnemonic_message')),
                  ),
                  Container(
                      margin: const EdgeInsets.only(bottom: 30.0),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 8.0),
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: Theme.of(context).primaryColor)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t('mnemonic_enter'),
                            style:
                                TextStyle(color: Theme.of(context).accentColor),
                          ),
                          TextField(
                            controller: _controller,
                            onChanged: (String v) {
                              _bloc.add(InputMnemo(v));
                            },
                            minLines: 3,
                            maxLines: 3,
                            decoration: InputDecoration(
                              // isDense: true,
                              contentPadding: const EdgeInsets.all(4.0),
                              // labelText: "labelText",
                              border: InputBorder.none,
                            ),
                          ),
                        ],
                      )),
                  Container(
                    margin: const EdgeInsets.only(bottom: 30.0),
                    child: PasswordInput(
                      label: t('password'),
                      validator: null,
                      onChanged: (v) {
                        _bloc.add(InputMnemoPassword(v));
                      },
                      controller: this._pwdController,
                    ),
                  ),
                  Container(
                    child: PasswordInput(
                      label: t('password-repeat'),
                      validator: null,
                      onChanged: (v) {
                        _bloc.add(InputMnemoRePassword(v));
                      },
                      controller: this._rePwdController,
                    ),
                  ),
                  Spacer(),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 50.0),
                    child: PrimaryButton('確認', submit,
                        disableColor: Theme.of(context).disabledColor,
                        borderColor: Colors.transparent),
                  )
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
