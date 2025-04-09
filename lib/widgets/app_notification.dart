import 'package:flutter/material.dart';

enum NotificationType { success, error, warning, info }

class AppNotification extends StatelessWidget {
  final String message;
  final NotificationType type;
  final VoidCallback? onAction;
  final String? actionLabel;
  final Duration duration;
  final IconData? customIcon;
  final bool showIcon;
  final bool isDismissible;

  const AppNotification({
    Key? key,
    required this.message,
    this.type = NotificationType.info,
    this.onAction,
    this.actionLabel,
    this.duration = const Duration(seconds: 3),
    this.customIcon,
    this.showIcon = true,
    this.isDismissible = true,
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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: _borderColor.withOpacity(0.3)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: isDismissible
              ? () => ScaffoldMessenger.of(context).hideCurrentSnackBar()
              : null,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                if (showIcon) ...[
                  Icon(_icon, color: _iconColor),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Text(
                    message,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
                if (onAction != null && actionLabel != null) ...[
                  TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      onAction!();
                    },
                    child: Text(
                      actionLabel!,
                      style: TextStyle(
                        color: _iconColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ] else if (isDismissible) ...[
                  IconButton(
                    icon: const Icon(Icons.close, size: 16),
                    onPressed: () =>
                        ScaffoldMessenger.of(context).hideCurrentSnackBar(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    color: Colors.grey[600],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  static void show(
    BuildContext context,
    String message, {
    NotificationType type = NotificationType.info,
    VoidCallback? onAction,
    String? actionLabel,
    Duration duration = const Duration(seconds: 3),
    IconData? customIcon,
    bool showIcon = true,
    bool isDismissible = true,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: AppNotification(
          message: message,
          type: type,
          onAction: onAction,
          actionLabel: actionLabel,
          customIcon: customIcon,
          showIcon: showIcon,
          isDismissible: isDismissible,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        duration: duration,
        padding: EdgeInsets.zero,
        margin: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
        dismissDirection: DismissDirection.horizontal,
      ),
    );
  }

  static void showSuccess(
    BuildContext context,
    String message, {
    VoidCallback? onAction,
    String? actionLabel,
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      context,
      message,
      type: NotificationType.success,
      onAction: onAction,
      actionLabel: actionLabel,
      duration: duration,
    );
  }

  static void showError(
    BuildContext context,
    String message, {
    VoidCallback? onAction,
    String? actionLabel,
    Duration duration = const Duration(seconds: 4),
  }) {
    show(
      context,
      message,
      type: NotificationType.error,
      onAction: onAction,
      actionLabel: actionLabel,
      duration: duration,
    );
  }

  static void showWarning(
    BuildContext context,
    String message, {
    VoidCallback? onAction,
    String? actionLabel,
    Duration duration = const Duration(seconds: 4),
  }) {
    show(
      context,
      message,
      type: NotificationType.warning,
      onAction: onAction,
      actionLabel: actionLabel,
      duration: duration,
    );
  }

  static void showInfo(
    BuildContext context,
    String message, {
    VoidCallback? onAction,
    String? actionLabel,
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      context,
      message,
      type: NotificationType.info,
      onAction: onAction,
      actionLabel: actionLabel,
      duration: duration,
    );
  }
}
