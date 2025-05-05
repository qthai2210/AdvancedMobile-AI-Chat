import 'package:aichatbot/data/models/iap/purchase_models.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';

void main() {
  // Testing model imports
  print(AppPurchaseStatus.completed);

  // Create a product
  final productDetails = ProductDetails(
    id: 'test_id',
    title: 'Test Product',
    description: 'A test product',
    price: '9.99',
    rawPrice: 9.99,
    currencyCode: 'USD',
    currencySymbol: r'$',
  );

  final appProduct = AppProduct.fromProductDetails(productDetails);

  // Access Android platform additions
  final iap = InAppPurchase.instance;
  final androidAddition =
      iap.getPlatformAddition<InAppPurchaseAndroidPlatformAddition>();
  // androidAddition.enablePendingPurchases();

  print('Models loaded successfully');
}
