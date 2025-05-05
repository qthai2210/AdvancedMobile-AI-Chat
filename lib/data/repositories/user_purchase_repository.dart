import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aichatbot/utils/logger.dart';
import 'package:aichatbot/data/models/iap/purchase_models.dart';
import 'package:aichatbot/data/models/iap/purchase_storage_models.dart';

/// Repository for storing and retrieving user purchase data
class UserPurchaseRepository {
  // Keys for SharedPreferences
  static const String _subscriptionsKey = 'user_active_subscriptions';
  static const String _creditsKey = 'user_credits_balance';
  static const String _purchaseHistoryKey = 'user_purchase_history';
  // Key for storing user ID linked to purchases
  static const String _linkedUserIdKey = 'linked_user_id';

  /// Get the user's active subscriptions
  Future<List<AppSubscription>> getActiveSubscriptions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final subscriptionsJson = prefs.getStringList(_subscriptionsKey) ?? [];

      return subscriptionsJson
          .map((json) => AppSubscription.fromJson(jsonDecode(json)))
          .where((subscription) => subscription.isActive)
          .toList();
    } catch (e) {
      AppLogger.e('Error getting active subscriptions: $e');
      return [];
    }
  }

  /// Check if the user has an active subscription
  Future<bool> hasActiveSubscription() async {
    final subscriptions = await getActiveSubscriptions();
    return subscriptions.isNotEmpty;
  }

  /// Store a new subscription
  Future<bool> storeSubscription(AppSubscription subscription) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Get existing subscriptions
      final subscriptionsJson = prefs.getStringList(_subscriptionsKey) ?? [];

      // Convert to objects
      final subscriptions = subscriptionsJson
          .map((json) => AppSubscription.fromJson(jsonDecode(json)))
          .toList();

      // Remove any existing subscription with same ID (to update)
      subscriptions.removeWhere((item) => item.id == subscription.id);

      // Add the new subscription
      subscriptions.add(subscription);

      // Convert back to JSON strings
      final updatedSubscriptionsJson =
          subscriptions.map((item) => jsonEncode(item.toJson())).toList();

      // Save to preferences
      await prefs.setStringList(_subscriptionsKey, updatedSubscriptionsJson);
      // Also store in purchase history
      await addToPurchaseHistory(
        PurchaseHistoryItem(
          productId: subscription.productId,
          purchaseDate: subscription.purchaseDate,
          isSubscription: true,
          expiryDate: subscription.expiryDate,
        ),
      );

      return true;
    } catch (e) {
      AppLogger.e('Error storing subscription: $e');
      return false;
    }
  }

  /// Get user credits balance
  Future<int> getCreditsBalance() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_creditsKey) ?? 0;
    } catch (e) {
      AppLogger.e('Error getting credits balance: $e');
      return 0;
    }
  }

  /// Add credits to user's balance
  Future<bool> addCredits(int credits) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentBalance = prefs.getInt(_creditsKey) ?? 0;
      final newBalance = currentBalance + credits;

      await prefs.setInt(_creditsKey, newBalance);

      return true;
    } catch (e) {
      AppLogger.e('Error adding credits: $e');
      return false;
    }
  }

  /// Get purchase history
  Future<List<PurchaseHistoryItem>> getPurchaseHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getStringList(_purchaseHistoryKey) ?? [];

      return historyJson
          .map((json) => PurchaseHistoryItem.fromJson(jsonDecode(json)))
          .toList();
    } catch (e) {
      AppLogger.e('Error getting purchase history: $e');
      return [];
    }
  }

  /// Add an item to purchase history
  Future<bool> addToPurchaseHistory(PurchaseHistoryItem item) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Get existing history
      final historyJson = prefs.getStringList(_purchaseHistoryKey) ?? [];

      // Convert to objects
      final history = historyJson
          .map((json) => PurchaseHistoryItem.fromJson(jsonDecode(json)))
          .toList();

      // Add the new item
      history.add(item);

      // Convert back to JSON strings
      final updatedHistoryJson =
          history.map((item) => jsonEncode(item.toJson())).toList();

      // Save to preferences
      await prefs.setStringList(_purchaseHistoryKey, updatedHistoryJson);

      return true;
    } catch (e) {
      AppLogger.e('Error adding to purchase history: $e');
      return false;
    }
  }

  /// Link all purchase data to a user ID (for account synchronization)
  Future<bool> linkPurchasesToUser(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Store the user ID
      await prefs.setString(_linkedUserIdKey, userId);

      AppLogger.d('Purchase data linked to user: $userId');
      return true;
    } catch (e) {
      AppLogger.e('Error linking purchases to user: $e');
      return false;
    }
  }

  /// Get the user ID linked to the purchases
  Future<String?> getLinkedUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_linkedUserIdKey);
    } catch (e) {
      AppLogger.e('Error getting linked user ID: $e');
      return null;
    }
  }

  /// Unlink purchases from user (for logout)
  Future<bool> unlinkPurchases() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_linkedUserIdKey);

      AppLogger.d('Purchase data unlinked from user');
      return true;
    } catch (e) {
      AppLogger.e('Error unlinking purchases: $e');
      return false;
    }
  }

  /// Clear all purchase data (for testing)
  Future<void> clearAllPurchaseData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_subscriptionsKey);
      await prefs.remove(_creditsKey);
      await prefs.remove(_purchaseHistoryKey);
      await prefs.remove(_linkedUserIdKey);
    } catch (e) {
      AppLogger.e('Error clearing purchase data: $e');
    }
  }
}
