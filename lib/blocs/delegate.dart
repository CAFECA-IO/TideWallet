import 'package:bloc/bloc.dart';

class ObserverDelegate extends BlocObserver {
  @override
  void onEvent(Bloc bloc, Object event) {
    super.onEvent(bloc, event);
    print('BLOC onEvent $event');
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    print('BLOC transition $transition');
    super.onTransition(bloc, transition);
  }

  @override
  void onError(Cubit bloc, Object error, StackTrace stackTrace) {
    print('BLOC error $error');

    super.onError(bloc, error, stackTrace);
  }
}
