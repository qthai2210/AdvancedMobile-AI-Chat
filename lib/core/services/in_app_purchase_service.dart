import 'dart:async';
import 'package:in_app_purchase/in_app_purchase.dart';

/// Service to handle in-app purchases
class InAppPurchaseService {
  final InAppPurchase _iap = InAppPurchase.instance;

  /// Check availability of the In-App Purchase system
  Future<bool> isAvailable() => _iap.isAvailable();

  /// Query product details by IDs
  Future<List<ProductDetails>> queryProducts(Set<String> productIds) async {
    final response = await _iap.queryProductDetails(productIds);
    if (response.error != null) {
      throw response.error!;
    }
    return response.productDetails;
  }

  /// Stream of purchase update lists
  Stream<List<PurchaseDetails>> get purchaseStream => _iap.purchaseStream;

  /// Buy a consumable product, returns success status
  Future<bool> buyConsumable(ProductDetails product) {
    final purchaseParam = PurchaseParam(productDetails: product);
    return _iap.buyConsumable(purchaseParam: purchaseParam, autoConsume: true);
  }

  /// Restore past purchases
  Future<void> restorePurchases() => _iap.restorePurchases();
}
