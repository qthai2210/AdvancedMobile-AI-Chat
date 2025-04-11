import 'package:shared_preferences/shared_preferences.dart';

/// A utility class for storing and retrieving authentication tokens
/// using SharedPreferences.
class SecureStorageUtil {
  static const String _accessTokenKey = 'ACCESS_TOKEN';
  static const String _refreshTokenKey = 'REFRESH_TOKEN';

  late SharedPreferences _prefs;
  bool _initialized = false;

  /// Singleton instance
  static final SecureStorageUtil _instance = SecureStorageUtil._internal();

  /// Factory constructor to return the singleton instance
  factory SecureStorageUtil() => _instance;

  /// Private constructor for singleton pattern
  SecureStorageUtil._internal();

  /// Initialize SharedPreferences instance
  Future<void> _initPrefs() async {
    if (!_initialized) {
      _prefs = await SharedPreferences.getInstance();
      _initialized = true;
    }
  }

  /// Writes authentication tokens to storage
  ///
  /// [accessToken] The access token for API authorization
  /// [refreshToken] The refresh token used to obtain new access tokens
  Future<void> writeSecureData({
    required String? accessToken,
    String? refreshToken,
  }) async {
    await _initPrefs();

    if (accessToken != null) {
      await _prefs.setString(_accessTokenKey, accessToken);
    }

    if (refreshToken != null) {
      await _prefs.setString(_refreshTokenKey, refreshToken);
    }
  }

  /// Retrieves the access token from storage
  ///
  /// Returns null if the token doesn't exist
  Future<String?> getAccessToken() async {
    await _initPrefs();
    return _prefs.getString(_accessTokenKey);
  }

  /// Retrieves the refresh token from storage
  ///
  /// Returns null if the token doesn't exist
  Future<String?> getRefreshToken() async {
    await _initPrefs();
    return _prefs.getString(_refreshTokenKey);
  }

  /// Deletes all stored authentication tokens
  Future<void> deleteTokens() async {
    await _initPrefs();
    await _prefs.remove(_accessTokenKey);
    await _prefs.remove(_refreshTokenKey);
  }

  /// Deletes all data from storage
  Future<void> deleteAll() async {
    await _initPrefs();
    await _prefs.clear();
  }

  /// Checks if the user is authenticated by verifying if an access token exists
  Future<bool> isAuthenticated() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }
}
