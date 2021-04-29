import 'dart:async';

import 'package:in_app_purchase/in_app_purchase.dart';

class BuyTidePointRepository {
  static const _productIds = {
    'tide_wallet_point_30',
    'tide_wallet_point_100',
    'tide_wallet_point_500'
  }; // only for google, ios id is different 設定的時候沒注意到兩邊id命名規則不同，所以設定的不一樣，之後改
  InAppPurchaseConnection _connection = InAppPurchaseConnection.instance;

  List<ProductDetails> _products = [];

  Stream<List<PurchaseDetails>> get purchaseUpdated =>
      InAppPurchaseConnection.instance.purchaseUpdatedStream;
  initStoreInfo() async {
    ProductDetailsResponse productDetailResponse =
        await _connection.queryProductDetails(_productIds);
    if (productDetailResponse.error == null) {
      _products = productDetailResponse.productDetails;
    }
  }

  Future<List<ProductDetails>> loadingProducts() async {
    const Set<String> _kIds = <String>{'product1', 'product2'};
    final ProductDetailsResponse response =
        await InAppPurchaseConnection.instance.queryProductDetails(_kIds);
    if (response.notFoundIDs.isNotEmpty) {
      // Handle the error.
      // The in-app purchases won’t appear until the app is published. Just saving in the draft won’t work. You can publish in alpha or beta. Go to you play store dashboard and press the publish button.
    }
    List<ProductDetails> products = response.productDetails;
    return products ?? [];
  }

  bool _isConsumable(ProductDetails productDetails) {
    // ++
  }

  dynamic purchaseProduct(ProductDetails productDetails) {
    final PurchaseParam purchaseParam =
        PurchaseParam(productDetails: productDetails);
    if (_isConsumable(productDetails)) {
      InAppPurchaseConnection.instance
          .buyConsumable(purchaseParam: purchaseParam);
    } else {
      InAppPurchaseConnection.instance
          .buyNonConsumable(purchaseParam: purchaseParam);
    }
  }
}
