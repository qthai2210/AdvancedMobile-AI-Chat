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
                            // Usage statistics section removed
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

  // Usage statistics related methods removed

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
