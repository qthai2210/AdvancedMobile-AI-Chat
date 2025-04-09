import 'package:flutter/material.dart';
import 'package:aichatbot/widgets/app_notification.dart';
import 'package:aichatbot/utils/error_formatter.dart';

extension BuildContextExtensions on BuildContext {
  void showSuccessNotification(
    String message, {
    VoidCallback? onAction,
    String? actionLabel,
    Duration duration = const Duration(seconds: 3),
  }) {
    AppNotification.showSuccess(
      this,
      message,
      onAction: onAction,
      actionLabel: actionLabel,
      duration: duration,
    );
  }

  void showErrorNotification(
    String message, {
    VoidCallback? onAction,
    String? actionLabel,
    Duration duration = const Duration(seconds: 4),
  }) {
    AppNotification.showError(
      this,
      message,
      onAction: onAction,
      actionLabel: actionLabel,
      duration: duration,
    );
  }

  void showWarningNotification(
    String message, {
    VoidCallback? onAction,
    String? actionLabel,
    Duration duration = const Duration(seconds: 4),
  }) {
    AppNotification.showWarning(
      this,
      message,
      onAction: onAction,
      actionLabel: actionLabel,
      duration: duration,
    );
  }

  void showInfoNotification(
    String message, {
    VoidCallback? onAction,
    String? actionLabel,
    Duration duration = const Duration(seconds: 3),
  }) {
    AppNotification.showInfo(
      this,
      message,
      onAction: onAction,
      actionLabel: actionLabel,
      duration: duration,
    );
  }

  void showApiErrorNotification(
    dynamic error, {
    VoidCallback? onAction,
    String? actionLabel,
    Duration duration = const Duration(seconds: 4),
  }) {
    AppNotification.showError(
      this,
      ErrorFormatter.formatApiError(error),
      onAction: onAction,
      actionLabel: actionLabel,
      duration: duration,
    );
  }

  void showAuthErrorNotification(
    String error, {
    VoidCallback? onAction,
    String? actionLabel,
    Duration duration = const Duration(seconds: 4),
  }) {
    AppNotification.showError(
      this,
      ErrorFormatter.formatAuthError(error),
      onAction: onAction,
      actionLabel: actionLabel,
      duration: duration,
    );
  }
}
