import 'package:aichatbot/data/models/auth/user_profile_model.dart';

/// Interface for the user profile repository
abstract class UserProfileRepository {
  /// Fetches the user profile from the API
  ///
  /// Returns a [UserProfileModel] with user data
  /// Optional [xJarvisGuid] can be provided for tracking
  Future<UserProfileModel> getUserProfile({String? xJarvisGuid});
}
