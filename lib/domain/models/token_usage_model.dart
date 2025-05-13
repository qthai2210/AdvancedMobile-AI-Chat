import 'package:equatable/equatable.dart';

/// Model representing the user's token usage data
class TokenUsageModel extends Equatable {
  final int availableTokens;
  final int totalTokens;
  final bool unlimited;
  final DateTime date;

  /// Creates a new instance of [TokenUsageModel]
  const TokenUsageModel({
    required this.availableTokens,
    required this.totalTokens,
    required this.unlimited,
    required this.date,
  });

  /// Creates a [TokenUsageModel] from a JSON map
  factory TokenUsageModel.fromJson(Map<String, dynamic> json) {
    return TokenUsageModel(
      availableTokens: json['availableTokens'] ?? 0,
      totalTokens: json['totalTokens'] ?? 0,
      unlimited: json['unlimited'] ?? false,
      date:
          json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
    );
  }

  /// Converts this model to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'availableTokens': availableTokens,
      'totalTokens': totalTokens,
      'unlimited': unlimited,
      'date': date.toIso8601String(),
    };
  }

  /// Creates a default instance with zero tokens
  factory TokenUsageModel.zero() {
    return TokenUsageModel(
      availableTokens: 0,
      totalTokens: 0,
      unlimited: false,
      date: DateTime.now(),
    );
  }

  @override
  List<Object> get props => [availableTokens, totalTokens, unlimited, date];
}
