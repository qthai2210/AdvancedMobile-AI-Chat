import 'package:aichatbot/data/models/iap/purchase_models.dart';

/// Represents an active subscription
class AppSubscription {
  /// The unique identifier of the subscription purchase
  final String id;

  /// The product ID of the subscription
  final String productId;

  /// When the subscription was purchased
  final DateTime purchaseDate;

  /// When the subscription expires
  final DateTime expiryDate;

  /// Whether the subscription was verified
  final bool isVerified;

  /// Creates a new AppSubscription
  AppSubscription({
    required this.id,
    required this.productId,
    required this.purchaseDate,
    required this.expiryDate,
    this.isVerified = false,
  });

  /// Check if the subscription is currently active
  bool get isActive => DateTime.now().isBefore(expiryDate);

  /// Check if the subscription is expired
  bool get isExpired => !isActive;

  /// Convert to a JSON object
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'purchaseDate': purchaseDate.millisecondsSinceEpoch,
      'expiryDate': expiryDate.millisecondsSinceEpoch,
      'isVerified': isVerified,
    };
  }

  /// Create an AppSubscription from a JSON object
  factory AppSubscription.fromJson(Map<String, dynamic> json) {
    return AppSubscription(
      id: json['id'],
      productId: json['productId'],
      purchaseDate: DateTime.fromMillisecondsSinceEpoch(json['purchaseDate']),
      expiryDate: DateTime.fromMillisecondsSinceEpoch(json['expiryDate']),
      isVerified: json['isVerified'] ?? false,
    );
  }

  /// Create an AppSubscription from an AppPurchase
  factory AppSubscription.fromPurchase(
    AppPurchase purchase,
    DateTime expiryDate,
  ) {
    return AppSubscription(
      id: purchase.id,
      productId: purchase.productId,
      purchaseDate: DateTime.now(),
      expiryDate: expiryDate,
      isVerified: true, // Assume verified if created from a purchase
    );
  }
}

/// Represents an item in the purchase history
class PurchaseHistoryItem {
  /// The product ID that was purchased
  final String productId;

  /// When the purchase was made
  final DateTime purchaseDate;

  /// Whether this is a subscription (vs. a one-time purchase)
  final bool isSubscription;

  /// For subscriptions, when it expires
  final DateTime? expiryDate;

  /// Number of credits added (for consumable purchases)
  final int? creditsAdded;

  /// Creates a new PurchaseHistoryItem
  PurchaseHistoryItem({
    required this.productId,
    required this.purchaseDate,
    required this.isSubscription,
    this.expiryDate,
    this.creditsAdded,
  });

  /// Convert to a JSON object
  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'purchaseDate': purchaseDate.millisecondsSinceEpoch,
      'isSubscription': isSubscription,
      if (expiryDate != null) 'expiryDate': expiryDate!.millisecondsSinceEpoch,
      if (creditsAdded != null) 'creditsAdded': creditsAdded,
    };
  }

  /// Create a PurchaseHistoryItem from a JSON object
  factory PurchaseHistoryItem.fromJson(Map<String, dynamic> json) {
    return PurchaseHistoryItem(
      productId: json['productId'],
      purchaseDate: DateTime.fromMillisecondsSinceEpoch(json['purchaseDate']),
      isSubscription: json['isSubscription'],
      expiryDate: json['expiryDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['expiryDate'])
          : null,
      creditsAdded: json['creditsAdded'],
    );
  }
}
