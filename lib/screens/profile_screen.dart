import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aichatbot/core/di/injection_container.dart';
import 'package:aichatbot/presentation/bloc/subscription/subscription_exports.dart';
import 'package:aichatbot/widgets/main_app_drawer.dart';
import 'package:aichatbot/utils/navigation_utils.dart' as navigation_utils;
import 'package:go_router/go_router.dart';
import 'package:aichatbot/presentation/widgets/banner_ad_widget.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = false;
  late SubscriptionBloc _subscriptionBloc;

  // Mock user data
  final _userData = {
    'name': 'John Doe',
    'email': 'john.doe@example.com',
    'avatar': 'assets/images/login_head.png',
    'plan': 'Premium',
    'joinDate': 'January 15, 2023',
  };

  // Mock usage statistics
  final _usageStats = {
    'chatsSent': 1245,
    'promptsCreated': 37,
    'botsCreated': 5,
    'tokensUsed': 246578,
    'tokensRemaining': 753422,
  };

  @override
  void initState() {
    super.initState();
    _subscriptionBloc = sl<SubscriptionBloc>();
    _fetchSubscriptionData();
  }

  @override
  void dispose() {
    //_subscriptionBloc.close();
    super.dispose();
  }

  void _fetchSubscriptionData() {
    _subscriptionBloc.add(const FetchSubscriptionEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => _subscriptionBloc,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Profile'),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                tooltip: 'Edit Profile',
                onPressed: _showEditProfileDialog,
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh Subscription',
                onPressed: () =>
                    _subscriptionBloc.add(const RefreshSubscriptionEvent()),
              ),
            ],
          ),
          drawer: MainAppDrawer(
            currentIndex: 2, // Index 2 corresponds to the Profile tab
            onTabSelected: (index) => navigation_utils
                .handleDrawerNavigation(context, index, currentIndex: 2),
          ),
          body: Column(
            children: [
              // Main content
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        child: Column(
                          children: [
                            _buildProfileHeader(),
                            BlocBuilder<SubscriptionBloc, SubscriptionState>(
                              builder: (context, state) {
                                return _buildAccountDetails(state);
                              },
                            ),
                            BlocBuilder<SubscriptionBloc, SubscriptionState>(
                              builder: (context, state) {
                                return _buildUsageStatistics(state);
                              },
                            ),
                            _buildSettingsSection(),
                          ],
                        ),
                      ),
              ),
              // Banner ad at the bottom
              const SizedBox(
                height: 60,
                width: double.infinity,
                child: BannerAdWidget(),
              ),
            ],
          ),
        ));
  }

  Widget _buildProfileHeader() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.92,
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: AssetImage(_userData['avatar']!),
          ),
          const SizedBox(height: 16),
          Text(
            _userData['name']!,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _userData['email']!,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 16),
          Chip(
            label: Text(
              '${_userData['plan']} Plan',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.black26,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountDetails(SubscriptionState state) {
    String planName = _userData['plan']!;
    bool showUpgradeButton = true;
    bool isLoading = false;
    bool hasError = false;
    String errorMessage = '';

    // Update with subscription data if available
    if (state is SubscriptionLoading) {
      isLoading = true;
    } else if (state is SubscriptionLoaded) {
      planName = state.subscription.displayName;
      // Hide upgrade button for premium plans
      showUpgradeButton = state.subscription.name.toLowerCase() == 'basic';
    } else if (state is SubscriptionError) {
      hasError = true;
      errorMessage = state.message;
    }

    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Account Details'),
            const SizedBox(height: 16),
            _buildDetailRow('Member Since', _userData['joinDate']!),
            const Divider(),
            if (isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (hasError)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Failed to load subscription: $errorMessage',
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              )
            else ...[
              _buildDetailRow('Plan', planName),
              const Divider(),
            ],
            _buildDetailRow('Email', _userData['email']!),
            const SizedBox(height: 16),
            if (showUpgradeButton)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => context.push('/purchase'),
                  child: const Text('Upgrade Plan'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsageStatistics(SubscriptionState state) {
    bool showSubscriptionTokens = false;
    int dailyTokens = 0;
    int monthlyTokens = 0;
    int annuallyTokens = 0;

    // Update with subscription data if available
    if (state is SubscriptionLoaded) {
      showSubscriptionTokens = true;
      dailyTokens = state.subscription.dailyTokens;
      monthlyTokens = state.subscription.monthlyTokens;
      annuallyTokens = state.subscription.annuallyTokens;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Usage Statistics'),
            const SizedBox(height: 16),
            _buildStatsGrid(),
            const SizedBox(height: 16),
            _buildTokenUsageBar(),
            if (showSubscriptionTokens) ...[
              const SizedBox(height: 20),
              _buildSubscriptionTokensSection(
                  dailyTokens, monthlyTokens, annuallyTokens),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionTokensSection(
      int dailyTokens, int monthlyTokens, int annuallyTokens) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Subscription Tokens',
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildTokenAllocationRow('Daily Tokens', dailyTokens),
              const SizedBox(height: 8),
              if (monthlyTokens > 0) ...[
                _buildTokenAllocationRow('Monthly Tokens', monthlyTokens),
                const SizedBox(height: 8),
              ],
              if (annuallyTokens > 0) ...[
                _buildTokenAllocationRow('Annual Tokens', annuallyTokens),
                const SizedBox(height: 8),
              ],
              const Divider(),
              _buildTokenAllocationRow(
                'Total Tokens',
                dailyTokens + monthlyTokens + annuallyTokens,
                isTotal: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTokenAllocationRow(String label, int value,
      {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            fontSize: isTotal ? 16 : 14,
          ),
        ),
        Text(
          value.toString(),
          style: TextStyle(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            fontSize: isTotal ? 16 : 14,
            color: isTotal ? Theme.of(context).primaryColor : null,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: [
        _buildStatCard(
            'Chats', _usageStats['chatsSent'].toString(), Icons.chat),
        _buildStatCard('Prompts', _usageStats['promptsCreated'].toString(),
            Icons.psychology),
        _buildStatCard(
            'Bots', _usageStats['botsCreated'].toString(), Icons.smart_toy),
        _buildStatCard(
            'Tokens Used', _usageStats['tokensUsed'].toString(), Icons.token),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Theme.of(context).primaryColor),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTokenUsageBar() {
    final tokensUsed = _usageStats['tokensUsed'] as int;
    final tokensRemaining = _usageStats['tokensRemaining'] as int;
    final totalTokens = tokensUsed + tokensRemaining;
    final usedPercentage = tokensUsed / totalTokens;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Token Usage',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            Text(
              '${(usedPercentage * 100).toStringAsFixed(1)}%',
              style: TextStyle(
                color: usedPercentage > 0.8 ? Colors.red : Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRounded(
          child: LinearProgressIndicator(
            value: usedPercentage,
            backgroundColor: Colors.grey.shade300,
            minHeight: 10,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${tokensUsed.toString()} used',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            Text(
              '${tokensRemaining.toString()} remaining',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSettingsSection() {
    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Settings'),
            const SizedBox(height: 16),
            _buildSettingTile(
              'Change Password',
              'Update your password',
              Icons.lock_outline,
              () => _showChangePasswordDialog(),
            ),
            _buildSettingTile(
              'Notification Preferences',
              'Manage notification settings',
              Icons.notifications_none,
              () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Notification settings coming soon')),
                );
              },
            ),
            _buildSettingTile(
              'Privacy Settings',
              'Control your data and privacy',
              Icons.privacy_tip_outlined,
              () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Privacy settings coming soon')),
                );
              },
            ),
            _buildSettingTile(
              'AI Model Preferences',
              'Choose default AI models',
              Icons.psychology_outlined,
              () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('AI model settings coming soon')),
                );
              },
            ),
            const Divider(height: 32),
            _buildSettingTile(
              'Logout',
              'Sign out of your account',
              Icons.logout,
              () => context.go('/login'),
              isDestructive: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    final color = isDestructive ? Colors.red : null;

    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          color: color,
          fontWeight: isDestructive ? FontWeight.w500 : null,
        ),
      ),
      subtitle: Text(subtitle),
      leading: Icon(icon, color: color),
      trailing: const Icon(Icons.chevron_right),
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
    );
  }

  void _showEditProfileDialog() {
    final nameController = TextEditingController(text: _userData['name']);
    final emailController = TextEditingController(text: _userData['email']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _userData['name'] = nameController.text;
                _userData['email'] = emailController.text;
              });

              context.pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile updated successfully')),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: currentPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Current Password',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'New Password',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirm New Password',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Password validation logic would go here
              context.pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Password changed successfully')),
              );
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
}

class ClipRounded extends StatelessWidget {
  final Widget child;
  final double radius;

  const ClipRounded({
    Key? key,
    required this.child,
    this.radius = 8,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: child,
    );
  }
}
