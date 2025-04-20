import 'package:equatable/equatable.dart';

class KnowledgeUnitModel {
  final String id;
  final String name;
  final String type;
  final int size;
  final bool status;
  final String userId;
  final String knowledgeId;
  final List<String> openAiFileIds;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdBy;
  final String? updatedBy;
  final DateTime? deletedAt;

  KnowledgeUnitModel({
    required this.id,
    required this.name,
    required this.type,
    required this.size,
    required this.status,
    required this.userId,
    required this.knowledgeId,
    required this.openAiFileIds,
    required this.metadata,
    required this.createdAt,
    required this.updatedAt,
    this.createdBy,
    this.updatedBy,
    this.deletedAt,
  });

  factory KnowledgeUnitModel.fromJson(Map<String, dynamic> json) {
    return KnowledgeUnitModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      size: json['size'] ?? 0,
      status: json['status'] ?? false,
      userId: json['userId'] ?? '',
      knowledgeId: json['knowledgeId'] ?? '',
      openAiFileIds: List<String>.from(json['openAiFileIds'] ?? []),
      metadata: json['metadata'] ?? {},
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
      createdBy: json['createdBy'],
      updatedBy: json['updatedBy'],
      deletedAt:
          json['deletedAt'] != null ? DateTime.parse(json['deletedAt']) : null,
    );
  }
}
