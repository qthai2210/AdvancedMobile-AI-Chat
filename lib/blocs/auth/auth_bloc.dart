import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aichatbot/blocs/auth/auth_event.dart';
import 'package:aichatbot/blocs/auth/auth_state.dart';
import 'package:aichatbot/services/api_client.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Authentication bloc that handles user authentication states and events.
///
/// This bloc manages the authentication flow including login, registration,
/// and social authentication features.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final ApiClient _apiClient = ApiClient();

  /// Mock user accounts for testing purposes.
  /// Maps email addresses to passwords.
  final Map<String, String> _mockAccounts = {
    'user@example.com': 'password123',
    'demo@aichat.com': 'demo1234',
    'test@test.com': 'test1234',
    'tushari23@gmail.com': '123456',
  };

  /// Currently entered email address
  String _email = '';

  /// Currently entered password
  String _password = '';

  /// Creates a new instance of [AuthBloc].
  ///
  /// Initializes the bloc with default state and registers event handlers.
  AuthBloc() : super(const AuthState()) {
    on<EmailChanged>(_onEmailChanged);
    on<PasswordChanged>(_onPasswordChanged);
    on<LoginSubmitted>(_onLoginSubmitted);
    on<SignUpRequested>(_onSignUpRequested);
    on<ForgotPasswordRequested>(_onForgotPasswordRequested);
    on<SocialLoginRequested>(_onSocialLoginRequested);
    on<RegisterSubmitted>(_onRegisterSubmitted);
    on<LogoutRequested>(_onLogoutRequested); // Add this line
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
  ///
  /// Validates credentials against mock accounts and emits appropriate states.
  /// Includes a simulated network delay for realistic behavior.
  void _onLoginSubmitted(LoginSubmitted event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading));

    try {
      final response = await _apiClient.login(
        email: _email,
        password: _password,
      );

      emit(
        state.copyWith(
          status: AuthStatus.success,
          user: User(
            id: response['user_id'],
            email: _email,
            name: _email.split('@').first,
            directNavigationPath: '/chat/detail/new',
            accessToken: response['access_token'],
            refreshToken: response['refresh_token'],
          ),
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  /// Handles sign-up request events.
  ///
  /// Currently resets the authentication state to initial.
  void _onSignUpRequested(SignUpRequested event, Emitter<AuthState> emit) {
    emit(
      state.copyWith(
        status: AuthStatus.success,
        user: User(
          id: '',
          email: '',
          name: '',
          directNavigationPath:
              '/register', // Add navigation path to register screen
        ),
      ),
    );
  }

  /// Processes forgot password requests.
  ///
  /// Simulates sending a password reset email.
  void _onForgotPasswordRequested(
    ForgotPasswordRequested event,
    Emitter<AuthState> emit,
  ) {
    emit(
      state.copyWith(
        status: AuthStatus.initial,
        errorMessage: 'Password reset email sent to $_email',
      ),
    );
  }

  /// Handles social login requests.
  ///
  /// Simulates successful authentication through social providers.
  void _onSocialLoginRequested(
    SocialLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Simulate successful login for all social providers
    emit(
      state.copyWith(
        status: AuthStatus.success,
        user: User(
          id: '2',
          email: 'social@example.com',
          name: 'Social User',
          directNavigationPath: '/home',
        ),
      ),
    );
  }

  /// Processes new user registration requests.
  ///
  /// Adds the new account to mock accounts and simulates successful registration.
  void _onRegisterSubmitted(
    RegisterSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));

    try {
      final response = await _apiClient.register(
        email: event.email,
        password: event.password,
      );

      emit(
        state.copyWith(
          status: AuthStatus.success,
          user: User(
            id: response['user_id'],
            email: event.email,
            name: event.name,
            directNavigationPath: '/home',
            accessToken: response['access_token'],
            refreshToken: response['refresh_token'],
          ),
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  /// Handles logout request
  void _onLogoutRequested(
      LogoutRequested event, Emitter<AuthState> emit) async {
    if (state.user?.accessToken == null) {
      // If no user is logged in or no access token, just reset state
      print("No user logged in or no access token, resetting state");
      emit(const AuthState(status: AuthStatus.initial));

      // Chuyển hướng đến trang login
      if (event.context != null && event.context!.mounted) {
        event.context!.go('/login');
      }
      return;
    }

    // Set loading state
    print("Emitting loading state for logout");
    emit(state.copyWith(status: AuthStatus.loading));

    try {
      print("Starting logout API call");
      await _apiClient.logout(
        accessToken: state.user!.accessToken!,
        refreshToken: state.user!.refreshToken,
      );
      print("Logout API call successful");

      // Reset auth state after successful logout - create a completely new state
      // Important: Set user to null explicitly
      print("Emitting initial state with null user");
      emit(const AuthState(status: AuthStatus.initial, user: null));
    } catch (error) {
      // Log the error
      print('Logout error: $error');

      // First emit failure state to show error message
      emit(state.copyWith(
        status: AuthStatus.failure,
        errorMessage: 'Logout failed: $error',
      ));

      // Important: Still log the user out locally even if API call fails
      await Future.delayed(const Duration(milliseconds: 300));
      print("Emitting initial state with null user after error");
      emit(const AuthState(status: AuthStatus.initial, user: null));
    }
  }
}
