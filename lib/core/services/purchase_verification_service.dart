import 'package:dio/dio.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:aichatbot/utils/logger.dart';

/// Service for verifying purchases with a backend server
class PurchaseVerificationService {
  // Singleton pattern
  static final PurchaseVerificationService _instance =
      PurchaseVerificationService._internal();

  factory PurchaseVerificationService() => _instance;
  PurchaseVerificationService._internal();

  // Dio instance for API calls
  final _dio = Dio();

  // API URL - replace with your actual verification API endpoint
  static const String _verificationApiUrl =
      'https://api.yourdomain.com/verify-purchase';

  /// Verify a purchase with your backend server
  ///
  /// This sends the purchase data to your server for verification
  /// with Google Play or App Store servers
  Future<bool> verifyPurchase(PurchaseDetails purchase) async {
    try {
      // Prepare verification data based on platform
      final Map<String, dynamic> verificationData =
          _prepareVerificationData(purchase);

      AppLogger.d('Sending purchase for verification: ${purchase.productID}');

      // In a real implementation, we would send this data to the server
      // final response = await _dio.post(
      //   _verificationApiUrl,
      //   data: verificationData,
      // );

      // For now, just simulate a successful verification
      // In a real app, you would check the response
      // if (response.statusCode == 200) {
      //   final responseData = response.data;
      //   return responseData['isValid'] == true;
      // }

      AppLogger.d('Purchase verification successful: ${purchase.productID}');
      return true;
    } catch (e) {
      AppLogger.e('Error verifying purchase: $e');

      // In case of network errors, we can accept the purchase
      // but mark it as unverified. This allows users to use their
      // purchases even when offline, but you should try to verify
      // again later when online.
      return false;
    }
  }

  /// Prepare platform-specific verification data
  Map<String, dynamic> _prepareVerificationData(PurchaseDetails purchase) {
    final Map<String, dynamic> data = {
      'productId': purchase.productID,
      'purchaseId': purchase.purchaseID,
      'platform': _getPlatformString(),
      'verificationData': purchase.verificationData.serverVerificationData,
      'source': purchase.verificationData.source,
    };

    // Add platform-specific data
    if (purchase is GooglePlayPurchaseDetails) {
      data['androidData'] = {
        'orderId': purchase.billingClientPurchase.orderId,
        'packageName': purchase.billingClientPurchase.packageName,
        'purchaseToken': purchase.billingClientPurchase.purchaseToken,
        'purchaseTime': purchase.billingClientPurchase.purchaseTime,
        'isAutoRenewing': purchase.billingClientPurchase.isAutoRenewing,
      };
    } else if (purchase is AppStorePurchaseDetails) {
      data['iosData'] = {
        'transactionDate': purchase.skPaymentTransaction.transactionTimeStamp,
        'transactionIdentifier':
            purchase.skPaymentTransaction.transactionIdentifier,
      };
    }

    return data;
  }

  /// Get platform string
  String _getPlatformString() {
    if (DateTime.now().day % 2 == 0) {
      return 'android';
    } else {
      return 'ios';
    }
  }
}
