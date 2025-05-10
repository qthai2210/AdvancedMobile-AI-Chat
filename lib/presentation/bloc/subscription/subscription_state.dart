import 'package:aichatbot/domain/models/subscription_models.dart';
import 'package:equatable/equatable.dart';

/// Base state for subscription bloc
abstract class SubscriptionState extends Equatable {
  const SubscriptionState();

  @override
  List<Object?> get props => [];
}

/// Initial state when no subscription data has been loaded
class SubscriptionInitial extends SubscriptionState {}

/// Loading state when fetching subscription data
class SubscriptionLoading extends SubscriptionState {}

/// Success state when subscription data is loaded
class SubscriptionLoaded extends SubscriptionState {
  final SubscriptionModel subscription;

  const SubscriptionLoaded(this.subscription);

  @override
  List<Object?> get props => [subscription];
}

/// Error state when subscription loading fails
class SubscriptionError extends SubscriptionState {
  final String message;

  const SubscriptionError(this.message);

  @override
  List<Object?> get props => [message];
}
