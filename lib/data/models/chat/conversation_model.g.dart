// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConversationModel _$ConversationModelFromJson(Map<String, dynamic> json) =>
    ConversationModel(
      id: json['id'] as String,
      title: json['title'] as String,
      createdAt: (json['createdAt'] as num).toInt(),
    );

Map<String, dynamic> _$ConversationModelToJson(ConversationModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'createdAt': instance.createdAt,
    };

ConversationListResponseModel _$ConversationListResponseModelFromJson(
        Map<String, dynamic> json) =>
    ConversationListResponseModel(
      cursor: json['cursor'] as String?,
      hasMore: json['has_more'] as bool,
      limit: (json['limit'] as num).toInt(),
      items: (json['items'] as List<dynamic>)
          .map((e) => ConversationModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ConversationListResponseModelToJson(
        ConversationListResponseModel instance) =>
    <String, dynamic>{
      'cursor': instance.cursor,
      'has_more': instance.hasMore,
      'limit': instance.limit,
      'items': instance.items,
    };
