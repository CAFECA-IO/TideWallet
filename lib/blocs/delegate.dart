import 'package:bloc/bloc.dart';

import '../helpers/logger.dart';
import 'account_currency/account_currency_bloc.dart';
import 'transaction_status/transaction_status_bloc.dart';

class ObserverDelegate extends BlocObserver {
  @override
  void onEvent(Bloc bloc, Object? event) {
    if (bloc is! AccountCurrencyBloc && bloc is! TransactionStatusBloc) {
      Log.debug('BLOC onEvent $event');
    }
    super.onEvent(bloc, event);
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    if (bloc is! AccountCurrencyBloc && bloc is! TransactionStatusBloc) {
      Log.info('BLOC transition $transition');
    }
    super.onTransition(bloc, transition);
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    Log.error('BLOC $bloc error $error');
    super.onError(bloc, error, stackTrace);
  }
}
