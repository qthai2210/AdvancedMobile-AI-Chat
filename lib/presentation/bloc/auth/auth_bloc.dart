import 'package:aichatbot/core/di/injection_container.dart';
import 'package:aichatbot/core/errors/auth_exception.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aichatbot/presentation/bloc/auth/auth_event.dart';
import 'package:aichatbot/presentation/bloc/auth/auth_state.dart';
import 'package:aichatbot/domain/usecases/auth/login_usecase.dart';
import 'package:aichatbot/domain/usecases/auth/register_usecase.dart';
import 'package:aichatbot/domain/usecases/auth/logout_usecase.dart';
import 'package:aichatbot/core/errors/failures.dart';
import 'package:aichatbot/utils/secure_storage_util.dart';
import 'package:aichatbot/utils/logger.dart';
import 'package:flutter/foundation.dart';

// Ensure that AuthFailure is defined in the 'failures.dart' file or replace it with the correct class name.
import 'package:go_router/go_router.dart';

/// Authentication bloc that handles user authentication states and events.
///
/// This bloc manages the authentication flow including login, registration,
/// and social authentication features.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUsecase loginUsecase;
  final RegisterUsecase registerUsecase;
  final LogoutUsecase logoutUsecase;
  final SecureStorageUtil _secureStorage = SecureStorageUtil();

  /// Currently entered email address
  String _email = '';

  /// Currently entered password
  String _password = '';

  /// Creates a new instance of [AuthBloc].
  ///
  /// Initializes the bloc with default state and registers event handlers.
  AuthBloc({
    required this.loginUsecase,
    required this.registerUsecase,
    required this.logoutUsecase,
  }) : super(const AuthState()) {
    on<EmailChanged>(_onEmailChanged);
    on<PasswordChanged>(_onPasswordChanged);
    on<LoginSubmitted>(_onLoginSubmitted);
    on<SignUpRequested>(_onSignUpRequested);
    on<ForgotPasswordRequested>(_onForgotPasswordRequested);
    on<SocialLoginRequested>(_onSocialLoginRequested);
    on<RegisterSubmitted>(_onRegisterSubmitted);
    on<LogoutRequested>(_onLogoutRequested);
  }

  /// Handles email change events by updating the stored email.
  ///
  /// [event] contains the new email value.
  void _onEmailChanged(EmailChanged event, Emitter<AuthState> emit) {
    _email = event.email;
  }

  /// Handles password change events by updating the stored password.
  ///
  /// [event] contains the new password value.
  void _onPasswordChanged(PasswordChanged event, Emitter<AuthState> emit) {
    _password = event.password;
  }

  /// Processes login submission attempts.
  void _onLoginSubmitted(LoginSubmitted event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading));

    try {
      final user = await loginUsecase(
        email: event.email,
        password: event.password,
      );

      // Initialize all post-login services after successful authentication
      await initPostLoginServices();
      debugPrint('Post-login services initialized after successful login');

      emit(state.copyWith(
        status: AuthStatus.success,
        user: user,
      ));
    } catch (error) {
      debugPrint('Auth bloc login error: $error');

      // Truyền nguyên error object để ErrorFormatter có thể xử lý
      emit(state.copyWith(
        status: AuthStatus.failure,
        errorMessage: error, // Không cần ép kiểu hoặc format ở đây
      ));
    }
  }

  /// Handles sign-up request events.
  void _onSignUpRequested(SignUpRequested event, Emitter<AuthState> emit) {
    emit(state.copyWith(
      status: AuthStatus.initial,
    ));
  }

  /// Processes forgot password requests.
  void _onForgotPasswordRequested(
    ForgotPasswordRequested event,
    Emitter<AuthState> emit,
  ) {
    emit(state.copyWith(
      status: AuthStatus.initial,
      errorMessage: 'Password reset email sent to $_email',
    ));
  }

  /// Handles social login requests.
  void _onSocialLoginRequested(
    SocialLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));

    // Simulate network delay for social login
    await Future.delayed(const Duration(seconds: 1));

    emit(state.copyWith(
      status: AuthStatus.success,
      user: null, // Replace with actual social login implementation
    ));
  }

  /// Processes new user registration requests.
  Future<void> _onRegisterSubmitted(
    RegisterSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));

    try {
      debugPrint('Register request: ${event.email}, ${event.name}');

      await registerUsecase(
        name: event.name,
        email: event.email,
        password: event.password,
      );

      // Emit registrationSuccess thay vì success
      emit(state.copyWith(
        status: AuthStatus.success,
        // Không set user ở đây vì chúng ta muốn người dùng đăng nhập
      ));
    } catch (error) {
      debugPrint('Register error in bloc: $error (${error.runtimeType})');

      String errorMessage = 'Đã xảy ra lỗi, vui lòng thử lại sau';

      // Kiểm tra nếu lỗi là AuthException
      if (error is AuthException) {
        errorMessage = error.message;
      } else {
        // Log lỗi khác
        debugPrint('Unexpected error: $error');
      }
      emit(state.copyWith(
        status: AuthStatus.failure,
        errorMessage: errorMessage,
      ));
    }
  }

  /// Handles logout request
  void _onLogoutRequested(
      LogoutRequested event, Emitter<AuthState> emit) async {
    if (state.user?.accessToken == null) {
      // If no user is logged in or no access token, just reset state

      // Reset post-login services even if there's no token
      // This ensures cleanup in case of app state inconsistency
      await resetPostLoginServices();
      debugPrint('Post-login services reset during logout (no token)');

      emit(const AuthState(status: AuthStatus.initial));

      // Redirect to login page
      if (event.context != null && event.context!.mounted) {
        event.context!.go('/login');
      }
      return;
    }

    // Set loading state
    emit(state.copyWith(status: AuthStatus.loading));

    try {
      // Reset post-login services before logging out
      await resetPostLoginServices();
      debugPrint('Post-login services reset before logout');

      await logoutUsecase(
        accessToken: state.user!.accessToken!,
        refreshToken: state.user!.refreshToken,
      );

      // Reset auth state after successful logout
      emit(const AuthState(status: AuthStatus.initial));

      // Redirect to login page after successful logout
      if (event.context != null && event.context!.mounted) {
        event.context!.go('/login');
      }
    } on Failure catch (failure) {
      // Log the error
      print('Logout error: ${failure.message}');

      emit(state.copyWith(
        status: AuthStatus.failure,
        errorMessage: 'Logout failed: ${failure.message}',
      ));

      // Still log out locally even if API call fails
      await Future.delayed(const Duration(milliseconds: 300));
      emit(const AuthState(status: AuthStatus.initial));

      // Redirect to login page even after failure
      if (event.context != null && event.context!.mounted) {
        event.context!.go('/login');
      }
    } catch (error) {
      // Log the error
      print('Unexpected logout error: $error');

      emit(state.copyWith(
        status: AuthStatus.failure,
        errorMessage: 'Logout failed: $error',
      ));

      // Still log out locally even if there's an unexpected error
      await Future.delayed(const Duration(milliseconds: 300));
      emit(const AuthState(status: AuthStatus.initial));

      // Redirect to login page even after error
      if (event.context != null && event.context!.mounted) {
        event.context!.go('/login');
      }
    }
  }
}
