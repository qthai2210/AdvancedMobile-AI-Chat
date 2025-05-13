import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aichatbot/core/di/injection_container.dart';
import 'package:aichatbot/presentation/bloc/subscription/subscription_exports.dart';
import 'package:aichatbot/presentation/bloc/user_profile/user_profile_bloc.dart';
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
  late UserProfileBloc _userProfileBloc;

  // User data (initially mock data until API data loads)
  final _userData = {
    'name': 'John Doe',
    'email': 'john.doe@example.com',
    'avatar': 'assets/images/login_head.png',
    'plan': 'Premium',
    'joinDate': 'January 15, 2023',
    'username': '',
    'roles': <String>[],
  };

  @override
  void initState() {
    super.initState();
    _subscriptionBloc = sl<SubscriptionBloc>();
    _userProfileBloc = sl<UserProfileBloc>();
    _fetchSubscriptionData();
    _fetchUserProfileData();
  }

  @override
  void dispose() {
    //_subscriptionBloc.close();
    _userProfileBloc.close();
    super.dispose();
  }

  void _fetchSubscriptionData() {
    _subscriptionBloc.add(const FetchSubscriptionEvent());
  }

  void _fetchUserProfileData() {
    _userProfileBloc.add(const FetchUserProfileEvent());
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => _subscriptionBloc),
          BlocProvider(create: (context) => _userProfileBloc),
        ],
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
                tooltip: 'Refresh Data',
                onPressed: () {
                  // Refresh both subscription and user profile data
                  _subscriptionBloc.add(const RefreshSubscriptionEvent());
                  _userProfileBloc.add(const FetchUserProfileEvent());

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Refreshing profile data...')),
                  );
                },
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
                            // Usage statistics and settings sections removed
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
    return BlocBuilder<UserProfileBloc, UserProfileState>(
      builder: (context, state) {
        String displayName = _userData['name'] as String;
        String email = _userData['email'] as String;

        if (state is UserProfileLoaded) {
          // Use username if available, otherwise use email prefix
          displayName = state.userProfile.username.isNotEmpty
              ? state.userProfile.username
              : state.userProfile.email.split('@').first;
          email = state.userProfile.email;

          // Update userData with the fetched data
          _userData['name'] = displayName;
          _userData['email'] = email;
          _userData['username'] = state.userProfile.username;
          _userData['roles'] = state.userProfile.roles;
        } else if (state is UserProfileLoading) {
          // Optional loading indicator in the header
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: CircularProgressIndicator(),
            ),
          );
        } else if (state is UserProfileError) {
          // Show error toast when profile fails to load
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to load profile: ${state.message}'),
                backgroundColor: Colors.red,
                action: SnackBarAction(
                  label: 'Retry',
                  textColor: Colors.white,
                  onPressed: () => _fetchUserProfileData(),
                ),
              ),
            );
          });
          // Continue with cached/mock data
        }

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
                backgroundImage: AssetImage(_userData['avatar'] as String),
              ),
              const SizedBox(height: 16),
              Text(
                displayName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                email,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),

              // Show user roles if available
              if (((_userData['roles'] as List<String>?) ?? []).isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Wrap(
                    spacing: 8,
                    children: (_userData['roles'] as List<String>)
                        .map((role) => Chip(
                              label: Text(
                                role,
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.white),
                              ),
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .secondary
                                  .withOpacity(0.7),
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ))
                        .toList(),
                  ),
                ),

              const SizedBox(height: 16),
              Chip(
                label: Text(
                  '${_userData['plan']} Plan',
                  style: const TextStyle(color: Colors.white),
                ),
                backgroundColor: Colors.black26,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              ),

              // Show refresh button and error message if profile failed to load
              if (state is UserProfileError)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: TextButton.icon(
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    label: const Text('Refresh Profile',
                        style: TextStyle(color: Colors.white)),
                    onPressed: () => _fetchUserProfileData(),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAccountDetails(SubscriptionState state) {
    bool showUpgradeButton = true;
    bool isLoading = false;
    bool hasError = false;
    String errorMessage = '';

    // Update with subscription data if available
    if (state is SubscriptionLoading) {
      isLoading = true;
    } else if (state is SubscriptionLoaded) {
      // Update the userData plan
      _userData['plan'] = state.subscription.displayName;

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
            _buildDetailRow('Member Since', _userData['joinDate'] as String),
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
              _buildDetailRow('Plan', _userData['plan'] as String),
              const Divider(),
            ],
            _buildDetailRow('Email', _userData['email'] as String),
            const SizedBox(height: 16),
            if (showUpgradeButton)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => context.push('/purchase'),
                  child: const Text('Upgrade Plan'),
                ),
              ),
            const SizedBox(height: 16),
            const Divider(),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: () => context.go('/login'),
                icon: const Icon(Icons.logout, color: Colors.red),
                label:
                    const Text('Logout', style: TextStyle(color: Colors.red)),
                style: TextButton.styleFrom(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  // Usage statistics and settings related methods removed

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
          Flexible(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
  // Settings related methods removed

  void _showEditProfileDialog() {
    final nameController =
        TextEditingController(text: _userData['name'] as String);
    final emailController =
        TextEditingController(text: _userData['email'] as String);

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
                enabled:
                    false, // Email cannot be edited as it comes from the API
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
                // Email is not updated as it should come from the API
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
  // Password related methods removed
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
