import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aichatbot/blocs/auth/auth_event.dart';
import 'package:aichatbot/blocs/auth/auth_state.dart';

/// Authentication bloc that handles user authentication states and events.
///
/// This bloc manages the authentication flow including login, registration,
/// and social authentication features.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
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

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Check if credentials match any mock account
    if (_mockAccounts.containsKey(_email) &&
        _mockAccounts[_email] == _password) {
      emit(
        state.copyWith(
          status: AuthStatus.success,
          user: User(
            id: '1',
            email: _email,
            name: _email.split('@').first,
            // Navigate directly to home screen
            directNavigationPath: '/chat/detail/new',
          ),
        ),
      );
    } else {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          errorMessage: 'Invalid email or password',
        ),
      );
    }
  }

  /// Handles sign-up request events.
  ///
  /// Currently resets the authentication state to initial.
  void _onSignUpRequested(SignUpRequested event, Emitter<AuthState> emit) {
    // In a real app, you would navigate to sign up screen
    // For now, just reset the state
    emit(state.copyWith(status: AuthStatus.initial));
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

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Add the new account to mock accounts
    _mockAccounts[event.email] = event.password;

    // Simulate successful registration
    emit(
      state.copyWith(
        status: AuthStatus.success,
        user: User(
          id: '3',
          email: event.email,
          name: event.name,
          directNavigationPath: '/home',
        ),
      ),
    );
  }
}
