class ErrorFormatter {
  static String formatApiError(dynamic error) {
    // Xử lý các loại lỗi phổ biến
    if (error is String && error.contains('Failed to get prompts')) {
      return 'Không thể tải prompts, vui lòng thử lại sau';
    }

    if (error is String && error.contains('Unauthorized')) {
      return 'Phiên đăng nhập đã hết hạn, vui lòng đăng nhập lại';
    }

    if (error is String && error.contains('Connection refused') ||
        error is String && error.contains('SocketException')) {
      return 'Không thể kết nối đến máy chủ, vui lòng kiểm tra kết nối mạng';
    }

    if (error is String && error.contains('timed out')) {
      return 'Kết nối quá thời gian, vui lòng thử lại sau';
    }

    // Nếu không có xử lý cụ thể, trả về thông báo chung
    return 'Đã xảy ra lỗi, vui lòng thử lại sau';
  }

  static String formatAuthError(String error) {
    print('Auth error: $error');
    if (error.contains('invalid_grant') ||
        error.contains('invalid_credentials')) {
      return 'Email hoặc mật khẩu không đúng';
    }

    if (error.contains('email_exists')) {
      return 'Email này đã được đăng ký';
    }

    if (error.contains('weak_password')) {
      return 'Mật khẩu quá yếu, vui lòng chọn mật khẩu mạnh hơn';
    }
    if (error.contains(' email must be a valid email')) {
      return 'Email không hợp lệ, vui lòng nhập lại';
    }
    return 'Đã xảy ra lỗi trong quá trình xác thực, vui lòng thử lại';
  }
}
