import 'package:flutter/material.dart';

/// A custom success dialog for displaying success messages.
///
/// This widget creates a visually distinctive popup for success messages with
/// customizable title, message, and action button.
class SuccessDialog extends StatelessWidget {
  final String title;
  final String message;
  final String buttonText;
  final VoidCallback? onButtonPressed;

  const SuccessDialog({
    Key? key,
    this.title = 'Success',
    required this.message,
    this.buttonText = 'OK',
    this.onButtonPressed,
  }) : super(key: key);

  /// Shows the success dialog.
  ///
  /// This static method makes it easy to display the dialog from anywhere in the app.
  static Future<void> show(
    BuildContext context, {
    String title = 'Success',
    required String message,
    String buttonText = 'OK',
    VoidCallback? onButtonPressed,
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return SuccessDialog(
          title: title,
          message: message,
          buttonText: buttonText,
          onButtonPressed: onButtonPressed ?? () => Navigator.of(context).pop(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.check_circle_outline,
              color: Colors.green,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
      content: Text(
        message,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black87,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16, bottom: 16),
          child: ElevatedButton(
            onPressed: onButtonPressed ?? () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(buttonText),
          ),
        ),
      ],
    );
  }
}
