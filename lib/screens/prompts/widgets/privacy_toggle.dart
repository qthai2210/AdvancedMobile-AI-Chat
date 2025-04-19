import 'package:flutter/material.dart';

class PrivacyToggle extends StatelessWidget {
  final bool isPublic;
  final Function(bool) onToggle;

  const PrivacyToggle({
    Key? key,
    required this.isPublic,
    required this.onToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: SwitchListTile(
        title: const Text('Hiển thị công khai'),
        subtitle:
            const Text('Người dùng khác có thể thấy và sử dụng prompt này'),
        value: isPublic,
        onChanged: onToggle,
        secondary: Icon(
          isPublic ? Icons.public : Icons.lock_outline,
          color: isPublic ? Colors.green : Colors.orange,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
