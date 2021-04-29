import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:tidewallet3/repositories/buy_tide_point_repository.dart';

part 'buy_tide_point_event.dart';
part 'buy_tide_point_state.dart';

class BuyTidePointBloc extends Bloc<BuyTidePointEvent, BuyTidePointState> {
  BuyTidePointRepository _repo;
  StreamSubscription<List<PurchaseDetails>> _subscription;

  BuyTidePointBloc(this._repo) : super(BuyTidePointInitial()) {
    _subscription?.cancel();
    _subscription = this._repo.purchaseUpdated.listen((purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      _subscription.cancel();
    }, onError: (error) {
      // handle error here.
    });
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    purchaseDetailsList.forEach((PurchaseDetails purchaseDetails) async {
      if (purchaseDetails.status == PurchaseStatus.pending) {
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
        } else if (purchaseDetails.status == PurchaseStatus.purchased) {}
        if (purchaseDetails.pendingCompletePurchase) {
          await InAppPurchaseConnection.instance
              .completePurchase(purchaseDetails);
        }
      }
    });
  }

  @override
  Stream<BuyTidePointState> mapEventToState(
    BuyTidePointEvent event,
  ) async* {
    // TODO: implement mapEventToState
  }
}
