import 'package:flutter/material.dart';

class InitialStateView extends StatelessWidget {
  const InitialStateView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/search_prompt.png', // Thay thế với hình ảnh thích hợp
            height: 150,
            width: 150,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.help_outline, size: 150, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          const Text(
            'Khám phá kho Prompt',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tìm kiếm hoặc chọn danh mục để bắt đầu',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
