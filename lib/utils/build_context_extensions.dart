import 'package:flutter/material.dart';
import 'package:aichatbot/widgets/app_notification.dart';
import 'package:aichatbot/utils/error_formatter.dart';
import 'package:aichatbot/widgets/error_dialog.dart';
import 'package:aichatbot/widgets/success_dialog.dart';
import 'package:go_router/go_router.dart';

extension BuildContextExtensions on BuildContext {
  void showSuccessNotification(
    String message, {
    VoidCallback? onAction,
    String? actionLabel,
    Duration duration = const Duration(seconds: 3),
  }) async {
    // Kiểm tra xem BuildContext có còn hợp lệ không
    if (!mounted) return; // Đảm bảo context còn hợp lệ

    defaultAction() {
      if (Navigator.canPop(this)) {
        Navigator.of(this).pop();
      }
    }

    // Using the new SuccessDialog instead of SnackBar
    try {
      SuccessDialog.show(
        this,
        title: 'Success',
        message: message,
        buttonText: actionLabel ?? 'OK',
        onButtonPressed: onAction ?? defaultAction,
      );
    } catch (e) {
      // Log lỗi để debug và xử lý tốt hơn
      debugPrint('Error showing success dialog: $e');
      // Sử dụng notification khác không phụ thuộc vào context
      ScaffoldMessenger.of(this).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  void showErrorNotification(
    String message, {
    VoidCallback? onAction,
    String? actionLabel,
    Duration duration = const Duration(seconds: 4),
  }) {
    if (!mounted) return; // Đảm bảo context còn hợp lệ

    defaultAction() {
      if (Navigator.canPop(this)) {
        Navigator.of(this).pop();
      }
    }

    try {
      ErrorDialog.show(
        this,
        title: 'Error',
        message: message,
        buttonText: actionLabel ?? 'OK',
        onButtonPressed: onAction ?? defaultAction,
      );
    } catch (e) {
      debugPrint('Error showing error dialog: $e');
      ScaffoldMessenger.of(this).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
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
      ErrorFormatter.formatAuthError(error),
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

  void showConfirmationDialog({
    required String title,
    required String content,
    required String confirmText,
    required String cancelText,
    required VoidCallback onConfirm,
    VoidCallback? onCancel,
    bool barrierDismissible = true,
  }) {
    showDialog(
      context: this,
      barrierDismissible: barrierDismissible,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () {
              context.pop();
              if (onCancel != null) onCancel();
            },
            child: Text(
              cancelText,
              style: TextStyle(
                color: Colors.grey[700],
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              context.pop();
              onConfirm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }
}
