import 'dart:async';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:aichatbot/core/services/in_app_purchase_service.dart';
import 'package:aichatbot/core/di/injection_container.dart';
import 'package:aichatbot/utils/logger.dart';
import 'package:go_router/go_router.dart';

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
        _showPurchaseSuccessDialog(purchaseDetails);
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

  void _showPurchaseSuccessDialog(PurchaseDetails purchaseDetails) {
    final bool isSubscription =
        _subscriptions.any((p) => p.id == purchaseDetails.productID);

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_outline_rounded,
                    color: Colors.green,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Purchase Successful!',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  isSubscription
                      ? 'Thank you for your purchase. Your premium subscription is now active.'
                      : 'Thank you for your purchase. Your credits have been added to your account.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Continue',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
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
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(12.0),
        action: SnackBarAction(
          label: 'OK',
          textColor: Theme.of(context).primaryColor,
          onPressed: () {},
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            _buildAppBar(context),
            SliverToBoxAdapter(
              child: _buildBody(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 200.0,
      floating: false,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColor.withOpacity(0.7),
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -20,
                bottom: -20,
                child: Opacity(
                  opacity: 0.2,
                  child: Icon(
                    Icons.star,
                    size: 150,
                    color: Colors.white,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Text(
                      'Upgrade Your Experience',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Unlock premium features and get more from your AI assistant',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () {
          try {
            // First try to use the standard Navigator pop
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              // If we can't pop (we're at the root), use GoRouter to navigate safely to home
              context.go('/home');
            }
          } catch (e) {
            // In case of any navigation errors, fallback to home
            AppLogger.e('Navigation error: $e');
            context.go('/home');
          }
        },
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          onPressed: _refreshProducts,
          tooltip: 'Refresh products',
        ),
        TextButton.icon(
          onPressed: _iapService.restorePurchases,
          icon: const Icon(Icons.restore, size: 16, color: Colors.white),
          label: const Text(
            'Restore',
            style: TextStyle(color: Colors.white),
          ),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (!_iapService.isAvailable) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 80,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 24),
              const Text(
                'In-app purchases unavailable',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'In-app purchases are not available on this device. Please try again on a different device.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _refreshProducts,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // List of premium features
    final List<Map<String, dynamic>> features = [
      {
        'icon': Icons.chat_bubble_outline_rounded,
        'title': 'Unlimited Chats',
        'description': 'Access unlimited AI conversations',
      },
      {
        'icon': Icons.auto_awesome,
        'title': 'Premium AI Models',
        'description': 'Use advanced AI language models',
      },
      {
        'icon': Icons.bolt,
        'title': 'Fast Response',
        'description': 'Get priority server access',
      },
      {
        'icon': Icons.block,
        'title': 'Ad-Free',
        'description': 'Enjoy the app without ads',
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),

          // Premium features showcase
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Premium Features',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ...features
                    .map((feature) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .primaryColor
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  feature['icon'],
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      feature['title'],
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      feature['description'],
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ))
                    .toList(),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Subscriptions section
          const Padding(
            padding: EdgeInsets.only(left: 8.0, bottom: 16.0),
            child: Text(
              'Choose Your Plan',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _buildSubscriptionsList(),

          const SizedBox(height: 24),

          // Credits section
          const Padding(
            padding: EdgeInsets.only(left: 8.0, bottom: 16.0),
            child: Text(
              'Purchase Credits',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _buildConsumablesList(),

          // Legal text
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Text(
              'Subscriptions will automatically renew unless canceled at least 24 hours before the end of the current period. You can manage your subscriptions in your account settings.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionsList() {
    if (_subscriptions.isEmpty) {
      return _buildEmptyState(
        'No subscription plans available',
        'We couldn\'t load subscription plans. Please try again later.',
      );
    }

    return Column(
      children: _subscriptions
          .map((product) => _buildSubscriptionCard(
                product,
                () => _purchaseSubscription(product),
              ))
          .toList(),
    );
  }

  Widget _buildConsumablesList() {
    if (_consumables.isEmpty) {
      return _buildEmptyState(
        'No credit packages available',
        'We couldn\'t load credit packages. Please try again later.',
      );
    }

    return Column(
      children: _consumables
          .map((product) => _buildCreditPackCard(
                product,
                () => _purchaseConsumable(product),
              ))
          .toList(),
    );
  }

  Widget _buildEmptyState(String title, String message) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _refreshProducts,
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionCard(
    ProductDetails product,
    VoidCallback onPurchase,
  ) {
    // Check if this is a monthly or yearly subscription
    final bool isMonthly = product.id.toLowerCase().contains('month');
    final String period = isMonthly ? 'Monthly' : 'Yearly';
    final String perPeriod = isMonthly ? '/month' : '/year';

    // Show a savings badge for yearly plans
    final Widget? savingsBadge = !isMonthly
        ? Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'SAVE 16%',
              style: TextStyle(
                color: Colors.green.shade800,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.star_rounded,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              period,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (savingsBadge != null) ...[
                              const SizedBox(width: 8),
                              savingsBadge,
                            ],
                          ],
                        ),
                        Text(
                          'Premium Subscription',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      product.price,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      perPeriod,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              product.description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                onPressed: _purchasePending ? null : onPurchase,
                child: _purchasePending
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        'Subscribe for ${product.price}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreditPackCard(
    ProductDetails product,
    VoidCallback onPurchase,
  ) {
    // Extract credit amount from product ID
    final RegExp creditRegex = RegExp(r'(\d+)');
    final Match? match = creditRegex.firstMatch(product.id);
    final String credits = match?.group(1) ?? '?';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.token,
                size: 32,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$credits Credits',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Text(
                  product.price,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _purchasePending ? null : onPurchase,
                  style: ElevatedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
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
                      : const Text('Buy Now'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
