import 'package:aichatbot/core/errors/failures.dart';
import 'package:aichatbot/data/models/auth/user_profile_model.dart';
import 'package:aichatbot/domain/repositories/user_profile_repository.dart';
import 'package:aichatbot/utils/logger.dart';

/// Use case for fetching user profile information
class GetUserProfileUseCase {
  final UserProfileRepository _userProfileRepository;

  /// Creates a new instance of [GetUserProfileUseCase]
  GetUserProfileUseCase(this._userProfileRepository);

  /// Executes the use case to retrieve user's profile information
  ///
  /// Optional [xJarvisGuid] can be provided for specific user context
  Future<UserProfileModel> call({String? xJarvisGuid}) async {
    try {
      return await _userProfileRepository.getUserProfile(
        xJarvisGuid: xJarvisGuid,
      );
    } catch (e) {
      // Log the error before re-throwing
      AppLogger.e('Error in GetUserProfileUseCase: $e');
      rethrow; // Re-throw to allow the bloc to handle the failure
    }
  }
}
