import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/reset/reset_bloc.dart';
import '../../blocs/user/user_bloc.dart';
import '../../blocs/backup/backup_bloc.dart';

import '../../repositories/account_repository.dart';
import '../../repositories/local_auth_repository.dart';
import '../../repositories/user_repository.dart';
import '../../widgets/dialogs/dialog_controller.dart';
import '../../widgets/dialogs/error_dialog.dart';
import '../../widgets/dialogs/verify_password_dialog.dart';
import '../../widgets/dialogs/success_dialog.dart';
import '../../helpers/i18n.dart';

class ResetSetting extends StatefulWidget {
  final Widget item;

  ResetSetting(this.item);
  @override
  _ResetSettingState createState() => _ResetSettingState();
}

class _ResetSettingState extends State<ResetSetting> {
  final t = I18n.t;

  ResetBloc _bloc;
  UserBloc _userBloc;
  BackupBloc _backupBloc;

  AccountRepository _accountRepository;
  UserRepository _userRepository;

  @override
  void didChangeDependencies() {
    _accountRepository = Provider.of<AccountRepository>(context);
    _userRepository = Provider.of<UserRepository>(context);
    _bloc =
        ResetBloc(_userRepository, _accountRepository, LocalAuthRepository());
    _userBloc = BlocProvider.of<UserBloc>(context);
    _backupBloc = BlocProvider.of<BackupBloc>(context);

    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ResetBloc, ResetState>(
      cubit: _bloc,
      listener: (context, state) async {
        if (state is ResetError) {
          if (state.error == RESET_ERROR.password) {
            DialogController.show(context, ErrorDialog(t('error_password')));
          } else if (state.error == RESET_ERROR.unknown) {
            DialogController.show(context, ErrorDialog(t('error_reset')));
          }
        }

        if (state is ResetSuccess) {
          DialogController.showUnDissmissible(
              context, SuccessDialog(t('success_reset')));

          await Future.delayed(Duration(milliseconds: 500));

          DialogController.dismiss(context);
          _userBloc.add(UserReset());
          _backupBloc.add(CleanBackup());
        }
      },
      child: InkWell(
        child: widget.item,
        onTap: () {
          // DialogController.showUnDissmissible(
          //   context,
          //   VerifyPasswordDialog(
          //     (String password) {
          //       _bloc.add(ResetWallet(password));
          //       DialogController.dismiss(context);
          //     },
          //     (String password) {
          //       DialogController.dismiss(context);
          //     },
          //   ),
          // );
          this._bloc.add(ResetWallet());
        },
      ),
    );
  }
}
