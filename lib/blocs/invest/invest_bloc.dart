import 'dart:async';

import '../../models/investment.model.dart';
import '../../repositories/invest_repository.dart';
import 'package:decimal/decimal.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'invest_event.dart';
part 'invest_state.dart';

class InvestBloc extends Bloc<InvestEvent, InvestState> {
  InvestBloc() : super(InvestInitial());

  @override
  Stream<InvestState> mapEventToState(
    InvestEvent event,
  ) async* {
    // TODO: implement mapEventToState
  }
}
