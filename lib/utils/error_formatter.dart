import 'dart:convert';
import 'package:flutter/material.dart';

class ErrorFormatter {
  static String formatAuthError(dynamic error) {
    debugPrint('Auth error raw: $error');

    // Trường hợp 1: error là Map (response data từ API)
    if (error is Map<String, dynamic>) {
      final code = error['code'];
      final errorMessage = error['error'];
      final details = error['details'];

      debugPrint(
          'Error code: $code, message: $errorMessage, details: $details');

      // Lỗi email không đúng định dạng
      if (code == 'SCHEMA_ERROR') {
        String detailStr = '';

        if (details is Map && details['message'] != null) {
          detailStr = details['message'].toString();
        }

        if (errorMessage != null) {
          detailStr = errorMessage.toString();
        }

        if (detailStr.contains('email')) {
          return 'Email không đúng định dạng, vui lòng kiểm tra lại';
        }

        if (detailStr.contains('password')) {
          return 'Mật khẩu không hợp lệ, vui lòng kiểm tra lại';
        }

        return 'Thông tin không hợp lệ, vui lòng kiểm tra lại';
      }

      // Các lỗi xác thực khác
      if (code == 'EMAIL_PASSWORD_MISMATCH' || code == 'INVALID_CREDENTIALS') {
        return 'Email hoặc mật khẩu không đúng';
      }

      if (code == 'EMAIL_EXISTS' || code == 'USER_EXISTS') {
        return 'Email này đã được đăng ký';
      }

      // Nếu có error message rõ ràng từ API
      if (errorMessage != null) {
        return errorMessage.toString();
      }

      return 'Đã xảy ra lỗi trong quá trình xác thực, vui lòng thử lại';
    }

    // Trường hợp 2: error là String (có thể là JSON string hoặc message)
    if (error is String) {
      try {
        final jsonError = json.decode(error);
        return formatAuthError(jsonError);
      } catch (e) {
        // Không phải JSON string
        debugPrint('Error parsing JSON: $e');
      }

      // Các pattern thông dụng
      if (error.contains('email') &&
          (error.contains('valid') || error.contains('format'))) {
        return 'Email không đúng định dạng, vui lòng kiểm tra lại';
      }

      if (error.contains('password') &&
          (error.contains('match') || error.contains('wrong'))) {
        return 'Email hoặc mật khẩu không đúng';
      }
    }

    // Trường hợp mặc định
    return 'Đã xảy ra lỗi trong quá trình xác thực, vui lòng thử lại';
  }

  static String formatApiError(dynamic error) {
    // Code xử lý lỗi API khác
    return 'Đã xảy ra lỗi, vui lòng thử lại sau';
  }
}
