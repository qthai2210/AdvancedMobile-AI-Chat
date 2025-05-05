import 'dart:async';
import 'dart:io';
import 'package:aichatbot/data/models/iap/purchase_models.dart';
import 'package:aichatbot/utils/logger.dart';
import 'package:aichatbot/utils/user_purchase_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';

/// Service to handle in-app purchases based on the official in_app_purchase package
/// documentation at https://pub.dev/packages/in_app_purchase
class InAppPurchaseService {
  // Singleton pattern
  static final InAppPurchaseService _instance =
      InAppPurchaseService._internal();

  factory InAppPurchaseService() => _instance;

  InAppPurchaseService._internal();

  // The main InAppPurchase instance
  final InAppPurchase _iap = InAppPurchase.instance;

  // Product IDs - Replace with your actual product IDs from Google Play/App Store
  static const String _premiumSubscriptionMonthly = 'ai_premium_monthly';
  static const String _premiumSubscriptionYearly = 'ai_premium_yearly';
  static const String _consumableCredits50 = 'ai_credits_50';
  static const String _consumableCredits100 = 'ai_credits_100';
  static const String _consumableCredits200 = 'ai_credits_200';

  /// All product IDs
  static const Set<String> _productIds = {
    _premiumSubscriptionMonthly,
    _premiumSubscriptionYearly,
    _consumableCredits50,
    _consumableCredits100,
    _consumableCredits200,
  };

  /// Subscription product IDs
  static const Set<String> _subscriptionProductIds = {
    _premiumSubscriptionMonthly,
    _premiumSubscriptionYearly,
  };

  /// Consumable product IDs
  static const Set<String> _consumableProductIds = {
    _consumableCredits50,
    _consumableCredits100,
    _consumableCredits200,
  };

  /// Stream controller for purchase updates
  final StreamController<AppPurchase> _purchaseController =
      StreamController<AppPurchase>.broadcast();

  /// Stream of purchase updates
  Stream<AppPurchase> get purchaseUpdates => _purchaseController.stream;

  /// Available products
  List<AppProduct> _availableProducts = [];
  bool _isAvailable = false;

  /// StreamSubscription for purchase updates
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  /// Flag to track if service is initialized
  bool _isInitialized = false;

  /// Check if service is initialized
  bool get isInitialized => _isInitialized;

  /// Initialize the service
  Future<void> initialize() async {
    if (_isInitialized) {
      AppLogger.d('InAppPurchaseService already initialized');
      return;
    }

    AppLogger.d('Initializing InAppPurchaseService');

    // Check if IAP is available on this device
    _isAvailable = await isAvailable();
    if (!_isAvailable) {
      AppLogger.w('In-app purchases not available on this device');
      return;
    }

    // Set platform-specific options
    if (Platform.isAndroid) {
      // Set up Android-specific features
      // final InAppPurchaseAndroidPlatformAddition androidPlatformAddition =
      //     _iap.getPlatformAddition<InAppPurchaseAndroidPlatformAddition>();
      // await androidPlatformAddition.;
    } else if (Platform.isIOS) {
      // Set up iOS-specific features if needed
      // final InAppPurchaseStoreKitPlatformAddition iosPlatformAddition =
      //    _iap.getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();

      // You can set delegates or additional configuration here if needed
    }

    // Set up purchase stream listener for real-time purchase updates
    _subscription = _iap.purchaseStream.listen(
      _handlePurchaseUpdate,
      onError: (error) {
        AppLogger.e('Purchase stream error: $error');
      },
      onDone: () {
        _subscription?.cancel();
      },
    );

    // Load products
    await loadProducts();

    _isInitialized = true;
    AppLogger.d('InAppPurchaseService initialization completed');
  }

  /// Dispose resources
  void dispose() {
    _subscription?.cancel();
    _purchaseController.close();
    _isInitialized = false;
    AppLogger.d('InAppPurchaseService disposed');
  }

  /// Check availability of the In-App Purchase system
  Future<bool> isAvailable() async {
    final bool available = await _iap.isAvailable();
    AppLogger.d('IAP available: $available');
    return available;
  }

  /// Load available products
  Future<List<AppProduct>> loadProducts() async {
    if (!_isAvailable) {
      AppLogger.w('IAP not available, cannot load products');
      return [];
    }

    try {
      AppLogger.d(
          'Querying product details for ${_productIds.length} products');
      final ProductDetailsResponse response =
          await _iap.queryProductDetails(_productIds);

      if (response.notFoundIDs.isNotEmpty) {
        AppLogger.w('Products not found: ${response.notFoundIDs.join(", ")}');
      }

      if (response.error != null) {
        AppLogger.e('Error loading products: ${response.error}');
        return [];
      }

      _availableProducts = response.productDetails
          .map((details) => AppProduct.fromProductDetails(details))
          .toList();

      AppLogger.d('Loaded ${_availableProducts.length} products');
      return _availableProducts;
    } catch (e) {
      AppLogger.e('Error querying product details: $e');
      return [];
    }
  }

  /// Get available products
  List<AppProduct> getAvailableProducts() => _availableProducts;

  /// Get available subscription products
  List<AppProduct> getAvailableSubscriptions() {
    return _availableProducts
        .where((product) => _subscriptionProductIds.contains(product.id))
        .toList();
  }

  /// Get available consumable products
  List<AppProduct> getAvailableConsumables() {
    return _availableProducts
        .where((product) => _consumableProductIds.contains(product.id))
        .toList();
  }

  /// Handle purchase updates from the InAppPurchase.purchaseStream
  void _handlePurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    AppLogger.d('Received ${purchaseDetailsList.length} purchase updates');

    for (final purchaseDetails in purchaseDetailsList) {
      // Create our wrapper model
      final appPurchase = AppPurchase.fromPurchaseDetails(purchaseDetails);
      _purchaseController.add(appPurchase);

      AppLogger.d(
          'Processing purchase: ${purchaseDetails.productID} with status ${purchaseDetails.status}');

      // Handle different purchase states
      switch (purchaseDetails.status) {
        case PurchaseStatus.pending:
          _handlePendingPurchase(purchaseDetails);
          break;
        case PurchaseStatus.purchased:
          _handleCompletedPurchase(purchaseDetails);
          break;
        case PurchaseStatus.restored:
          _handleRestoredPurchase(purchaseDetails);
          break;
        case PurchaseStatus.error:
          _handleFailedPurchase(purchaseDetails);
          break;
        case PurchaseStatus.canceled:
          _handleCancelledPurchase(purchaseDetails);
          break;
      }

      // Complete the purchase to acknowledge it to the store
      if (purchaseDetails.pendingCompletePurchase) {
        AppLogger.d('Completing purchase for ${purchaseDetails.productID}');
        _iap.completePurchase(purchaseDetails);
      }
    }
  }

  /// Handle a purchase that is pending
  void _handlePendingPurchase(PurchaseDetails purchase) {
    AppLogger.d('Purchase pending: ${purchase.productID}');
    // You may want to show a loading indicator in your UI
  }

  /// Handle a completed purchase
  Future<void> _handleCompletedPurchase(PurchaseDetails purchase) async {
    AppLogger.d('Purchase completed: ${purchase.productID}');
    // Verify the purchase with your backend server
    await _verifyPurchase(purchase);

    // Process the purchase based on whether it's a subscription or consumable
    if (_consumableProductIds.contains(purchase.productID)) {
      if (Platform.isAndroid) {
        await _consumeAndroidPurchase(purchase);
      }
    }
  }

  /// Handle a purchase that has been restored
  Future<void> _handleRestoredPurchase(PurchaseDetails purchase) async {
    AppLogger.d('Purchase restored: ${purchase.productID}');
    // Similar to completed purchase, but for restored purchases
    await _verifyPurchase(purchase);
  }

  /// Handle a purchase that failed
  void _handleFailedPurchase(PurchaseDetails purchase) {
    AppLogger.e(
        'Purchase failed: ${purchase.productID}, error: ${purchase.error}');
    // You may want to show an error message in your UI
  }

  /// Handle a purchase that was cancelled by the user
  void _handleCancelledPurchase(PurchaseDetails purchase) {
    AppLogger.d('Purchase cancelled: ${purchase.productID}');
    // You may want to show a cancelled message in your UI
  }

  /// Verify purchase with your backend server
  Future<bool> _verifyPurchase(PurchaseDetails purchase) async {
    try {
      AppLogger.d('Verifying purchase: ${purchase.productID}');

      // In a production app, you would verify with your backend:
      // final response = await api.verifyPurchase(
      //   userId: currentUser.id,
      //   productId: purchase.productID,
      //   purchaseId: purchase.purchaseID,
      //   verificationData: purchase.verificationData.serverVerificationData,
      //   platform: Platform.isAndroid ? 'android' : 'ios',
      // );

      // For now, we'll just process the purchase locally
      await _processPurchase(purchase);

      AppLogger.d('Purchase verified and processed for ${purchase.productID}');
      return true;
    } catch (e) {
      AppLogger.e('Error verifying purchase: $e');
      return false;
    }
  }

  /// Process a verified purchase
  Future<void> _processPurchase(PurchaseDetails purchase) async {
    try {
      // Check if this is a subscription or consumable
      if (_subscriptionProductIds.contains(purchase.productID)) {
        // Handle subscription
        final expiryDate = _calculateExpiryDate(purchase.productID);
        await UserPurchasePreferences.setPremium(expiryDate: expiryDate);
        AppLogger.d('Subscription processed until $expiryDate');
      } else if (_consumableProductIds.contains(purchase.productID)) {
        // Handle consumable
        final creditAmount = _getCreditAmount(purchase.productID);
        await UserPurchasePreferences.addTokens(creditAmount);
        AppLogger.d('Added $creditAmount credits to user account');
      }

      // Record the purchase regardless of type
      double price = _getProductPrice(purchase.productID);

      // Try to get the real price from the product details if available
      final matchingProduct = _availableProducts.firstWhere(
        (p) => p.id == purchase.productID,
        orElse: () => throw Exception('Product not found'),
      );

      price = matchingProduct.rawPrice;

      await UserPurchasePreferences.recordPurchase(
        productId: purchase.productID,
        purchaseId: purchase.purchaseID ?? 'unknown',
        amount: price,
        currencyCode: matchingProduct.currencyCode,
      );
    } catch (e) {
      AppLogger.e('Error processing purchase: $e');
    }
  }

  /// For Android, consume a purchase so it can be bought again
  Future<void> _consumeAndroidPurchase(PurchaseDetails purchase) async {
    if (!Platform.isAndroid) return;

    try {
      final InAppPurchaseAndroidPlatformAddition androidAddition =
          _iap.getPlatformAddition<InAppPurchaseAndroidPlatformAddition>();
      await androidAddition.consumePurchase(purchase);
      AppLogger.d('Android purchase consumed: ${purchase.productID}');
    } catch (e) {
      AppLogger.e('Error consuming Android purchase: $e');
    }
  }

  /// Calculate expiry date for a subscription
  DateTime _calculateExpiryDate(String productId) {
    final now = DateTime.now();
    if (productId == _premiumSubscriptionMonthly) {
      return now.add(const Duration(days: 30));
    } else if (productId == _premiumSubscriptionYearly) {
      return now.add(const Duration(days: 365));
    }
    // Default to 30 days if unknown
    return now.add(const Duration(days: 30));
  }

  /// Get credit amount for consumable product
  int _getCreditAmount(String productId) {
    switch (productId) {
      case _consumableCredits50:
        return 50;
      case _consumableCredits100:
        return 100;
      case _consumableCredits200:
        return 200;
      default:
        return 0;
    }
  }

  /// Get product price (would normally come from product details)
  double _getProductPrice(String productId) {
    switch (productId) {
      case _premiumSubscriptionMonthly:
        return 9.99;
      case _premiumSubscriptionYearly:
        return 79.99;
      case _consumableCredits50:
        return 4.99;
      case _consumableCredits100:
        return 8.99;
      case _consumableCredits200:
        return 15.99;
      default:
        return 0.0;
    }
  }

  /// Buy a consumable product, returns success status
  Future<bool> buyConsumable(AppProduct product) async {
    if (!_isAvailable || !_isInitialized) {
      AppLogger.w(
          'IAP not available or not initialized, cannot buy consumable');
      return false;
    }

    try {
      AppLogger.d('Attempting to buy consumable ${product.id}');
      final purchaseParam = PurchaseParam(
        productDetails: product.details,
        applicationUserName: null, // You can pass user ID here
      );

      // The autoConsume parameter is only used on Android
      // On iOS, consumables are consumed automatically by the App Store
      final result = await _iap.buyConsumable(
        purchaseParam: purchaseParam,
        autoConsume: Platform.isAndroid, // Auto-consume on Android
      );

      AppLogger.d('Buy consumable result: $result');
      return result;
    } catch (e) {
      AppLogger.e('Error buying consumable: $e');
      return false;
    }
  }

  /// Buy a subscription product, returns success status
  Future<bool> buySubscription(AppProduct product) async {
    if (!_isAvailable || !_isInitialized) {
      AppLogger.w(
          'IAP not available or not initialized, cannot buy subscription');
      return false;
    }

    try {
      AppLogger.d('Attempting to buy subscription ${product.id}');
      final purchaseParam = PurchaseParam(
        productDetails: product.details,
        applicationUserName: null, // You can pass user ID here
      );

      final result = await _iap.buyNonConsumable(purchaseParam: purchaseParam);
      AppLogger.d('Buy subscription result: $result');
      return result;
    } catch (e) {
      AppLogger.e('Error buying subscription: $e');
      return false;
    }
  }

  /// Upgrade existing subscription (Android only)
  Future<bool> upgradeSubscription(
      AppProduct newProduct, String oldPurchaseId) async {
    if (!Platform.isAndroid) {
      AppLogger.w('Subscription upgrade is available only on Android');
      return false;
    }

    if (!_isAvailable || !_isInitialized) {
      AppLogger.w(
          'IAP not available or not initialized, cannot upgrade subscription');
      return false;
    }

    // Find the old purchase
    final oldPurchase = await _findPurchase(oldPurchaseId);
    if (oldPurchase == null) {
      AppLogger.e('Could not find the old purchase to upgrade from');
      return false;
    }

    try {
      AppLogger.d('Attempting to upgrade subscription to ${newProduct.id}');

      // Create the Android-specific parameters
      final GooglePlayPurchaseParam purchaseParam = GooglePlayPurchaseParam(
          productDetails: newProduct.details,
          changeSubscriptionParam: ChangeSubscriptionParam(
              oldPurchaseDetails: oldPurchase as GooglePlayPurchaseDetails,
              replacementMode: ReplacementMode.withTimeProration));
      final result = await _iap.buyNonConsumable(purchaseParam: purchaseParam);
      AppLogger.d('Upgrade subscription result: $result');
      return result;
    } catch (e) {
      AppLogger.e('Error upgrading subscription: $e');
      return false;
    }
  }

  /// Helper method to find a purchase by ID (for upgrading)
  Future<PurchaseDetails?> _findPurchase(String purchaseId) async {
    // This would typically come from a local database or a query to the store
    // For this example, we'll return null
    return null;
  }

  /// Restore past purchases
  Future<void> restorePurchases() async {
    if (!_isAvailable || !_isInitialized) {
      AppLogger.w(
          'IAP not available or not initialized, cannot restore purchases');
      return;
    }

    try {
      AppLogger.d('Restoring purchases');
      await _iap.restorePurchases();
    } catch (e) {
      AppLogger.e('Error restoring purchases: $e');
      throw e;
    }
  }
}
