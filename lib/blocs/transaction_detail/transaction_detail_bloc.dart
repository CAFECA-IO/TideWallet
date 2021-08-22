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
      yield TransactionDetailLoading();
      Map transactionDetail =
          await this._repo.getTransactionDetail(event.accountId, event.txid);
      Account account = transactionDetail["account"];
      Account shareAccount = transactionDetail["shareAccount"];
      Transaction transaction = transactionDetail["transaction"];
      yield TransactionDetailLoaded(account, shareAccount, transaction);
    }
    if (state is TransactionDetailLoaded) {
      TransactionDetailLoaded _state = state as TransactionDetailLoaded;
      if (event is UpdateTransaction) {
        if (_state.transaction.txId == event.transaction.txId) {
          yield TransactionDetailLoaded(
              event.account, _state.shareAccount, event.transaction);
        }
      }
    }
  }
}
