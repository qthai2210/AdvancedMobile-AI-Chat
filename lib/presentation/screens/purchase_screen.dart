import 'dart:async';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:aichatbot/core/services/in_app_purchase_service.dart';
import 'package:aichatbot/core/di/injection_container.dart';
import 'package:aichatbot/utils/logger.dart';

class PurchaseScreen extends StatefulWidget {
  const PurchaseScreen({Key? key}) : super(key: key);

  @override
  State<PurchaseScreen> createState() => _PurchaseScreenState();
}

class _PurchaseScreenState extends State<PurchaseScreen> {
  final _iapService = sl<InAppPurchaseService>();
  late StreamSubscription<List<PurchaseDetails>> _subscription;

  bool _isLoading = true;
  bool _purchasePending = false;
  List<ProductDetails> _subscriptions = [];
  List<ProductDetails> _consumables = [];

  @override
  void initState() {
    super.initState();
    _initProducts();
    _setupPurchaseListener();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  Future<void> _initProducts() async {
    setState(() {
      _isLoading = true;
    });

    // Initialize the IAP service
    await _iapService.initialize();

    if (!_iapService.isAvailable) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    // Load products
    await _iapService.loadProducts();

    // Update UI
    setState(() {
      _subscriptions = _iapService.subscriptions;
      _consumables = _iapService.consumables;
      _isLoading = false;
    });
  }

  void _setupPurchaseListener() {
    _subscription = _iapService.purchaseStream.listen(
      (purchaseDetailsList) {
        for (var purchaseDetails in purchaseDetailsList) {
          _handlePurchaseUpdate(purchaseDetails);
        }
      },
      onDone: () {
        _subscription.cancel();
      },
      onError: (error) {
        AppLogger.e('Error in purchase stream: $error');
        _showMessage('Purchase error: $error');
      },
    );
  }

  void _handlePurchaseUpdate(PurchaseDetails purchaseDetails) {
    setState(() {
      _purchasePending = purchaseDetails.status == PurchaseStatus.pending;
    });

    switch (purchaseDetails.status) {
      case PurchaseStatus.pending:
        _showMessage('Purchase pending...');
        break;
      case PurchaseStatus.purchased:
      case PurchaseStatus.restored:
        _showMessage('Thank you for your purchase!');
        break;
      case PurchaseStatus.error:
        _showMessage(
            'Error: ${purchaseDetails.error?.message ?? 'Unknown error'}');
        AppLogger.e('Purchase error: ${purchaseDetails.error}');
        break;
      case PurchaseStatus.canceled:
        _showMessage('Purchase cancelled');
        break;
    }
  }

  Future<void> _refreshProducts() async {
    await _initProducts();
  }

  Future<void> _purchaseSubscription(ProductDetails product) async {
    setState(() {
      _purchasePending = true;
    });

    try {
      final result = await _iapService.buySubscription(product);
      if (!result) {
        setState(() {
          _purchasePending = false;
        });
        _showMessage('Failed to purchase subscription');
      }
    } catch (e) {
      setState(() {
        _purchasePending = false;
      });
      _showMessage('Error: $e');
      AppLogger.e('Purchase error: $e');
    }
  }

  Future<void> _purchaseConsumable(ProductDetails product) async {
    setState(() {
      _purchasePending = true;
    });

    try {
      final result = await _iapService.buyConsumable(product);
      if (!result) {
        setState(() {
          _purchasePending = false;
        });
        _showMessage('Failed to purchase credits');
      }
    } catch (e) {
      setState(() {
        _purchasePending = false;
      });
      _showMessage('Error: $e');
      AppLogger.e('Purchase error: $e');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Premium Features'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshProducts,
            tooltip: 'Refresh products',
          ),
          IconButton(
            icon: const Icon(Icons.restore),
            onPressed: _iapService.restorePurchases,
            tooltip: 'Restore purchases',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (!_iapService.isAvailable) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'In-app purchases are not available on this device.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Subscriptions
          const Text(
            'Premium Subscription',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Unlock unlimited AI responses and premium features',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          _buildSubscriptionsList(),

          const SizedBox(height: 32),

          // Credits
          const Text(
            'AI Credits',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Purchase additional AI credits',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          _buildConsumablesList(),
        ],
      ),
    );
  }

  Widget _buildSubscriptionsList() {
    if (_subscriptions.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('No subscription products available.'),
        ),
      );
    }

    return Column(
      children: _subscriptions
          .map((product) => _buildProductCard(
                product,
                () => _purchaseSubscription(product),
                isSubscription: true,
              ))
          .toList(),
    );
  }

  Widget _buildConsumablesList() {
    if (_consumables.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('No consumable products available.'),
        ),
      );
    }

    return Column(
      children: _consumables
          .map((product) => _buildProductCard(
                product,
                () => _purchaseConsumable(product),
                isSubscription: false,
              ))
          .toList(),
    );
  }

  Widget _buildProductCard(
    ProductDetails product,
    VoidCallback onPurchase, {
    required bool isSubscription,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  product.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  product.price,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              product.description,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
                onPressed: _purchasePending ? null : onPurchase,
                child: _purchasePending
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(isSubscription ? 'Subscribe' : 'Purchase'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
