import 'package:aichatbot/core/errors/failures.dart';
import 'package:aichatbot/data/datasources/remote/assistant_api_service.dart';
import 'package:aichatbot/data/models/assistant/assistant_list_response.dart';
import 'package:aichatbot/data/models/assistant/assistant_model.dart';
import 'package:aichatbot/data/models/assistant/get_assistants_params.dart';
import 'package:aichatbot/domain/repositories/assistant_repository.dart';
import 'package:dio/dio.dart';

/// Implementation of [AssistantRepository] that uses API service
class AssistantRepositoryImpl implements AssistantRepository {
  final AssistantApiService assistantApiService;

  /// Creates a new instance of [AssistantRepositoryImpl]
  AssistantRepositoryImpl({required this.assistantApiService});

  @override
  Future<AssistantListResponse> getAssistants({
    String? query,
    SortOrder? order,
    String? orderField,
    int? offset,
    int? limit,
    bool? isFavorite,
    bool? isPublished,
    String? xJarvisGuid,
  }) async {
    try {
      final params = GetAssistantsParams(
        q: query,
        order: order,
        orderField: orderField,
        offset: offset,
        limit: limit,
        isFavorite: isFavorite,
        isPublished: isPublished,
        xJarvisGuid: xJarvisGuid,
      );

      return await assistantApiService.getAssistants(params);
    } on DioException catch (e) {
      throw ServerFailure(
        e.response?.statusMessage ?? 'Server error: ${e.response?.statusCode}',
      );
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<AssistantModel> getAssistantById(String assistantId,
      {String? xJarvisGuid}) async {
    try {
      return await assistantApiService.getAssistantById(assistantId,
          xJarvisGuid: xJarvisGuid);
    } on DioException catch (e) {
      throw ServerFailure(
        e.response?.statusMessage ?? 'Server error: ${e.response?.statusCode}',
      );
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<AssistantModel> createAssistant({
    required String assistantName,
    String? instructions,
    String? description,
    String? guidId,
  }) async {
    try {
      return await assistantApiService.createAssistant(
        assistantName: assistantName,
        instructions: instructions,
        description: description,
        guidId: guidId,
      );
    } on DioException catch (e) {
      throw ServerFailure(
        e.response?.statusMessage ?? 'Server error: ${e.response?.statusCode}',
      );
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<AssistantModel> updateAssistant({
    required String assistantId,
    required String assistantName,
    String? instructions,
    String? description,
    String? xJarvisGuid,
  }) async {
    try {
      return await assistantApiService.updateAssistant(
        assistantId: assistantId,
        assistantName: assistantName,
        instructions: instructions,
        description: description,
        xJarvisGuid: xJarvisGuid,
      );
    } on DioException catch (e) {
      throw ServerFailure(
        e.response?.statusMessage ?? 'Server error: ${e.response?.statusCode}',
      );
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<bool> deleteAssistant({
    required String assistantId,
    String? xJarvisGuid,
  }) async {
    try {
      return await assistantApiService.deleteAssistant(
        assistantId: assistantId,
        xJarvisGuid: xJarvisGuid,
      );
    } on DioException catch (e) {
      throw ServerFailure(
        e.response?.statusMessage ?? 'Server error: ${e.response?.statusCode}',
      );
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<bool> linkKnowledgeToAssistant({
    required String assistantId,
    required String knowledgeId,
    String? accessToken,
    String? xJarvisGuid,
  }) async {
    try {
      return await assistantApiService.linkKnowledgeToAssistant(
        assistantId: assistantId,
        knowledgeId: knowledgeId,
        accessToken: accessToken,
        xJarvisGuid: xJarvisGuid,
      );
    } on DioException catch (e) {
      throw ServerFailure(
        e.response?.statusMessage ?? 'Server error: ${e.response?.statusCode}',
      );
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<bool> removeKnowledgeFromAssistant({
    required String assistantId,
    required String knowledgeId,
    String? accessToken,
    String? xJarvisGuid,
  }) async {
    try {
      return await assistantApiService.removeKnowledgeFromAssistant(
        assistantId: assistantId,
        knowledgeId: knowledgeId,
        accessToken: accessToken,
        xJarvisGuid: xJarvisGuid,
      );
    } on DioException catch (e) {
      throw ServerFailure(
        e.response?.statusMessage ?? 'Server error: ${e.response?.statusCode}',
      );
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<String> publishTelegramBot({
    required String assistantId,
    required String botToken,
    String? accessToken,
    String? xJarvisGuid,
  }) async {
    try {
      return await assistantApiService.publishTelegramBot(
        assistantId: assistantId,
        botToken: botToken,
        accessToken: accessToken,
        xJarvisGuid: xJarvisGuid,
      );
    } on DioException catch (e) {
      throw ServerFailure(
        e.response?.statusMessage ?? 'Server error: ${e.response?.statusCode}',
      );
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> validateTelegramBot({
    required String botToken,
    String? accessToken,
    String? xJarvisGuid,
  }) async {
    try {
      return await assistantApiService.validateTelegramBot(
        botToken: botToken,
        accessToken: accessToken,
        xJarvisGuid: xJarvisGuid,
      );
    } on DioException catch (e) {
      throw ServerFailure(
        e.response?.statusMessage ?? 'Server error: ${e.response?.statusCode}',
      );
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> validateSlackBot({
    required String botToken,
    required String clientId,
    required String clientSecret,
    required String signingSecret,
    String? accessToken,
    String? xJarvisGuid,
  }) async {
    try {
      return await assistantApiService.validateSlackBot(
        botToken: botToken,
        clientId: clientId,
        clientSecret: clientSecret,
        signingSecret: signingSecret,
        accessToken: accessToken,
        xJarvisGuid: xJarvisGuid,
      );
    } on DioException catch (e) {
      throw ServerFailure(
        e.response?.statusMessage ?? 'Server error: ${e.response?.statusCode}',
      );
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }
}
