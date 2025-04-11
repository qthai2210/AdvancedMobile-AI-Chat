import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:aichatbot/presentation/bloc/auth/auth_bloc.dart';
import 'package:aichatbot/presentation/bloc/auth/auth_event.dart';
import 'package:aichatbot/presentation/bloc/auth/auth_state.dart';
import 'package:aichatbot/widgets/social_login_button.dart';
import 'package:aichatbot/widgets/custom_button.dart';
import 'package:aichatbot/utils/build_context_extensions.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController(text: '2test@gmail.com');
  final _passwordController = TextEditingController(text: '22102003T');
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    // Initialize with existing values
    context.read<AuthBloc>().add(EmailChanged(_emailController.text));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.failure) {
          context.showAuthErrorNotification(
              state.errorMessage ?? 'Đăng nhập thất bại');
        }
        if (state.status == AuthStatus.success) {
          //context.showSuccessNotification('Đăng nhập thành công');

          // Thêm đoạn code này để tự động chuyển trang
          Future.delayed(const Duration(milliseconds: 500), () {
            // Sử dụng Go Router nếu ứng dụng của bạn đang dùng
            try {
              context.go(
                  '/chat'); // hoặc '/prompts' tùy theo cấu trúc route của bạn
            } catch (_) {
              // Fallback cho Navigation 1.0 nếu Go Router không khả dụng
              Navigator.of(context)
                  .pushReplacementNamed('/chat'); // hoặc route khác
            }
          });
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF0F0FF),
        body: SafeArea(
          child: Stack(
            //clipBehavior: Clip.none, // Allow children to overlap outside bounds
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
                          // Add top padding for the image
                          padding: const EdgeInsets.fromLTRB(46, 60, 46, 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              _buildHeader(),
                              _buildLoginForm(),
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

              // Robot avatar image positioned to overlap the white container
              Positioned(
                top: 40, // Adjust this to position the image properly
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const CircleAvatar(
                      radius: 50, // Size of the avatar
                      backgroundColor:
                          Colors.white, // Background color for the avatar
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

  // Header section with title (without the avatar)
  Widget _buildHeader() {
    return const Column(
      children: [
        // Login Title (Avatar is now in the Stack)
        Text(
          'Log in',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text(
          'Welcome back',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
        SizedBox(height: 32),
      ],
    );
  }

  // Login form section with email and password fields
  Widget _buildLoginForm() {
    return Column(
      children: [
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

        // Forgot Password with gradient border
        Align(
          alignment: Alignment.centerRight,
          child: Container(
            margin: const EdgeInsets.only(top: 32, bottom: 32, right: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Color(0xFF315BFF), // Blue
                  Color(0xFFC07BFF), // Light Purple
                  Color(0xFFBD3CFF), // Purple
                  Color(0xFFBA2FFF), // Darker Purple
                ],
                stops: [0.1473, 0.429, 0.7946, 1.0703],
              ),
            ),
            child: Container(
              margin: const EdgeInsets.all(1.2), // Border width
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(11),
              ),
              child: TextButton(
                onPressed: () {
                  context.read<AuthBloc>().add(ForgotPasswordRequested());
                },
                style: TextButton.styleFrom(
                  minimumSize: Size.zero,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Forgot Password',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ),
        ),
        //const SizedBox(height: 16),
      ],
    );
  }

  // Action buttons section
  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // Login Button
          BlocBuilder<AuthBloc, AuthState>(
            buildWhen: (previous, current) => previous.status != current.status,
            builder: (context, state) {
              return CustomButton(
                text: 'Log in',
                isLoading: state.status == AuthStatus.loading,
                onPressed: () {
                  // Kiểm tra các field có dữ liệu không
                  if (_emailController.text.isEmpty ||
                      _passwordController.text.isEmpty) {
                    context.showWarningNotification(
                      'Vui lòng nhập email và mật khẩu',
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

                  // Gửi request đăng nhập
                  context.read<AuthBloc>().add(
                        LoginSubmitted(
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
          const SizedBox(height: 16),
          // Sign Up Button
          CustomButton(
            text: 'Sign UP',
            onPressed: () {
              context.read<AuthBloc>().add(SignUpRequested());
            },
            type: ButtonType.outlined,
            color: const Color(0xFF6A3DE8),
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

  // Terms and registration info section
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

        // Already Registered - navigate to register screen
        GestureDetector(
          onTap: () => context.go('/register'),
          child: const Text(
            'Create a new account',
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
