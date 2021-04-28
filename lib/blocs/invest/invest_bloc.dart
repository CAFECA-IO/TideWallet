import 'dart:async';

import '../../models/investment.model.dart';
import '../../repositories/invest_repository.dart';
import '../../repositories/user_repository.dart';
import 'package:decimal/decimal.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'invest_event.dart';
part 'invest_state.dart';

class InvestBloc extends Bloc<InvestEvent, InvestState> {
  final InvestRepository _repo;
  final UserRepository _userRepo;
  StreamSubscription _subscription;
  InvestBloc(this._repo, this._userRepo) : super(InvestInitial()) {
    _subscription?.cancel();
    this._repo.listener.listen((msg) {
      if (msg.evt == INVESTMENT_EVT.OnUpdateInvestment) {
        this.add(UpdateInvestAccountList(msg.value['investAccounts']));
      }
    });
  }

  @override
  Stream<InvestState> mapEventToState(
    InvestEvent event,
  ) async* {
    if (event is GetInvestments) {
      List<InvestAccount> investAccounts =
          await _repo.getInvestmentList(this._userRepo.user.id);
      yield ListInvestments(investAccounts: investAccounts);
    }
    if (event is UpdateInvestAccountList) {
      yield ListInvestments(investAccounts: event.investAccounts);
    }
  }
}
