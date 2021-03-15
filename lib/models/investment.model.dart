import 'package:decimal/decimal.dart';

import 'account.model.dart';

enum InvestStrategy { Climb, Decline, Fluctuating }
enum InvestAmplitude { Low, Normal, High }

extension InvestStrategyExft on InvestStrategy {
  String get value {
    switch (this) {
      case InvestStrategy.Climb:
        return 'strategy_of_climb';
        break;
      case InvestStrategy.Decline:
        return 'strategy_of_decline';
        break;
      case InvestStrategy.Fluctuating:
        return 'strategy_of_flutuating';
        break;
      default:
        return 'unknown';
        break;
    }
  }
}

extension InvestAmplitudeExt on InvestAmplitude {
  String get value {
    switch (this) {
      case InvestAmplitude.Low:
        return 'low_amplitude';
        break;
      case InvestAmplitude.Normal:
        return 'high_amplitude';
        break;
      case InvestAmplitude.High:
        return 'high_amplitude';
        break;
      default:
        return 'unknown';
        break;
    }
  }
}

class InvestAccount {
  final Currency currency;
  final List<Investment> investments;

  InvestAccount(this.currency, this.investments);
}

class Investment {
  final String id;
  final InvestStrategy investStrategy;
  final InvestAmplitude investAmplitude;
  final Decimal investAmount;
  final Decimal iRR; //Internal Rate of Return

  Investment(this.id, this.investStrategy, this.investAmplitude,
      this.investAmount, this.iRR);
}
