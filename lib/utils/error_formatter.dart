import 'package:aichatbot/core/errors/auth_exception.dart';
import 'package:flutter/material.dart';

class ErrorFormatter {
  static String formatAuthError(dynamic error) {
    // Debug để kiểm tra loại và nội dung của error
    debugPrint('Auth error raw: $error');

    // Trường hợp error là String, trả về nguyên bản
    if (error is String) {
      return error;
    }

    // Nếu error là Map hoặc có thể convert to Map
    Map<String, dynamic> errorMap = {};

    if (error is Map) {
      errorMap = error as Map<String, dynamic>;
    } else if (error is AuthException) {
      return error.message; // Đã được định dạng trong AuthException
    } else if (error is Exception || error is Error) {
      // Chuyển exception thành string để parse
      final errorString = error.toString();
      // Cố gắng trích xuất mã lỗi từ chuỗi lỗi nếu có
      if (errorString.contains('EMAIL_PASSWORD_MISMATCH')) {
        return 'Email hoặc mật khẩu không đúng, vui lòng kiểm tra lại';
      }
      else if (errorString.contains('USER_EMAIL_ALREADY_EXISTS')) {
        return 'Email này đã được sử dụng, vui lòng thử email khác';
      }
      return 'Đã xảy ra lỗi, vui lòng thử lại sau';
    }

    // Lấy error code từ response
    final errorCode = errorMap['code'];

    // Căn cứ vào error code để return message phù hợp
    switch (errorCode) {
      case 'USER_EMAIL_ALREADY_EXISTS':
        return 'Email này đã được sử dụng, vui lòng thử email khác';
      case 'EMAIL_PASSWORD_MISMATCH':
        return 'Email hoặc mật khẩu không đúng, vui lòng kiểm tra lại';
      case 'USER_NOT_FOUND':
        return 'Tài khoản này không tồn tại';
      case 'ACCOUNT_DISABLED':
        return 'Tài khoản của bạn đã bị khóa';
      case 'INVALID_CREDENTIALS':
        return 'Thông tin đăng nhập không hợp lệ';
      case 'TOO_MANY_ATTEMPTS':
        return 'Quá nhiều lần thử, vui lòng thử lại sau';
      case 'NETWORK_ERROR':
        return 'Lỗi kết nối mạng, vui lòng kiểm tra lại';
      default:
        // Nếu có message trong response thì ưu tiên dùng
        if (errorMap.containsKey('error') && errorMap['error'] is String) {
          final errorMessage = errorMap['error'];
          if (errorMessage.contains('Wrong e-mail or password')) {
            return 'Email hoặc mật khẩu không đúng, vui lòng kiểm tra lại';
          }
          return errorMap['error'];
        }
        return 'Đã xảy ra lỗi, vui lòng thử lại sau';
    }
  }

  // Thêm phương thức formatPromptError
  static String formatPromptError(dynamic error) {
    // Debug để kiểm tra loại và nội dung của error
    debugPrint('Prompt error raw: $error');

    // Trường hợp error là String, trả về nguyên bản
    if (error is String) {
      return error;
    }

    // Nếu error là Map hoặc có thể convert to Map
    Map<String, dynamic> errorMap = {};
    if (error is Map) {
      errorMap = error as Map<String, dynamic>;
    } else if (error is Exception) {
      // Xử lý Exception nếu cần
      final errorString = error.toString();

      // Kiểm tra các loại lỗi cụ thể liên quan đến Prompt
      if (errorString.contains('NOT_FOUND')) {
        return 'Prompt không tồn tại hoặc đã bị xóa';
      } else if (errorString.contains('PERMISSION_DENIED')) {
        return 'Bạn không có quyền thực hiện hành động này';
      } else if (errorString.contains('UNAUTHORIZED')) {
        return 'Bạn cần đăng nhập để thực hiện hành động này';
      }

      return 'Đã xảy ra lỗi, vui lòng thử lại sau';
    }

    // Lấy error code từ response
    final errorCode = errorMap['code'];

    // Căn cứ vào error code để return message phù hợp
    switch (errorCode) {
      case 'NOT_FOUND':
        return 'Prompt không tồn tại hoặc đã bị xóa';
      case 'PERMISSION_DENIED':
        return 'Bạn không có quyền thực hiện hành động này';
      case 'UNAUTHORIZED':
        return 'Bạn cần đăng nhập để thực hiện hành động này';
      case 'VALIDATION_ERROR':
        return 'Thông tin prompt không hợp lệ';
      case 'TITLE_ALREADY_EXISTS':
        return 'Đã tồn tại prompt với tiêu đề này';
      default:
        // Nếu có message trong response thì ưu tiên dùng
        if (errorMap.containsKey('error') && errorMap['error'] is String) {
          return errorMap['error'];
        }
        return 'Đã xảy ra lỗi, vui lòng thử lại sau';
    }
  }
}
