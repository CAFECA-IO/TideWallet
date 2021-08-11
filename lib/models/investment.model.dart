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
      case InvestStrategy.Decline:
        return 'strategy_of_decline';
      case InvestStrategy.Fluctuating:
        return 'strategy_of_flutuating';
      default:
        return 'unknown';
    }
  }
}

extension InvestAmplitudeExt on InvestAmplitude {
  int get index {
    switch (this) {
      case InvestAmplitude.Low:
        return 0;
      case InvestAmplitude.Normal:
        return 1;
      case InvestAmplitude.High:
        return 2;
      default:
        return 0;
    }
  }

  String get value {
    switch (this) {
      case InvestAmplitude.Low:
        return 'low_amplitude';
      case InvestAmplitude.Normal:
        return 'normal_amplitude';
      case InvestAmplitude.High:
        return 'high_amplitude';
      default:
        return 'unknown';
    }
  }
}

extension InvestPercentageExt on InvestPercentage {
  int get index {
    switch (this) {
      case InvestPercentage.Low:
        return 0;
      case InvestPercentage.Normal:
        return 1;
      case InvestPercentage.High:
        return 2;
      default:
        return 0;
    }
  }

  String get value {
    switch (this) {
      case InvestPercentage.Low:
        return '10';
      case InvestPercentage.Normal:
        return '50';
      case InvestPercentage.High:
        return '90';
      default:
        return 'unknown';
    }
  }
}

class InvestAccount {
  final Currency currency;
  final List<Investment> investments;

  InvestAccount(this.currency, this.investments);
}

enum INVESTMENT_EVT { OnUpdateInvestment, ClearAll }

class InvestmentMessage {
  final INVESTMENT_EVT evt;
  final value;

  InvestmentMessage({required this.evt, this.value});
}

class Investment {
  String id;
  final InvestStrategy investStrategy;
  final InvestAmplitude investAmplitude;
  final Decimal investAmount;
  final Decimal fee;
  final Decimal estimateProfit;
  final Decimal iRR; //Internal Rate of Return
  Decimal? feeToFiat;

  Investment(this.id, this.investStrategy, this.investAmplitude,
      this.investAmount, this.fee, this.estimateProfit, this.iRR,
      {this.feeToFiat});
}
