import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aichatbot/blocs/auth/auth_event.dart';
import 'package:aichatbot/blocs/auth/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  // Mock accounts for testing
  final Map<String, String> _mockAccounts = {
    'user@example.com': 'password123',
    'demo@aichat.com': 'demo1234',
    'test@test.com': 'test1234',
    'tushari23@gmail.com': '123456',
  };

  String _email = '';
  String _password = '';

  AuthBloc() : super(const AuthState()) {
    on<EmailChanged>(_onEmailChanged);
    on<PasswordChanged>(_onPasswordChanged);
    on<LoginSubmitted>(_onLoginSubmitted);
    on<SignUpRequested>(_onSignUpRequested);
    on<ForgotPasswordRequested>(_onForgotPasswordRequested);
    on<SocialLoginRequested>(_onSocialLoginRequested);
    on<RegisterSubmitted>(_onRegisterSubmitted);
  }

  void _onEmailChanged(EmailChanged event, Emitter<AuthState> emit) {
    _email = event.email;
  }

  void _onPasswordChanged(PasswordChanged event, Emitter<AuthState> emit) {
    _password = event.password;
  }

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

  void _onSignUpRequested(SignUpRequested event, Emitter<AuthState> emit) {
    // In a real app, you would navigate to sign up screen
    // For now, just reset the state
    emit(state.copyWith(status: AuthStatus.initial));
  }

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
