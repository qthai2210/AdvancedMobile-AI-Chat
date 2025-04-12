import 'dart:convert';
import 'package:flutter/material.dart';

class ErrorFormatter {
  static String formatAuthError(dynamic error) {
    debugPrint('Auth error raw: $error');

    // Trường hợp 1: error là Map (response data từ API hoặc lỗi kết nối)
    if (error is Map<String, dynamic>) {
      final code = error['code'];
      final errorMessage = error['error'];

      // Lỗi email hoặc mật khẩu không đúng
      if (code == 'EMAIL_PASSWORD_MISMATCH') {
        return 'Email hoặc mật khẩu không đúng, vui lòng kiểm tra lại';
      }

      // Lỗi mật khẩu quá ngắn
      if (code == 'PASSWORD_TOO_SHORT') {
        int minLength = 8;
        if (error['details'] is Map && error['details']['min_length'] != null) {
          minLength =
              int.tryParse(error['details']['min_length'].toString()) ?? 8;
        }
        return 'Mật khẩu phải có ít nhất $minLength ký tự';
      }

      // Các lỗi khác
      if (errorMessage != null) {
        return errorMessage.toString();
      }
    }

    // Các xử lý khác giữ nguyên
    // Trường hợp 2: error là String JSON
    if (error is String) {
      try {
        final jsonError = jsonDecode(error);
        if (jsonError is Map<String, dynamic>) {
          return formatAuthError(jsonError);
        }
      } catch (_) {
        // Ignore JSON parse errors
      }

      if (error.contains('timeout') ||
          error.contains('connection') ||
          error.contains('network')) {
        return 'Kết nối không ổn định, vui lòng thử lại sau';
      }
    }

    // Mặc định
    return 'Đã xảy ra lỗi, vui lòng thử lại sau';
  }

  static String formatPromptError(dynamic error) {
    debugPrint('Prompt error raw: $error');

    // Trường hợp error là Map
    if (error is Map<String, dynamic>) {
      final code = error['code'];
      final errorMessage = error['error'];

      // Xử lý các loại lỗi liên quan đến favorite
      if (code == 'FAVORITE_ERROR') {
        return errorMessage?.toString() ??
            'Không thể thực hiện thao tác yêu thích, vui lòng thử lại sau';
      }

      // Xử lý lỗi xác thực
      if (code == 'UNAUTHORIZED') {
        return 'Phiên đăng nhập đã hết hạn, vui lòng đăng nhập lại';
      }

      // Xử lý lỗi mạng
      if (code == 'NETWORK_ERROR') {
        return 'Lỗi kết nối mạng, vui lòng kiểm tra kết nối và thử lại';
      }

      // Nếu có error message cụ thể, hiển thị nó
      if (errorMessage != null) {
        return errorMessage.toString();
      }
    }

    // Mặc định
    return 'Đã xảy ra lỗi, vui lòng thử lại sau';
  }
}
