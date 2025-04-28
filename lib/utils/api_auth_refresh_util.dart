// File: api_auth_refresh_util.dart
// This utility handles refreshing API data when auth state changes

import 'package:aichatbot/core/di/injection_container.dart' as di;
import 'package:aichatbot/presentation/bloc/auth/auth_bloc.dart';
import 'package:aichatbot/presentation/bloc/auth/auth_state.dart';
import 'package:aichatbot/presentation/bloc/prompt/prompt_bloc.dart';
import 'package:aichatbot/presentation/bloc/prompt/prompt_event.dart';
import 'package:aichatbot/utils/logger.dart';
import 'package:flutter/foundation.dart';

class ApiAuthRefreshUtil {
  static final ApiAuthRefreshUtil _instance = ApiAuthRefreshUtil._internal();

  factory ApiAuthRefreshUtil() {
    return _instance;
  }

  ApiAuthRefreshUtil._internal();

  // Track if we've already setup the listener
  bool _isListenerSetup = false;

  // Setup the listener to refresh data when auth state changes
  void setupAuthListener() {
    if (_isListenerSetup) return;

    final authBloc = di.sl<AuthBloc>();

    // Listen for auth state changes
    authBloc.stream.listen((state) {
      AppLogger.i('Auth state changed: ${state.status}');

      // When logged in, refresh prompt data with a delay to ensure
      // all services are registered
      if (state.status == AuthStatus.success && state.user != null) {
        AppLogger.i('User logged in, refreshing API data');

        // Reset prompt data first
        try {
          final promptBloc = di.sl<PromptBloc>();
          promptBloc.add(ResetPromptState());

          // Schedule fetch with delays to ensure dependencies are ready
          Future.delayed(const Duration(milliseconds: 500), () {
            try {
              if (state.user?.accessToken != null) {
                AppLogger.i('Fetching prompt data after login (1st attempt)');
                promptBloc.add(FetchPrompts(
                  accessToken: state.user!.accessToken!,
                  limit: 20,
                  offset: 0,
                  isFavorite: false,
                ));
              }
            } catch (e) {
              AppLogger.e('Error fetching prompts (1st attempt): $e');
            }
          });

          // Second attempt after a longer delay
          Future.delayed(const Duration(seconds: 2), () {
            try {
              if (state.user?.accessToken != null) {
                AppLogger.i('Fetching prompt data after login (2nd attempt)');
                promptBloc.add(FetchPrompts(
                  accessToken: state.user!.accessToken!,
                  limit: 20,
                  offset: 0,
                  isFavorite: false,
                ));
              }
            } catch (e) {
              AppLogger.e('Error fetching prompts (2nd attempt): $e');
            }
          });
        } catch (e) {
          AppLogger.e('Error setting up prompt refresh: $e');
        }
      }
    });

    _isListenerSetup = true;
    AppLogger.i('Auth listener setup complete');
  }
}
