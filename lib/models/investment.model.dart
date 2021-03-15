import 'package:decimal/decimal.dart';

import 'account.model.dart';

enum InvestStrategy { Climb, Decline, Fluctuating }
enum InvestAmplitude { Low, Normal, High }
enum InvestPercentage { Low, Normal, High }

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
  int get index {
    switch (this) {
      case InvestAmplitude.Low:
        return 0;
        break;
      case InvestAmplitude.Normal:
        return 1;
        break;
      case InvestAmplitude.High:
        return 2;
        break;
      default:
        return 0;
        break;
    }
  }

  String get value {
    switch (this) {
      case InvestAmplitude.Low:
        return 'low_amplitude';
        break;
      case InvestAmplitude.Normal:
        return 'normal_amplitude';
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

extension InvestPercentageExt on InvestPercentage {
  int get index {
    switch (this) {
      case InvestPercentage.Low:
        return 0;
        break;
      case InvestPercentage.Normal:
        return 1;
        break;
      case InvestPercentage.High:
        return 2;
        break;
      default:
        return 0;
        break;
    }
  }

  String get value {
    switch (this) {
      case InvestPercentage.Low:
        return '10';
        break;
      case InvestPercentage.Normal:
        return '50';
        break;
      case InvestPercentage.High:
        return '90';
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
