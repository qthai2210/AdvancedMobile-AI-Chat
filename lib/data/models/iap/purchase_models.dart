import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';

/// Enum to represent the status of a purchase
enum AppPurchaseStatus {
  /// The purchase is currently pending (e.g., awaiting payment)
  pending,

  /// The purchase was completed successfully
  completed,

  /// The purchase failed
  failed,

  /// The purchase was cancelled by the user
  cancelled,

  /// The purchase was restored from a previous transaction
  restored,
}

/// A model class representing a product that can be purchased
class AppProduct {
  /// The product ID (same as in app store)
  final String id;

  /// The title of the product as defined in the app store
  final String title;

  /// The description of the product as defined in the app store
  final String description;

  /// The localized price string (e.g., "$9.99")
  final String price;

  /// The raw numeric price amount
  final double rawPrice;

  /// The currency code (e.g., "USD")
  final String currencyCode;

  /// The currency symbol (e.g., "$")
  final String currencySymbol;

  /// Whether this product is a subscription
  final bool isSubscription;

  /// The original product details from the in_app_purchase package
  final ProductDetails details;

  /// Creates a new AppProduct
  const AppProduct({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.rawPrice,
    required this.currencyCode,
    required this.currencySymbol,
    required this.isSubscription,
    required this.details,
  });

  /// Factory method to create an AppProduct from ProductDetails
  factory AppProduct.fromProductDetails(ProductDetails details) {
    return AppProduct(
      id: details.id,
      title: details.title,
      description: details.description,
      price: details.price,
      rawPrice: details.rawPrice,
      currencyCode: details.currencyCode,
      currencySymbol: details.currencySymbol,
      // Check if product ID contains subscription identifier or use another method
      // This is just an example and should be adapted to your product ID naming
      isSubscription: details.id.contains('premium') ||
          details.id.contains('subscription') ||
          details.id.contains('monthly') ||
          details.id.contains('yearly'),
      details: details,
    );
  }

  @override
  String toString() => 'AppProduct(id: $id, title: $title, price: $price)';
}

/// A model class representing a completed purchase
class AppPurchase {
  /// The purchase ID (same as in app store)
  final String id;

  /// The ID of the purchased product
  final String productId;

  /// The status of the purchase
  final AppPurchaseStatus status;

  /// Any error message, if the purchase failed
  final String? error;

  /// The original purchase details from the in_app_purchase package
  final PurchaseDetails details;

  /// Creates a new AppPurchase
  const AppPurchase({
    required this.id,
    required this.productId,
    required this.status,
    this.error,
    required this.details,
  });

  /// Factory method to create an AppPurchase from PurchaseDetails
  factory AppPurchase.fromPurchaseDetails(PurchaseDetails details) {
    AppPurchaseStatus status;

    // Map the PurchaseStatus to our AppPurchaseStatus
    switch (details.status) {
      case PurchaseStatus.pending:
        status = AppPurchaseStatus.pending;
        break;
      case PurchaseStatus.purchased:
        status = AppPurchaseStatus.completed;
        break;
      case PurchaseStatus.restored:
        status = AppPurchaseStatus.restored;
        break;
      case PurchaseStatus.error:
        status = AppPurchaseStatus.failed;
        break;
      case PurchaseStatus.canceled:
        status = AppPurchaseStatus.cancelled;
        break;
      default:
        status = AppPurchaseStatus.failed;
    }
    return AppPurchase(
      id: details.purchaseID ?? 'unknown_id',
      productId: details.productID,
      status: status,
      error: details.error?.message ??
          (details.status == PurchaseStatus.error
              ? 'Unknown error occurred'
              : null),
      details: details,
    );
  }

  @override
  String toString() =>
      'AppPurchase(id: $id, productId: $productId, status: $status)';
}
