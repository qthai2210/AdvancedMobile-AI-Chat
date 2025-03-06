import 'package:flutter/material.dart';

class RenameDialogWidget extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onSave;

  const RenameDialogWidget({
    super.key,
    required this.controller,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Đổi tên cuộc trò chuyện'),
      content: TextField(
        controller: controller,
        autofocus: true,
        decoration: const InputDecoration(
          hintText: 'Nhập tên mới',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        TextButton(
          onPressed: () {
            onSave(controller.text);
            Navigator.pop(context);
          },
          child: const Text('Lưu'),
        ),
      ],
    );
  }
}

class DeleteConfirmationDialog extends StatelessWidget {
  final VoidCallback onConfirm;

  const DeleteConfirmationDialog({super.key, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Xác nhận xóa'),
      content: const Text(
        'Bạn có chắc muốn xóa cuộc trò chuyện này? Hành động này không thể hoàn tác.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        TextButton(
          onPressed: onConfirm,
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('Xóa'),
        ),
      ],
    );
  }
}

class ChatOptionsMenu extends StatelessWidget {
  final VoidCallback onRename;
  final VoidCallback onDelete;

  const ChatOptionsMenu({
    super.key,
    required this.onRename,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'rename') {
          onRename();
        } else if (value == 'delete') {
          onDelete();
        }
      },
      itemBuilder: (BuildContext context) => [
        const PopupMenuItem(
          value: 'rename',
          child: Row(
            children: [
              Icon(Icons.edit),
              SizedBox(width: 8),
              Text('Đổi tên'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, color: Colors.red),
              SizedBox(width: 8),
              Text('Xóa', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
    );
  }
}
