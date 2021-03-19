import 'package:bloc/bloc.dart';

import '../helpers/logger.dart';

class ObserverDelegate extends BlocObserver {
  @override
  void onEvent(Bloc bloc, Object event) {
    Log.debug('BLOC onEvent $event');
    super.onEvent(bloc, event);
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    Log.info('BLOC transition $transition');
    super.onTransition(bloc, transition);

  }

  @override
  void onError(Cubit bloc, Object error, StackTrace stackTrace) {
    Log.error('BLOC $bloc error $error');
    super.onError(bloc, error, stackTrace);
  }
}
