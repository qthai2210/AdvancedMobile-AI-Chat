import 'package:equatable/equatable.dart';

/// Model representing the user's subscription data
class SubscriptionModel extends Equatable {
  final String name;
  final String pricingDisplay;
  final double price;
  final String billingPeriod; // 'monthly' or 'yearly'
  final bool isActive;
  final DateTime? expiryDate;
  final List<String> features;
  final List<String> modelAccess;
  final int? creditsAllotment;
  final int? dailyModelAccesses;

  /// Creates a new instance of [SubscriptionModel]
  const SubscriptionModel({
    required this.name,
    required this.pricingDisplay,
    required this.price,
    required this.billingPeriod,
    required this.isActive,
    this.expiryDate,
    required this.features,
    required this.modelAccess,
    this.creditsAllotment,
    this.dailyModelAccesses,
  });

  /// Creates a [SubscriptionModel] from a JSON map
  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      name: json['name'] ?? '',
      pricingDisplay: json['pricingDisplay'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      billingPeriod: json['billingPeriod'] ?? 'monthly',
      isActive: json['isActive'] ?? false,
      expiryDate: json['expiryDate'] != null
          ? DateTime.parse(json['expiryDate'])
          : null,
      features: List<String>.from(json['features'] ?? []),
      modelAccess: List<String>.from(json['modelAccess'] ?? []),
      creditsAllotment: json['creditsAllotment'],
      dailyModelAccesses: json['dailyModelAccesses'],
    );
  }

  /// Converts this model to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'pricingDisplay': pricingDisplay,
      'price': price,
      'billingPeriod': billingPeriod,
      'isActive': isActive,
      'expiryDate': expiryDate?.toIso8601String(),
      'features': features,
      'modelAccess': modelAccess,
      'creditsAllotment': creditsAllotment,
      'dailyModelAccesses': dailyModelAccesses,
    };
  }

  /// Human-readable subscription name
  String get displayName {
    switch (name.toLowerCase()) {
      case 'free':
        return 'Free';
      case 'starter':
        return 'Starter';
      case 'pro':
        return 'Pro';
      default:
        return name.isNotEmpty
            ? '${name[0].toUpperCase()}${name.substring(1)}'
            : 'Free';
    }
  }

  /// Get credits available (or 0 if none)
  int get availableCredits {
    return creditsAllotment ?? 0;
  }

  @override
  List<Object?> get props => [
        name,
        pricingDisplay,
        price,
        billingPeriod,
        isActive,
        expiryDate,
        features,
        modelAccess,
        creditsAllotment,
        dailyModelAccesses,
      ];

  /// Factory to create a free plan subscription
  factory SubscriptionModel.free() {
    return SubscriptionModel(
      name: 'free',
      pricingDisplay: 'US\$0',
      price: 0,
      billingPeriod: 'free',
      isActive: true,
      features: [
        '40 accesses to basic models daily',
        'GPT-4o mini',
        'Claude 3.5 Haiku',
        'DeepSeek V3 & R1',
        'Limited trial for image/video generation',
        'Basic model-driven smart writing, translation, and summary',
        'Limited trial for ChatPDF',
      ],
      modelAccess: ['GPT-4o mini', 'Claude 3.5 Haiku', 'DeepSeek V3 & R1'],
      dailyModelAccesses: 40,
    );
  }

  /// Factory to create a starter plan subscription
  factory SubscriptionModel.starter({bool yearly = false}) {
    return SubscriptionModel(
      name: 'starter',
      pricingDisplay: yearly ? 'US\$79.9/year' : 'US\$6.67/month',
      price: yearly ? 79.9 : 6.67,
      billingPeriod: yearly ? 'yearly' : 'monthly',
      isActive: true,
      expiryDate: DateTime.now().add(Duration(days: yearly ? 365 : 30)),
      features: [
        'UNLIMITED accesses to basic models monthly',
        'GPT-4o mini',
        'Claude 3.5 Haiku',
        'DeepSeek V3 & R1',
        'UNLIMITED accesses to advanced models monthly',
        'o1 & GPT-4o',
        'Claude 3.7 Sonnet',
        'Gemini 2.0 Pro',
        'Llama 3.1 405B',
        'Advanced model-driven smart writing, translation, summary, and ChatPDF',
        '1500 Advanced Credits',
      ],
      modelAccess: [
        'GPT-4o mini',
        'Claude 3.5 Haiku',
        'DeepSeek V3 & R1',
        'o1 & GPT-4o',
        'Claude 3.7 Sonnet',
        'Gemini 2.0 Pro',
        'Llama 3.1 405B'
      ],
      creditsAllotment: 1500,
    );
  }
}
