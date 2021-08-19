import 'package:bloc/bloc.dart';

import '../helpers/logger.dart';
import 'account_list/account_list_bloc.dart';
import 'account_detail/account_detail_bloc.dart';

class ObserverDelegate extends BlocObserver {
  @override
  void onEvent(Bloc bloc, Object? event) {
    if (bloc is! AccountListBloc && bloc is! AccountDetailBloc) {
      Log.debug('BLOC onEvent $event');
    }
    super.onEvent(bloc, event);
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    if (bloc is! AccountListBloc && bloc is! AccountDetailBloc) {
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
