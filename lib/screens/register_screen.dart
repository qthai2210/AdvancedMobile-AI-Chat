import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:aichatbot/presentation/bloc/auth/auth_bloc.dart';
import 'package:aichatbot/presentation/bloc/auth/auth_event.dart';
import 'package:aichatbot/presentation/bloc/auth/auth_state.dart';
import 'package:aichatbot/widgets/social_login_button.dart';
import 'package:aichatbot/widgets/custom_button.dart';
import 'package:aichatbot/utils/error_formatter.dart';
import 'package:aichatbot/widgets/error_dialog.dart';
import 'package:aichatbot/utils/build_context_extensions.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.failure) {
          debugPrint(
              'Auth failure with message type: ${state.errorMessage.runtimeType}');

          final formattedError =
              ErrorFormatter.formatAuthError(state.errorMessage);
          debugPrint('Formatted error: $formattedError');

          context.showErrorNotification(
            formattedError,
            actionLabel: 'Thử lại',
          );
        } else if (state.status == AuthStatus.success) {
          context.showSuccessNotification('Đăng ký thành công');

          // Tự động chuyển hướng đến trang login sau khi đăng ký thành công
          Future.delayed(const Duration(milliseconds: 500), () {
            try {
              context.go('/login');
            } catch (_) {
              // Fallback cho Navigation 1.0 nếu GoRouter gặp lỗi
              Navigator.of(context).pushReplacementNamed('/login');
            }
          });
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF0F0FF),
        body: SafeArea(
          child: Stack(
            children: [
              // Background column with white container
              Column(
                children: [
                  // Space for the image to overlap
                  const SizedBox(height: 80),
                  // Main content with white background and rounded top borders
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(100),
                          topRight: Radius.circular(100),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                            offset: Offset(0, -2),
                          ),
                        ],
                      ),
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(46, 60, 46, 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              _buildHeader(),
                              _buildRegistrationForm(),
                              _buildActionButtons(),
                              _buildSocialLogin(),
                              _buildTermsAndRegistration(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Avatar image positioned to overlap the white container
              Positioned(
                top: 40,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black,
                          spreadRadius: 2,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      child: Image(
                        image: AssetImage('assets/images/login_head.png'),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Header section
  Widget _buildHeader() {
    return const Column(
      children: [
        Text(
          'Sign Up',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text(
          'Create your account',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
        SizedBox(height: 32),
      ],
    );
  }

  // Registration form fields
  Widget _buildRegistrationForm() {
    return Column(
      children: [
        // Name Field
        TextField(
          controller: _nameController,
          keyboardType: TextInputType.name,
          decoration: const InputDecoration(
            hintText: 'Full Name',
            prefixIcon: Icon(Icons.person_outline),
          ),
          onChanged: (name) {
            // Add handler if needed
          },
        ),
        const SizedBox(height: 16),

        // Email Field
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            hintText: 'Email',
            prefixIcon: Icon(Icons.email_outlined),
          ),
          onChanged: (email) {
            context.read<AuthBloc>().add(EmailChanged(email));
          },
        ),
        const SizedBox(height: 16),

        // Password Field
        TextField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            hintText: 'Password',
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
          ),
          onChanged: (password) {
            context.read<AuthBloc>().add(PasswordChanged(password));
          },
        ),
        const SizedBox(height: 16),

        // Confirm Password Field
        TextField(
          controller: _confirmPasswordController,
          obscureText: _obscureConfirmPassword,
          decoration: InputDecoration(
            hintText: 'Confirm Password',
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirmPassword
                    ? Icons.visibility_off
                    : Icons.visibility,
              ),
              onPressed: () {
                setState(() {
                  _obscureConfirmPassword = !_obscureConfirmPassword;
                });
              },
            ),
          ),
          onChanged: (confirmPassword) {
            // Add confirm password validation
          },
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  // Action buttons section
  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          BlocBuilder<AuthBloc, AuthState>(
            buildWhen: (previous, current) => previous.status != current.status,
            builder: (context, state) {
              return CustomButton(
                text: 'Create Account',
                isLoading: state.status == AuthStatus.loading,
                onPressed: () {
                  // Kiểm tra các field có dữ liệu không
                  if (_nameController.text.isEmpty ||
                      _emailController.text.isEmpty ||
                      _passwordController.text.isEmpty ||
                      _confirmPasswordController.text.isEmpty) {
                    context.showWarningNotification(
                      'Vui lòng điền đầy đủ thông tin',
                    );
                    return;
                  }

                  // Kiểm tra định dạng email
                  final emailRegExp = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                  if (!emailRegExp.hasMatch(_emailController.text)) {
                    context.showWarningNotification(
                      'Email không đúng định dạng, vui lòng kiểm tra lại',
                    );
                    return;
                  }

                  // Kiểm tra password trùng khớp
                  if (_passwordController.text !=
                      _confirmPasswordController.text) {
                    context.showWarningNotification(
                      'Mật khẩu nhập lại không khớp',
                    );
                    return;
                  }

                  // Gửi form đăng ký
                  context.read<AuthBloc>().add(
                        RegisterSubmitted(
                          name: _nameController.text,
                          email: _emailController.text,
                          password: _passwordController.text,
                        ),
                      );
                },
                type: ButtonType.filled,
                gradient: const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Color(0xFF295BFF), // Blue
                    Color(0xFF9B40D1), // Purple
                  ],
                  stops: [0.0, 0.9577],
                  transform: GradientRotation(1.584), // 90.7 degrees in radians
                ),
              );
            },
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // Social login section
  Widget _buildSocialLogin() {
    return Column(
      children: [
        // Or Continue With
        const Row(
          children: [
            Expanded(child: Divider()),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Or Continue With',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: 24),

        // Social Login Buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SocialLoginButton(
              icon: Icons.g_mobiledata,
              onPressed: () {
                context.read<AuthBloc>().add(SocialLoginRequested('google'));
              },
            ),
            const SizedBox(width: 16),
            SocialLoginButton(
              icon: Icons.facebook,
              onPressed: () {
                context.read<AuthBloc>().add(SocialLoginRequested('facebook'));
              },
            ),
            const SizedBox(width: 16),
            SocialLoginButton(
              icon: Icons.camera_alt_outlined,
              onPressed: () {
                context.read<AuthBloc>().add(SocialLoginRequested('instagram'));
              },
            ),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  // Terms and login navigation
  Widget _buildTermsAndRegistration() {
    return Column(
      children: [
        // Terms of Service
        const Text(
          'By Signing Up You Accept The Terms Of Service',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const Text(
          'And Our Privacy Policy',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 16),

        // Already Registered - Login Link
        GestureDetector(
          onTap: () => context.go('/login'),
          child: const Text(
            'Already registered? Log in',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF6A3DE8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
