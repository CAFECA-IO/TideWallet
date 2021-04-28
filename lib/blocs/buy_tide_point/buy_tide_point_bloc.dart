import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'buy_tide_point_event.dart';
part 'buy_tide_point_state.dart';

class BuyTidePointBloc extends Bloc<BuyTidePointEvent, BuyTidePointState> {
  BuyTidePointBloc() : super(BuyTidePointInitial());

  @override
  Stream<BuyTidePointState> mapEventToState(
    BuyTidePointEvent event,
  ) async* {
    // TODO: implement mapEventToState
  }
}
