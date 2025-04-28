import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Handles navigation from drawer tabs
void handleDrawerNavigation(BuildContext context, int index,
    {required int currentIndex}) {
  // Đóng drawer trước khi điều hướng
  context.pop();

  // Nếu đang ở màn hình hiện tại, không làm gì cả
  if (index == currentIndex) {
    return;
  }

  // Điều hướng dựa trên index
  switch (index) {
    case 0:
      context.go('/chat/detail/new');
      break;
    case 1:
      context.go('/email');
      break;
    case 2:
      context.go('/profile');
      break;
    case 3:
      context.go('/prompts');
      break;
    case 4:
      context.go('/bot_management');
      break;
    case 5:
      context.go('/knowledge_management');
      break;
    case 6:
      // Help & Support - chưa có route
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Help & Support coming soon')),
      );
      break;
    case 7:
      // Settings - chưa có route
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings screen coming soon')),
      );
      break;
  }
}
