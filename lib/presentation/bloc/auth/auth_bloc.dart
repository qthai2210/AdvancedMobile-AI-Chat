import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aichatbot/presentation/bloc/auth/auth_event.dart';
import 'package:aichatbot/presentation/bloc/auth/auth_state.dart';
import 'package:aichatbot/domain/usecases/auth/login_usecase.dart';
import 'package:aichatbot/domain/usecases/auth/register_usecase.dart';
import 'package:aichatbot/domain/usecases/auth/logout_usecase.dart';
import 'package:aichatbot/core/errors/failures.dart';
import 'package:aichatbot/utils/secure_storage_util.dart';
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
        email: _email,
        password: _password,
      );

      emit(state.copyWith(
        status: AuthStatus.success,
        user: user,
      ));
      // save access and refresh token to secure storage
      await _secureStorage.writeSecureData(
        accessToken: user.accessToken,
        refreshToken: user.refreshToken,
      );
    } catch (error) {
      debugPrint('Login error in bloc: $error (${error.runtimeType})');

      // Truyền error object nguyên bản không chuyển đổi
      emit(state.copyWith(
        status: AuthStatus.failure,
        errorMessage: error,
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
  void _onRegisterSubmitted(
    RegisterSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));

    try {
      final user = await registerUsecase(
        email: event.email,
        password: event.password,
        name: event.name,
      );

      emit(state.copyWith(
        status: AuthStatus.success,
        user: user,
      ));
    } catch (error) {
      debugPrint('Register error in bloc: $error (${error.runtimeType})');

      // Truyền error object nguyên bản không chuyển đổi
      emit(state.copyWith(
        status: AuthStatus.failure,
        errorMessage: error,
      ));
    }
  }

  /// Handles logout request
  void _onLogoutRequested(
      LogoutRequested event, Emitter<AuthState> emit) async {
    if (state.user?.accessToken == null) {
      // If no user is logged in or no access token, just reset state

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
