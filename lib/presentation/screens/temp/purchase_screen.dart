import 'package:flutter/material.dart';
import 'package:aichatbot/core/di/injection_container.dart';
import 'package:aichatbot/core/services/in_app_purchase_service.dart';
import 'package:aichatbot/utils/logger.dart';

class PurchaseScreen extends StatefulWidget {
  const PurchaseScreen({Key? key}) : super(key: key);

  @override
  State<PurchaseScreen> createState() => _PurchaseScreenState();
}

class _PurchaseScreenState extends State<PurchaseScreen> {
  final InAppPurchaseService _iapService = sl<InAppPurchaseService>();
  bool _isInitialized = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeIAP();
  }

  Future<void> _initializeIAP() async {
    try {
      setState(() {
        _isLoading = true;
      });

      await _iapService.initialize();

      setState(() {
        // _isInitialized = await _iapService.isAvailable();
        _isLoading = false;
      });

      if (_isInitialized) {
        await _iapService.loadProducts();
      }
    } catch (e) {
      AppLogger.e('Error initializing IAP: $e');
      setState(() {
        _isLoading = false;
        _isInitialized = false;
      });
    }
  }

  Future<void> _restorePurchases() async {
    if (!_isInitialized) return;

    try {
      setState(() {
        _isLoading = true;
      });

      await _iapService.restorePurchases();

      setState(() {
        _isLoading = false;
      });

      _showMessage('Restore completed!');
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showMessage('Error restoring purchases: $e');
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

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
            icon: const Icon(Icons.restore),
            onPressed: _restorePurchases,
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

    if (!_isInitialized) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'In-app purchases are not available on this device.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _initializeIAP,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Center(
            child: Text(
              'Upgrade to Premium',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Center(
            child: Text(
              'Unlock all features and get unlimited AI responses',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Monthly subscription card
          _buildSubscriptionCard(
            title: 'Monthly Premium',
            price: '\$9.99/month',
            description: 'Full access to all features with monthly billing',
            onSubscribe: () => _showMessage(
                'Monthly subscription selected - feature coming soon!'),
          ),

          const SizedBox(height: 16),

          // Yearly subscription card
          _buildSubscriptionCard(
            title: 'Yearly Premium',
            price: '\$79.99/year',
            description:
                'Full access to all features. Save 33% compared to monthly billing!',
            isBestValue: true,
            onSubscribe: () => _showMessage(
                'Yearly subscription selected - feature coming soon!'),
          ),

          const SizedBox(height: 32),

          const Divider(),

          const SizedBox(height: 32),

          // Credits section
          const Center(
            child: Text(
              'Purchase AI Credits',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Credits packages
          _buildCreditPackCard(
            title: '50 Credits',
            price: '\$4.99',
            onPurchase: () =>
                _showMessage('50 credits selected - feature coming soon!'),
          ),

          const SizedBox(height: 12),

          _buildCreditPackCard(
            title: '100 Credits',
            price: '\$8.99',
            isBestValue: true,
            onPurchase: () =>
                _showMessage('100 credits selected - feature coming soon!'),
          ),

          const SizedBox(height: 12),

          _buildCreditPackCard(
            title: '200 Credits',
            price: '\$15.99',
            onPurchase: () =>
                _showMessage('200 credits selected - feature coming soon!'),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionCard({
    required String title,
    required String price,
    required String description,
    required VoidCallback onSubscribe,
    bool isBestValue = false,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isBestValue
            ? BorderSide(color: Theme.of(context).primaryColor, width: 2)
            : BorderSide.none,
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isBestValue)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'BEST VALUE',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  price,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              description,
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
                onPressed: onSubscribe,
                child: const Text('Subscribe'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreditPackCard({
    required String title,
    required String price,
    required VoidCallback onPurchase,
    bool isBestValue = false,
  }) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isBestValue
            ? BorderSide(color: Theme.of(context).primaryColor, width: 1)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (isBestValue)
                    Text(
                      'Best value',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ),
            Text(
              price,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
              ),
              onPressed: onPurchase,
              child: const Text('Buy'),
            ),
          ],
        ),
      ),
    );
  }
}
