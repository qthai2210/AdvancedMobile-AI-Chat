import 'package:equatable/equatable.dart';

/// Model representing the user's subscription data
class SubscriptionModel extends Equatable {
  final String name;
  final int dailyTokens;
  final int monthlyTokens;
  final int annuallyTokens;

  /// Creates a new instance of [SubscriptionModel]
  const SubscriptionModel({
    required this.name,
    required this.dailyTokens,
    required this.monthlyTokens,
    required this.annuallyTokens,
  });

  /// Creates a [SubscriptionModel] from a JSON map
  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      name: json['name'] ?? '',
      dailyTokens: json['dailyTokens'] ?? 0,
      monthlyTokens: json['monthlyTokens'] ?? 0,
      annuallyTokens: json['annuallyTokens'] ?? 0,
    );
  }

  /// Converts this model to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'dailyTokens': dailyTokens,
      'monthlyTokens': monthlyTokens,
      'annuallyTokens': annuallyTokens,
    };
  }

  /// Human-readable subscription name
  String get displayName {
    switch (name.toLowerCase()) {
      case 'basic':
        return 'Basic Plan';
      case 'premium':
        return 'Premium Plan';
      case 'enterprise':
        return 'Enterprise Plan';
      default:
        return name.isNotEmpty
            ? '${name[0].toUpperCase()}${name.substring(1)} Plan'
            : 'Free Plan';
    }
  }

  /// Total tokens available
  int get totalTokens {
    return dailyTokens + monthlyTokens + annuallyTokens;
  }

  @override
  List<Object?> get props => [name, dailyTokens, monthlyTokens, annuallyTokens];
}
