import 'package:aichatbot/utils/logger.dart';
import 'package:dio/dio.dart';

/// Custom Dio logger interceptor that uses the app's AppLogger
///
/// This class safely intercepts Dio requests/responses and logs them using
/// the application's custom logger without modifying Dio's internals.
class DioAppLogger extends Interceptor {
  final bool request;
  final bool requestHeader;
  final bool requestBody;
  final bool responseHeader;
  final bool responseBody;
  final bool error;

  /// Creates a new DioAppLogger with configurable logging options
  DioAppLogger({
    this.request = true,
    this.requestHeader = true,
    this.requestBody = false,
    this.responseHeader = true,
    this.responseBody = false,
    this.error = true,
  });

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (request) {
      AppLogger.i('*** Request ***');
      AppLogger.i('URI: ${options.uri}');
      AppLogger.i('Method: ${options.method}');

      if (requestHeader) {
        AppLogger.i('Headers:');
        options.headers.forEach((key, value) {
          AppLogger.i('  $key: $value');
        });
      }

      if (requestBody) {
        AppLogger.i('Body:');
        AppLogger.i(options.data.toString());
      }
    }

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (responseBody || responseHeader) {
      AppLogger.i('*** Response ***');
      AppLogger.i('URI: ${response.requestOptions.uri}');
      AppLogger.i('Status Code: ${response.statusCode}');

      if (responseHeader) {
        AppLogger.i('Headers:');
        response.headers.forEach((name, values) {
          AppLogger.i('  $name: ${values.join(', ')}');
        });
      }

      if (responseBody) {
        AppLogger.i('Response Body:');
        AppLogger.i(response.data.toString());
      }
    }

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (error) {
      AppLogger.e('*** DioException ***');
      AppLogger.e('URI: ${err.requestOptions.uri}');
      AppLogger.e('Status Code: ${err.response?.statusCode}');
      AppLogger.e('Error Type: ${err.type}');
      AppLogger.e('Error Message: ${err.message}');

      if (err.response != null) {
        AppLogger.e('Error Response: ${err.response?.data}');
      }
    }

    handler.next(err);
  }
}
