import 'package:flutter/material.dart';
import 'dart:async';

enum NotificationType { success, error, warning, info }

class AppNotification extends StatelessWidget {
  final String message;
  final String? title;
  final NotificationType type;
  final VoidCallback? onAction;
  final String? actionLabel;
  final IconData? customIcon;
  final bool showIcon;
  const AppNotification({
    Key? key,
    required this.message,
    this.title,
    this.type = NotificationType.info,
    this.onAction,
    this.actionLabel,
    this.customIcon,
    this.showIcon = true,
  }) : super(key: key);

  IconData get _icon {
    if (customIcon != null) return customIcon!;

    switch (type) {
      case NotificationType.success:
        return Icons.check_circle_outline;
      case NotificationType.error:
        return Icons.error_outline;
      case NotificationType.warning:
        return Icons.warning_amber_outlined;
      case NotificationType.info:
        return Icons.info_outline;
    }
  }

  Color get _backgroundColor {
    switch (type) {
      case NotificationType.success:
        return Colors.green.shade50;
      case NotificationType.error:
        return Colors.red.shade50;
      case NotificationType.warning:
        return Colors.amber.shade50;
      case NotificationType.info:
        return Colors.blue.shade50;
    }
  }

  Color get _borderColor {
    switch (type) {
      case NotificationType.success:
        return Colors.green;
      case NotificationType.error:
        return Colors.red;
      case NotificationType.warning:
        return Colors.amber;
      case NotificationType.info:
        return Colors.blue;
    }
  }

  Color get _iconColor {
    switch (type) {
      case NotificationType.success:
        return Colors.green;
      case NotificationType.error:
        return Colors.red;
      case NotificationType.warning:
        return Colors.amber.shade800;
      case NotificationType.info:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get the appropriate title based on notification type if not provided
    final notificationTitle = title ?? _getDefaultTitle();

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 5,
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with icon and title
            Row(
              children: [
                if (showIcon) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _backgroundColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(_icon, color: _iconColor, size: 28),
                  ),
                  const SizedBox(width: 16),
                ],
                Expanded(
                  child: Text(
                    notificationTitle,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Message content
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                message,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[800],
                  height: 1.4,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Action buttons
            Row(
              mainAxisAlignment: onAction != null && actionLabel != null
                  ? MainAxisAlignment.spaceBetween
                  : MainAxisAlignment.end,
              children: [
                if (onAction != null && actionLabel != null)
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      onAction!();
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: _iconColor,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                    ),
                    child: Text(actionLabel!),
                  ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _iconColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                  ),
                  child: const Text('OK'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to get default title based on notification type
  String _getDefaultTitle() {
    switch (type) {
      case NotificationType.success:
        return 'Success';
      case NotificationType.error:
        return 'Error';
      case NotificationType.warning:
        return 'Warning';
      case NotificationType.info:
        return 'Information';
    }
  }

  static Future<void> show(
    BuildContext context,
    String message, {
    String? title,
    NotificationType type = NotificationType.info,
    VoidCallback? onAction,
    String? actionLabel,
    IconData? customIcon,
    bool showIcon = true,
    bool barrierDismissible = true,
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (BuildContext context) {
        return AppNotification(
          message: message,
          title: title,
          type: type,
          onAction: onAction,
          actionLabel: actionLabel,
          customIcon: customIcon,
          showIcon: showIcon,
        );
      },
    );
  }

  static Future<void> showSuccess(
    BuildContext context,
    String message, {
    String? title,
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    return show(
      context,
      message,
      title: title ?? 'Success',
      type: NotificationType.success,
      onAction: onAction,
      actionLabel: actionLabel,
    );
  }

  static Future<void> showError(
    BuildContext context,
    String message, {
    String? title,
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    return show(
      context,
      message,
      title: title ?? 'Error',
      type: NotificationType.error,
      onAction: onAction,
      actionLabel: actionLabel,
    );
  }

  static Future<void> showWarning(
    BuildContext context,
    String message, {
    String? title,
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    return show(
      context,
      message,
      title: title ?? 'Warning',
      type: NotificationType.warning,
      onAction: onAction,
      actionLabel: actionLabel,
    );
  }

  static Future<void> showInfo(
    BuildContext context,
    String message, {
    String? title,
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    return show(
      context,
      message,
      title: title ?? 'Information',
      type: NotificationType.info,
      onAction: onAction,
      actionLabel: actionLabel,
    );
  }
}
