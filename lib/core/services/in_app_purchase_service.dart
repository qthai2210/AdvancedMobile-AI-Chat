import 'dart:async';
import 'dart:io';
import 'package:aichatbot/data/models/iap/purchase_models.dart';
import 'package:aichatbot/data/models/iap/purchase_storage_models.dart';
import 'package:aichatbot/data/repositories/user_purchase_repository.dart';
import 'package:aichatbot/core/services/purchase_verification_service.dart';
import 'package:aichatbot/core/services/purchase_analytics_service.dart';
import 'package:aichatbot/utils/logger.dart';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
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

  // Repository for user purchases
  final UserPurchaseRepository _repository = UserPurchaseRepository();
  // Service for verifying purchases with backend
  final PurchaseVerificationService _verificationService =
      PurchaseVerificationService();

  // Analytics service for tracking purchase events
  final PurchaseAnalyticsService _analytics = PurchaseAnalyticsService();

  // Product IDs - Replace with your actual product IDs from Google Play/App Store
  static const String _premiumSubscriptionMonthly = 'month_subscription';
  static const String _premiumSubscriptionYearly =
      'com.advancedmobile.aichatbot.premium_yearly';
  static const String _consumableCredits50 =
      'com.advancedmobile.aichatbot.credits_50';
  static const String _consumableCredits100 =
      'com.advancedmobile.aichatbot.credits_100';
  static const String _consumableCredits200 =
      'com.advancedmobile.aichatbot.credits_200';

  /// All product IDs
  static final Set<String> productIds = {
    _premiumSubscriptionMonthly,
    _premiumSubscriptionYearly,
    _consumableCredits50,
    _consumableCredits100,
    _consumableCredits200,
  };

  /// Subscription product IDs
  static final Set<String> subscriptionProductIds = {
    _premiumSubscriptionMonthly,
    _premiumSubscriptionYearly,
  };

  /// Consumable product IDs
  static final Set<String> consumableProductIds = {
    _consumableCredits50,
    _consumableCredits100,
    _consumableCredits200,
  };
  // States
  bool _isAvailable = false;
  bool _isInitialized = false;
  List<ProductDetails> _products = [];
  final List<PurchaseDetails> _purchases = [];

  // Stream subscription for purchases
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  // Public getters
  bool get isAvailable => _isAvailable;
  bool get isInitialized => _isInitialized;
  List<ProductDetails> get products => _products;
  List<ProductDetails> get subscriptions => _products
      .where((product) => subscriptionProductIds.contains(product.id))
      .toList();
  List<ProductDetails> get consumables => _products
      .where((product) => consumableProductIds.contains(product.id))
      .toList();

  /// Get the raw purchase stream from the in_app_purchase package
  Stream<List<PurchaseDetails>> get purchaseStream => _iap.purchaseStream;

  /// Initialize the IAP service
  Future<void> initialize() async {
    if (_isInitialized) {
      AppLogger.d('IAP already initialized');
      return;
    }

    // Check if IAP is available on this device
    _isAvailable = await _iap.isAvailable();
    if (!_isAvailable) {
      AppLogger.w('IAP not available on this device');
      return;
    }

    // Set up platform-specific configurations
    if (Platform.isAndroid) {
      // Android-specific configurations (handled by the package)
      AppLogger.d('Initializing Android IAP');
    } else if (Platform.isIOS) {
      // iOS-specific configurations
      // For iOS, you may need additional setup like payment queue delegate
      // but we'll keep it simple for now
      AppLogger.d('Initialized iOS IAP');
    }

    // Listen for purchase updates
    _subscription = _iap.purchaseStream.listen(
      _onPurchaseUpdate,
      onDone: () {
        _subscription?.cancel();
      },
      onError: (error) {
        AppLogger.e('IAP stream error: $error');
      },
    );

    // Load products
    await loadProducts();

    _isInitialized = true;
    AppLogger.d('IAP initialized successfully');
  }

  /// Load available products from the stores
  Future<List<ProductDetails>> loadProducts() async {
    try {
      final ProductDetailsResponse response =
          await _iap.queryProductDetails(productIds);

      if (response.notFoundIDs.isNotEmpty) {
        AppLogger.w('Products not found: ${response.notFoundIDs.join(', ')}');
      }

      _products = response.productDetails;

      AppLogger.d('Loaded ${_products.length} products');
      return _products;
    } catch (e) {
      AppLogger.e('Failed to load products: $e');
      return [];
    }
  }

  /// Handle purchase updates
  void _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) async {
    for (final purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        AppLogger.d('Purchase pending: ${purchaseDetails.productID}');
        // Show a loading UI while purchase is pending
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          AppLogger.e('Error purchasing: ${purchaseDetails.error}');
          // Track the error
          _analytics.trackPurchaseFailed(purchaseDetails.productID,
              purchaseDetails.error?.message ?? 'Unknown error');
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          // Process the purchase (verify, deliver, etc.)
          await _processPurchase(purchaseDetails);

          // Store the purchase for later use
          _purchases.add(purchaseDetails);
        } else if (purchaseDetails.status == PurchaseStatus.canceled) {
          AppLogger.d('Purchase cancelled: ${purchaseDetails.productID}');
          // Track the cancellation
          _analytics.trackPurchaseFailed(
              purchaseDetails.productID, 'User canceled');
        }

        // Complete the purchase to acknowledge it to the store
        if (purchaseDetails.pendingCompletePurchase) {
          await _iap.completePurchase(purchaseDetails);
          AppLogger.d('Purchase completed for: ${purchaseDetails.productID}');
        }
      }
    }
  }

  /// Verify the purchase with your server
  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) async {
    // In a production app, you should implement server-side verification here

    if (purchaseDetails.verificationData.serverVerificationData.isEmpty) {
      AppLogger.w('No verification data available for purchase');
      return false;
    }

    // Verify purchase with backend service
    final isVerified =
        await _verificationService.verifyPurchase(purchaseDetails);

    if (isVerified) {
      AppLogger.d('Purchase verified: ${purchaseDetails.productID}');
      return true;
    } else {
      AppLogger.w('Purchase verification failed: ${purchaseDetails.productID}');
      return false;
    }
  }

  /// Deliver the purchased product to the user
  Future<void> _deliverProduct(PurchaseDetails purchaseDetails) async {
    // Check if it's a subscription or consumable
    if (subscriptionProductIds.contains(purchaseDetails.productID)) {
      // Handle subscription purchase
      await _activateSubscription(purchaseDetails);
    } else if (consumableProductIds.contains(purchaseDetails.productID)) {
      // Handle consumable purchase
      await _addCredits(purchaseDetails);
    }
  }

  /// Activate a subscription
  Future<void> _activateSubscription(PurchaseDetails purchaseDetails) async {
    final productId = purchaseDetails.productID;

    // Calculate expiration date based on product
    final DateTime expiryDate;
    if (productId == _premiumSubscriptionMonthly) {
      expiryDate = DateTime.now().add(const Duration(days: 30));
    } else if (productId == _premiumSubscriptionYearly) {
      expiryDate = DateTime.now().add(const Duration(days: 365));
    } else {
      // Default to monthly
      expiryDate = DateTime.now().add(const Duration(days: 30));
    }

    // Create an AppPurchase from PurchaseDetails
    final appPurchase = AppPurchase.fromPurchaseDetails(purchaseDetails);

    // Create a subscription object
    final subscription = AppSubscription.fromPurchase(appPurchase, expiryDate);

    // Store subscription in persistence layer
    final success = await _repository.storeSubscription(subscription);

    if (success) {
      AppLogger.d('Subscription activated until: $expiryDate');
      _analytics.trackSubscriptionActivated(subscription);
    } else {
      AppLogger.e('Failed to store subscription data');
    }
  }

  /// Add credits for consumable purchase
  Future<void> _addCredits(PurchaseDetails purchaseDetails) async {
    final productId = purchaseDetails.productID;

    // Determine credit amount based on product
    int credits = 0;
    if (productId == _consumableCredits50) {
      credits = 50;
    } else if (productId == _consumableCredits100) {
      credits = 100;
    } else if (productId == _consumableCredits200) {
      credits = 200;
    }

    // Add credits to user balance in persistence layer
    final success = await _repository.addCredits(credits);

    if (success) {
      AppLogger.d('Added $credits credits to user account');

      // Track credits added
      _analytics.trackCreditsAdded(productId, credits);

      // Add to purchase history
      await _repository.addToPurchaseHistory(
        PurchaseHistoryItem(
          productId: productId,
          purchaseDate: DateTime.now(),
          isSubscription: false,
          creditsAdded: credits,
        ),
      );
    } else {
      AppLogger.e('Failed to add credits to user account');
    }

    // On Android, you need to consume the purchase so it can be purchased again
    if (Platform.isAndroid && purchaseDetails is GooglePlayPurchaseDetails) {
      final androidAddition =
          _iap.getPlatformAddition<InAppPurchaseAndroidPlatformAddition>();
      await androidAddition.consumePurchase(purchaseDetails);
      AppLogger.d('Consumed Android purchase: ${purchaseDetails.productID}');
    }
  }

  /// Buy a consumable product
  Future<bool> buyConsumable(ProductDetails product) async {
    if (!_isAvailable) return false;

    try {
      AppLogger.d('Buying consumable: ${product.id}');
      final purchaseParam = PurchaseParam(productDetails: product);
      return _iap.buyConsumable(
        purchaseParam: purchaseParam,
        autoConsume: Platform.isIOS, // iOS handles consumption automatically
      );
    } catch (e) {
      AppLogger.e('Error buying consumable: $e');
      return false;
    }
  }

  /// Buy a subscription
  Future<bool> buySubscription(ProductDetails product) async {
    if (!_isAvailable) return false;

    try {
      AppLogger.d('Buying subscription: ${product.id}');
      final purchaseParam = PurchaseParam(productDetails: product);
      return _iap.buyNonConsumable(purchaseParam: purchaseParam);
    } catch (e) {
      AppLogger.e('Error buying subscription: $e');
      return false;
    }
  }

  /// Process a purchase (new or restored)
  Future<void> _processPurchase(PurchaseDetails purchaseDetails) async {
    // Verify the purchase with the server
    final isVerified = await _verifyPurchase(purchaseDetails);

    if (isVerified) {
      // Create an AppPurchase object
      final appPurchase = AppPurchase.fromPurchaseDetails(purchaseDetails);

      // Track the completed purchase
      _analytics.trackPurchaseCompleted(appPurchase);

      // Complete the purchase (deliver the product)
      await _deliverProduct(purchaseDetails);
    } else {
      // Handle verification failure
      AppLogger.w('Purchase verification failed: ${purchaseDetails.productID}');
      _analytics.trackPurchaseFailed(
          purchaseDetails.productID, 'Verification failed');
    }
  }

  /// Restore previous purchases (especially important for iOS)
  /// This will trigger the purchaseStream listener which will
  /// handle restored purchases just like new purchases
  Future<bool> restorePurchases() async {
    if (!_isAvailable) {
      AppLogger.w('In-app purchases not available, cannot restore');
      return false;
    }

    try {
      AppLogger.d('Restoring purchases...');

      // For iOS, this refreshes receipts and triggers the purchase stream
      // For Android, we need to query purchase history separately
      await _iap.restorePurchases();

      int restoredCount = 0;

      if (Platform.isAndroid) {
        // On Android, we may need to manually check for historical purchases
        final androidAddition =
            _iap.getPlatformAddition<InAppPurchaseAndroidPlatformAddition>();
        final queryResult = await androidAddition.queryPastPurchases();

        AppLogger.d(
            'Android purchase history queried: ${queryResult.pastPurchases.length} items found');

        // Process past purchases that weren't handled already
        for (final purchase in queryResult.pastPurchases) {
          // Only process completed purchases
          if (purchase.status == PurchaseStatus.purchased ||
              purchase.status == PurchaseStatus.restored) {
            await _processPurchase(purchase);
            restoredCount++;
          }
        }
      }

      // Track restored purchases in analytics
      _analytics.trackPurchasesRestored(restoredCount);

      AppLogger.d('Purchase restoration completed');
      return true;
    } catch (e) {
      AppLogger.e('Error restoring purchases: $e');
      return false;
    }
  }

  /// Check if the user has any active subscription
  Future<bool> hasActiveSubscription() async {
    return await _repository.hasActiveSubscription();
  }

  /// Get the list of active subscriptions
  Future<List<AppSubscription>> getActiveSubscriptions() async {
    return await _repository.getActiveSubscriptions();
  }

  /// Get the current credit balance for the user
  Future<int> getCreditsBalance() async {
    return await _repository.getCreditsBalance();
  }

  /// Get the user's purchase history
  Future<List<PurchaseHistoryItem>> getPurchaseHistory() async {
    return await _repository.getPurchaseHistory();
  }

  /// Link purchases to a user account
  Future<bool> linkPurchasesToUser(String userId) async {
    return await _repository.linkPurchasesToUser(userId);
  }

  /// Get the ID of the user linked to these purchases
  Future<String?> getLinkedUserId() async {
    return await _repository.getLinkedUserId();
  }

  /// Unlink purchases from user account (for logout)
  Future<bool> unlinkPurchases() async {
    return await _repository.unlinkPurchases();
  }

  /// Clear all purchase data (for testing only)
  Future<void> clearPurchaseData() async {
    await _repository.clearAllPurchaseData();
    AppLogger.d('Purchase data cleared');
  }

  /// Dispose resources
  void dispose() {
    _subscription?.cancel();
    _isInitialized = false;
    AppLogger.d('IAP service disposed');
  }

  /// Get all subscription products
  List<AppProduct> getSubscriptionProducts() {
    return _products
        .where((product) => subscriptionProductIds.contains(product.id))
        .map((product) => AppProduct.fromProductDetails(product))
        .toList();
  }

  /// Get all consumable products
  List<AppProduct> getConsumableProducts() {
    return _products
        .where((product) => !subscriptionProductIds.contains(product.id))
        .map((product) => AppProduct.fromProductDetails(product))
        .toList();
  }

  /// Get a product by its ID
  AppProduct? getProductById(String productId) {
    try {
      final product =
          _products.firstWhere((product) => product.id == productId);
      return AppProduct.fromProductDetails(product);
    } catch (e) {
      return null;
    }
  }
}
