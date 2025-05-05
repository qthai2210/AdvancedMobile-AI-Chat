import 'package:aichatbot/data/models/iap/purchase_storage_models.dart';
import 'package:aichatbot/data/models/iap/purchase_models.dart';
import 'package:aichatbot/utils/logger.dart';

/// Service for tracking purchase-related analytics events
class PurchaseAnalyticsService {
  // Singleton pattern
  static final PurchaseAnalyticsService _instance =
      PurchaseAnalyticsService._internal();

  factory PurchaseAnalyticsService() => _instance;
  PurchaseAnalyticsService._internal();

  /// Track when a purchase starts (user initiates a purchase)
  void trackPurchaseStarted(String productId) {
    // In a real app, you would send this to your analytics service
    AppLogger.d('Analytics - Purchase started: $productId');
    _logEvent('purchase_started', {
      'product_id': productId,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  /// Track when a purchase completes successfully
  void trackPurchaseCompleted(AppPurchase purchase) {
    AppLogger.d('Analytics - Purchase completed: ${purchase.productId}');
    _logEvent('purchase_completed', {
      'product_id': purchase.productId,
      'purchase_id': purchase.id,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'is_subscription': _isSubscription(purchase.productId),
    });
  }

  /// Track when a purchase fails
  void trackPurchaseFailed(String productId, String error) {
    AppLogger.d('Analytics - Purchase failed: $productId ($error)');
    _logEvent('purchase_failed', {
      'product_id': productId,
      'error': error,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  /// Track when purchases are restored
  void trackPurchasesRestored(int count) {
    AppLogger.d('Analytics - Purchases restored: $count items');
    _logEvent('purchases_restored', {
      'count': count,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  /// Track when a subscription is activated
  void trackSubscriptionActivated(AppSubscription subscription) {
    AppLogger.d(
        'Analytics - Subscription activated: ${subscription.productId}');
    _logEvent('subscription_activated', {
      'product_id': subscription.productId,
      'purchase_id': subscription.id,
      'expiry_date': subscription.expiryDate.millisecondsSinceEpoch,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  /// Track when a subscription expires or is canceled
  void trackSubscriptionEnded(AppSubscription subscription, String reason) {
    AppLogger.d(
        'Analytics - Subscription ended: ${subscription.productId} ($reason)');
    _logEvent('subscription_ended', {
      'product_id': subscription.productId,
      'purchase_id': subscription.id,
      'reason': reason, // 'expired', 'canceled', etc.
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  /// Track when credits are added to a user account
  void trackCreditsAdded(String productId, int amount) {
    AppLogger.d('Analytics - Credits added: $amount from $productId');
    _logEvent('credits_added', {
      'product_id': productId,
      'amount': amount,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  /// Check if a product ID is a subscription
  bool _isSubscription(String productId) {
    // This should match your logic in InAppPurchaseService
    return productId.contains('premium');
  }

  /// Log an event to your analytics service
  /// (placeholder implementation)
  void _logEvent(String eventName, Map<String, dynamic> params) {
    // In a real app, integrate with Firebase Analytics, Amplitude, etc.
    // For example, with Firebase:
    // FirebaseAnalytics.instance.logEvent(name: eventName, parameters: params);

    AppLogger.d('Analytics Event: $eventName\nParams: $params');
  }
}
