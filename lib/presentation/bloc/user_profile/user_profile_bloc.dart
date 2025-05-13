import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aichatbot/core/errors/failures.dart';
import 'package:aichatbot/data/models/auth/user_profile_model.dart';
import 'package:aichatbot/domain/usecases/auth/get_user_profile_usecase.dart';
import 'package:aichatbot/utils/logger.dart';

// Events
abstract class UserProfileEvent extends Equatable {
  const UserProfileEvent();

  @override
  List<Object?> get props => [];
}

class FetchUserProfileEvent extends UserProfileEvent {
  final String? xJarvisGuid;

  const FetchUserProfileEvent({this.xJarvisGuid});

  @override
  List<Object?> get props => [xJarvisGuid];
}

// States
abstract class UserProfileState extends Equatable {
  const UserProfileState();

  @override
  List<Object?> get props => [];
}

class UserProfileInitial extends UserProfileState {}

class UserProfileLoading extends UserProfileState {}

class UserProfileLoaded extends UserProfileState {
  final UserProfileModel userProfile;

  const UserProfileLoaded(this.userProfile);

  @override
  List<Object> get props => [userProfile];
}

class UserProfileError extends UserProfileState {
  final String message;

  const UserProfileError(this.message);

  @override
  List<Object> get props => [message];
}

// Bloc
class UserProfileBloc extends Bloc<UserProfileEvent, UserProfileState> {
  final GetUserProfileUseCase getUserProfileUseCase;

  UserProfileBloc({required this.getUserProfileUseCase})
      : super(UserProfileInitial()) {
    on<FetchUserProfileEvent>(_onFetchUserProfile);
  }
  Future<void> _onFetchUserProfile(
    FetchUserProfileEvent event,
    Emitter<UserProfileState> emit,
  ) async {
    try {
      emit(UserProfileLoading());

      final userProfile =
          await getUserProfileUseCase(xJarvisGuid: event.xJarvisGuid);

      emit(UserProfileLoaded(userProfile));
    } on AuthFailure catch (e) {
      AppLogger.e('Authentication error fetching user profile: $e');
      emit(UserProfileError('Authentication error: ${e.message}'));
    } on NetworkFailure catch (e) {
      AppLogger.e('Network error fetching user profile: $e');
      emit(UserProfileError('Network error: ${e.message}'));
    } on ServerFailure catch (e) {
      AppLogger.e('Server error fetching user profile: $e');
      emit(UserProfileError('Server error: ${e.message}'));
    } on NotFoundFailure catch (e) {
      AppLogger.e('Resource not found error: $e');
      emit(UserProfileError('Resource not found: ${e.message}'));
    } on Failure catch (e) {
      AppLogger.e('Other failure type fetching user profile: $e');
      emit(UserProfileError(e.message));
    } catch (e) {
      AppLogger.e('Unexpected error fetching user profile: $e');
      emit(UserProfileError('An unexpected error occurred. Please try again.'));
    }
  }
}
