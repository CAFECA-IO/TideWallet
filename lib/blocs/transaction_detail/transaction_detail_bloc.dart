import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../models/account.model.dart';
import '../../models/transaction.model.dart';
import '../../repositories/transaction_repository.dart';

part 'transaction_detail_event.dart';
part 'transaction_detail_state.dart';

class TransactionDetailBloc
    extends Bloc<TransactionDetailEvent, TransactionDetailState> {
  TransactionRepository _repo;
  TransactionDetailBloc(this._repo) : super(TransactionDetailInitial());

  @override
  Stream<TransactionDetailState> mapEventToState(
    TransactionDetailEvent event,
  ) async* {
    if (event is GetTransactionDetial) {
      if (state is TransactionLoaded) {
        TransactionLoaded _state = state as TransactionLoaded;
        if (_state.account.id == event.accountId) return;
      }
      Map transactionDetail =
          await this._repo.getTransactionDetail(event.accountId, event.txid);
      Account account = transactionDetail["account"];
      Account shareAccount = transactionDetail["shareAccount"];
      Transaction transaction = transactionDetail["transaction"];
      yield TransactionLoaded(account, shareAccount, transaction);
    }
    if (state is TransactionLoaded) {
      TransactionLoaded _state = state as TransactionLoaded;
      if (event is UpdateTransaction) {
        if (_state.transaction.txId == event.transaction.txId) {
          yield TransactionLoaded(
              event.account, _state.shareAccount, event.transaction);
        }
      }
    }
  }
}
