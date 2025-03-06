import 'package:flutter/material.dart';

class ChatInputField extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onSendMessage;

  const ChatInputField({
    super.key,
    required this.controller,
    required this.onSendMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -2),
            blurRadius: 4,
            color: Colors.black.withOpacity(0.1),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.attach_file),
              onPressed: () {
                // Handle file attachment
              },
            ),
            Expanded(
              child: TextField(
                controller: controller,
                decoration: const InputDecoration(
                  hintText: 'Nhập tin nhắn...',
                  border: InputBorder.none,
                ),
                maxLines: null,
                textInputAction: TextInputAction.newline,
                onSubmitted: (value) {
                  if (value.trim().isNotEmpty) {
                    onSendMessage(value);
                    controller.clear();
                  }
                },
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send),
              color: Theme.of(context).primaryColor,
              onPressed: () {
                onSendMessage(controller.text);
                controller.clear();
              },
            ),
          ],
        ),
      ),
    );
  }
}
