import 'package:flutter/material.dart';
import 'package:aichatbot/widgets/app_notification.dart';
import 'package:aichatbot/utils/error_formatter.dart';
import 'package:aichatbot/widgets/error_dialog.dart';
import 'package:aichatbot/widgets/success_dialog.dart';

extension BuildContextExtensions on BuildContext {
  void showSuccessNotification(
    String message, {
    VoidCallback? onAction,
    String? actionLabel,
    Duration duration = const Duration(seconds: 3),
  }) {
    // Using the new SuccessDialog instead of SnackBar
    SuccessDialog.show(
      this,
      title: 'Success',
      message: message,
      buttonText: actionLabel ?? 'OK',
      onButtonPressed: onAction ?? () => Navigator.of(this).pop(),
    );
  }

  void showErrorNotification(
    String message, {
    VoidCallback? onAction,
    String? actionLabel,
    Duration duration = const Duration(seconds: 4),
  }) {
    // Using the new ErrorDialog instead of SnackBar
    ErrorDialog.show(
      this,
      title: 'Error',
      message: message,
      buttonText: actionLabel ?? 'OK',
      onButtonPressed: onAction ?? () => Navigator.of(this).pop(),
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
    );
  }
}
