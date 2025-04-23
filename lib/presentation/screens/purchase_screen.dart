import 'dart:async';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:aichatbot/core/services/in_app_purchase_service.dart';
import 'package:aichatbot/core/di/injection_container.dart';

class PurchaseScreen extends StatefulWidget {
  const PurchaseScreen({Key? key}) : super(key: key);

  @override
  _PurchaseScreenState createState() => _PurchaseScreenState();
}

class _PurchaseScreenState extends State<PurchaseScreen> {
  final _iapService = sl<InAppPurchaseService>();
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  bool _available = false;
  List<ProductDetails> _products = [];

  @override
  void initState() {
    super.initState();
    _initIAP();
  }

  Future<void> _initIAP() async {
    _available = await _iapService.isAvailable();
    if (!_available) {
      setState(() {});
      return;
    }
    // Query product details
    const ids = <String>{'your_product_id'};
    _products = await _iapService.queryProducts(ids);
    // Subscribe to purchase updates (list of PurchaseDetails)
    _subscription = _iapService.purchaseStream.listen(
      (purchases) {
        for (var purchase in purchases) {
          _onPurchaseUpdate(purchase);
        }
      },
      onError: (error) {
        // Handle error here
      },
    );
    setState(() {});
  }

  void _onPurchaseUpdate(PurchaseDetails purchase) {
    switch (purchase.status) {
      case PurchaseStatus.pending:
        // show pending UI
        break;
      case PurchaseStatus.purchased:
        // deliver product
        break;
      case PurchaseStatus.error:
        // handle error
        break;
      default:
        break;
    }
    // Complete purchase if necessary
    if (purchase.pendingCompletePurchase) {
      InAppPurchase.instance.completePurchase(purchase);
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('In-App Purchase')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!_available) const Text('IAP not available.'),
            for (var product in _products)
              ElevatedButton(
                onPressed: () => _iapService.buyConsumable(product),
                child: Text('Buy ${product.title}'),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _iapService.restorePurchases,
              child: const Text('Restore Purchases'),
            ),
          ],
        ),
      ),
    );
  }
}
