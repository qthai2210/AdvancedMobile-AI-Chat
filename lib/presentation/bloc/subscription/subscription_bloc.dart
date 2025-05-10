import 'package:aichatbot/domain/usecases/get_user_subscription_usecase.dart';
import 'package:aichatbot/presentation/bloc/subscription/subscription_event.dart';
import 'package:aichatbot/presentation/bloc/subscription/subscription_state.dart';
import 'package:aichatbot/utils/logger.dart';
import 'package:bloc/bloc.dart';

/// BLoC for managing subscription data
class SubscriptionBloc extends Bloc<SubscriptionEvent, SubscriptionState> {
  final GetUserSubscriptionUseCase _getUserSubscriptionUseCase;

  /// Creates a new instance of [SubscriptionBloc]
  SubscriptionBloc(this._getUserSubscriptionUseCase)
      : super(SubscriptionInitial()) {
    on<FetchSubscriptionEvent>(_onFetchSubscription);
    on<RefreshSubscriptionEvent>(_onRefreshSubscription);
  }

  /// Handles fetch subscription event
  Future<void> _onFetchSubscription(
    FetchSubscriptionEvent event,
    Emitter<SubscriptionState> emit,
  ) async {
    try {
      // Only show loading if we're not already loaded
      if (state is! SubscriptionLoaded) {
        emit(SubscriptionLoading());
      }

      final subscription = await _getUserSubscriptionUseCase(
        xJarvisGuid: event.xJarvisGuid,
      );

      emit(SubscriptionLoaded(subscription));
    } catch (e) {
      AppLogger.e('Error fetching subscription: $e');
      emit(SubscriptionError('Failed to load subscription: $e'));
    }
  }

  /// Handles refresh subscription event
  Future<void> _onRefreshSubscription(
    RefreshSubscriptionEvent event,
    Emitter<SubscriptionState> emit,
  ) async {
    try {
      emit(SubscriptionLoading());

      final subscription = await _getUserSubscriptionUseCase(
        xJarvisGuid: event.xJarvisGuid,
      );

      emit(SubscriptionLoaded(subscription));
    } catch (e) {
      AppLogger.e('Error refreshing subscription: $e');
      emit(SubscriptionError('Failed to refresh subscription: $e'));
    }
  }
}
