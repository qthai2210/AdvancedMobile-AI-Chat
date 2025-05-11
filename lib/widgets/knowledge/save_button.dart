import 'package:flutter/material.dart';

class SaveButton extends StatelessWidget {
  final bool isLoading;
  final bool canSave;
  final VoidCallback? onPressed;
  const SaveButton({
    Key? key,
    required this.isLoading,
    required this.canSave,
    required this.onPressed,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: canSave && !isLoading ? onPressed : null,
      child: isLoading
        ? const SizedBox(
            width: 16, height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : const Text('Add Data Source'),
    );
  }
}
