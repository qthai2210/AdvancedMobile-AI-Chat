import 'package:equatable/equatable.dart';

/// Base class for subscription events
abstract class SubscriptionEvent extends Equatable {
  const SubscriptionEvent();

  @override
  List<Object?> get props => [];
}

/// Event to fetch user subscription data
class FetchSubscriptionEvent extends SubscriptionEvent {
  final String? xJarvisGuid;

  const FetchSubscriptionEvent({this.xJarvisGuid});

  @override
  List<Object?> get props => [xJarvisGuid];
}

/// Event to refresh subscription data
class RefreshSubscriptionEvent extends SubscriptionEvent {
  final String? xJarvisGuid;

  const RefreshSubscriptionEvent({this.xJarvisGuid});

  @override
  List<Object?> get props => [xJarvisGuid];
}

/// Event to update user subscription after purchase
class UpdateSubscriptionEvent extends SubscriptionEvent {
  final String planName;
  final bool isYearly;

  const UpdateSubscriptionEvent({
    required this.planName,
    required this.isYearly,
  });

  @override
  List<Object?> get props => [planName, isYearly];
}
