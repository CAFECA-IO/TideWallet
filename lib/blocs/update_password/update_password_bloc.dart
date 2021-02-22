import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../repositories/user_repository.dart';
import '../../helpers/validator.dart';

part 'update_password_event.dart';
part 'update_password_state.dart';

class UpdatePasswordBloc
    extends Bloc<UpdatePasswordEvent, UpdatePasswordState> {
  final UserRepository _userRepo;
  UpdatePasswordBloc(this._userRepo) : super(UpdatePasswordStateCheck());
  Validator _validator = new Validator();

  UpdateFormError validateState(UpdatePasswordStateCheck state) {
    if (!_userRepo.verifyPassword(state.currentPassword))
      return UpdateFormError.wrongPassword;
    if (state.rules.contains(false)) return UpdateFormError.passwordInvalid;
    if (state.password != state.rePassword)
      return UpdateFormError.passwordNotMatch;

    return UpdateFormError.none;
  }

  @override
  Stream<UpdatePasswordState> mapEventToState(
    UpdatePasswordEvent event,
  ) async* {
    UpdatePasswordStateCheck _state = state;

    if (event is InputWalletCurrentPassword) {
      if (_state.password.isNotEmpty) {
        yield _state.copyWith(
          currentPassword: event.currentPassword,
          rules:
              _validator.validPassword(_state.password, event.currentPassword),
        );
      } else {
        yield _state.copyWith(currentPassword: event.currentPassword);
      }
    }

    if (event is InputPassword) {
      yield _state.copyWith(
          password: event.password,
          rules:
              _validator.validPassword(event.password, _state.currentPassword));
    }

    if (event is InputRePassword) {
      yield _state.copyWith(rePassword: event.password);
    }

    if (event is SubmitUpdatePassword) {
      yield _state.copyWith(error: this.validateState(_state));
    }

    if (event is UpdatePassword) {
      yield PasswordUpdating();

      final success = await _userRepo.updatePassword(_state.currentPassword, _state.password);

      if (success) {
        yield PasswordUpdated();
      } else {
        yield PasswordUpdateFail();
      }
    }

    if (event is CleanUpdatePassword) {
      yield _state.copyWith(error: null);
    }
  }
}
