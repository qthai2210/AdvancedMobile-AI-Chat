import 'package:aichatbot/core/errors/exceptions.dart';
import 'package:aichatbot/core/errors/failures.dart';
import 'package:aichatbot/data/datasources/remote/user_profile_api_service.dart';
import 'package:aichatbot/data/models/auth/user_profile_model.dart';
import 'package:aichatbot/domain/repositories/user_profile_repository.dart';
import 'package:aichatbot/utils/logger.dart';

/// Implementation of the [UserProfileRepository] interface
class UserProfileRepositoryImpl implements UserProfileRepository {
  final UserProfileApiService _userProfileApiService;

  /// Creates a new instance of [UserProfileRepositoryImpl]
  UserProfileRepositoryImpl(
      {required UserProfileApiService userProfileApiService})
      : _userProfileApiService = userProfileApiService;
  @override
  Future<UserProfileModel> getUserProfile({String? xJarvisGuid}) async {
    try {
      return await _userProfileApiService.getUserProfile(
        xJarvisGuid: xJarvisGuid,
      );
    } on UnauthorizedException catch (e) {
      AppLogger.e('Authentication error: $e');
      throw AuthFailure('Authentication failed: ${e.message}');
    } on ServerException catch (e) {
      AppLogger.e('Server error: $e');
      throw ServerFailure(e.message);
    } on NetworkException catch (e) {
      AppLogger.e('Network error: $e');
      throw NetworkFailure(e.message);
    } on NotFoundException catch (e) {
      AppLogger.e('Resource not found: $e');
      throw NotFoundFailure(e.message);
    } catch (e) {
      AppLogger.e('Unexpected error fetching user profile: $e');
      throw UnexpectedFailure('Unexpected error: $e');
    }
  }
}
