import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// A utility class to manage user purchase preferences and data using SharedPreferences
class UserPurchasePreferences {
  // Keys for SharedPreferences
  static const String _premiumKey = 'user_premium_status';
  static const String _premiumExpiryKey = 'user_premium_expiry';
  static const String _tokenBalanceKey = 'user_token_balance';
  static const String _purchaseHistoryKey = 'user_purchase_history';

  /// Check if the user has premium status
  static Future<bool> isPremium() async {
    final prefs = await SharedPreferences.getInstance();
    final expiryTimestamp = prefs.getInt(_premiumExpiryKey);

    if (expiryTimestamp == null) {
      return false;
    }

    final expiryDate = DateTime.fromMillisecondsSinceEpoch(expiryTimestamp);
    return DateTime.now().isBefore(expiryDate);
  }

  /// Get premium expiration date
  static Future<DateTime?> getPremiumExpiryDate() async {
    final prefs = await SharedPreferences.getInstance();
    final expiryTimestamp = prefs.getInt(_premiumExpiryKey);

    if (expiryTimestamp == null) {
      return null;
    }

    return DateTime.fromMillisecondsSinceEpoch(expiryTimestamp);
  }

  /// Set premium status with an expiration date
  static Future<bool> setPremium({required DateTime expiryDate}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_premiumKey, true);
      await prefs.setInt(_premiumExpiryKey, expiryDate.millisecondsSinceEpoch);
      return true;
    } catch (e) {
      print('Error setting premium status: $e');
      return false;
    }
  }

  /// Clear premium status
  static Future<bool> clearPremium() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_premiumKey, false);
      await prefs.remove(_premiumExpiryKey);
      return true;
    } catch (e) {
      print('Error clearing premium status: $e');
      return false;
    }
  }

  /// Get token balance
  static Future<int> getTokenBalance() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_tokenBalanceKey) ?? 0;
  }

  /// Add tokens to balance
  static Future<bool> addTokens(int amount) async {
    try {
      if (amount <= 0) {
        return false;
      }

      final prefs = await SharedPreferences.getInstance();
      final currentBalance = prefs.getInt(_tokenBalanceKey) ?? 0;
      await prefs.setInt(_tokenBalanceKey, currentBalance + amount);
      return true;
    } catch (e) {
      print('Error adding tokens: $e');
      return false;
    }
  }

  /// Use tokens from balance
  static Future<bool> useTokens(int amount) async {
    try {
      if (amount <= 0) {
        return false;
      }

      final prefs = await SharedPreferences.getInstance();
      final currentBalance = prefs.getInt(_tokenBalanceKey) ?? 0;

      if (currentBalance < amount) {
        return false; // Not enough tokens
      }

      await prefs.setInt(_tokenBalanceKey, currentBalance - amount);
      return true;
    } catch (e) {
      print('Error using tokens: $e');
      return false;
    }
  }

  /// Record a purchase in the history
  static Future<bool> recordPurchase({
    required String productId,
    required String purchaseId,
    required double amount,
    required String currencyCode,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getStringList(_purchaseHistoryKey) ?? [];

      // Create purchase record
      final purchase = {
        'productId': productId,
        'purchaseId': purchaseId,
        'amount': amount,
        'currencyCode': currencyCode,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      // Add to history
      historyJson.add(jsonEncode(purchase));
      await prefs.setStringList(_purchaseHistoryKey, historyJson);

      return true;
    } catch (e) {
      print('Error recording purchase: $e');
      return false;
    }
  }

  /// Get purchase history
  static Future<List<Map<String, dynamic>>> getPurchaseHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getStringList(_purchaseHistoryKey) ?? [];

    return historyJson
        .map((item) => jsonDecode(item) as Map<String, dynamic>)
        .toList();
  }

  /// Clear all purchase data (for testing or account reset)
  static Future<bool> clearAllPurchaseData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_premiumKey);
      await prefs.remove(_premiumExpiryKey);
      await prefs.remove(_tokenBalanceKey);
      await prefs.remove(_purchaseHistoryKey);
      return true;
    } catch (e) {
      print('Error clearing purchase data: $e');
      return false;
    }
  }
}
