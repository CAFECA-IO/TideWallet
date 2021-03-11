import 'dart:async';

import 'package:tidewallet3/repositories/user_repository.dart';

import '../../models/investment.model.dart';
import '../../repositories/invest_repository.dart';
import 'package:decimal/decimal.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'invest_event.dart';
part 'invest_state.dart';

class InvestBloc extends Bloc<InvestEvent, InvestState> {
  final InvestRepository _repo;
  final UserRepository _userRepo;
  InvestBloc(this._repo, this._userRepo) : super(InvestInitial());

  @override
  Stream<InvestState> mapEventToState(
    InvestEvent event,
  ) async* {
    if (event is GetInvestments) {
      List<InvestAccount> investAccounts =
          await _repo.getInvestmentList(this._userRepo.user.id);
      yield ListInvestments(investAccounts: investAccounts);
    }
  }
}
