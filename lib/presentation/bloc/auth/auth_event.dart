import 'package:flutter/material.dart';

abstract class AuthEvent {}

class EmailChanged extends AuthEvent {
  final String email;
  EmailChanged(this.email);
}

class PasswordChanged extends AuthEvent {
  final String password;
  PasswordChanged(this.password);
}

class LoginSubmitted extends AuthEvent {
  final String email;
  final String password;

  LoginSubmitted({
    required this.email,
    required this.password,
  });
}

class ForgotPasswordRequested extends AuthEvent {}

class SignUpRequested extends AuthEvent {}

class SocialLoginRequested extends AuthEvent {
  final String provider;
  SocialLoginRequested(this.provider);
}

class RegisterSubmitted extends AuthEvent {
  final String name;
  final String email;
  final String password;

  RegisterSubmitted({
    required this.name,
    required this.email,
    required this.password,
  });
}

class LogoutRequested extends AuthEvent {
  final BuildContext? context;

  LogoutRequested({this.context});
}
