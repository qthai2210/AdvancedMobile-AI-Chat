import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:aichatbot/core/config/api_config.dart';
import 'package:aichatbot/core/errors/exceptions.dart';
import 'package:aichatbot/data/models/prompt/prompt_model.dart';

class PromptApiService {
  final http.Client client;
  final Map<String, String> _headers = ApiConfig.defaultHeaders;

  PromptApiService({required this.client});

  Future<PromptModel> createPrompt({
    required String accessToken,
    required String title,
    required String content,
    required String description,
    required String category,
    required bool isPublic,
    required String language,
  }) async {
    final response = await client.post(
      Uri.parse('${ApiConfig.jarvisBaseUrl}/prompts'),
      headers: {
        ..._headers,
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode({
        'title': title,
        'content': content,
        'description': description,
        'category': category,
        'isPublic': isPublic,
        'language': language,
      }),
    );

    if (response.statusCode == 201) {
      return PromptModel.fromJson(jsonDecode(response.body));
    } else {
      throw ServerException('Failed to create prompt: ${response.body}');
    }
  }

  Future<PromptModel> updatePrompt({
    required String accessToken,
    required String promptId,
    required Map<String, dynamic> promptData,
  }) async {
    final response = await client.put(
      Uri.parse('${ApiConfig.jarvisBaseUrl}/prompts/$promptId'),
      headers: {
        ..._headers,
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(promptData),
    );

    if (response.statusCode == 200) {
      return PromptModel.fromJson(jsonDecode(response.body));
    } else {
      throw ServerException('Failed to update prompt: ${response.body}');
    }
  }

  Future<List<PromptModel>> getPrompts({
    required String accessToken,
  }) async {
    final response = await client.get(
      Uri.parse('${ApiConfig.jarvisBaseUrl}/prompts'),
      headers: {
        ..._headers,
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((item) => PromptModel.fromJson(item)).toList();
    } else {
      throw ServerException('Failed to get prompts: ${response.body}');
    }
  }

  Future<void> deletePrompt({
    required String accessToken,
    required String promptId,
  }) async {
    final response = await client.delete(
      Uri.parse('${ApiConfig.jarvisBaseUrl}/prompts/$promptId'),
      headers: {
        ..._headers,
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode != 204) {
      throw ServerException('Failed to delete prompt: ${response.body}');
    }
  }
}
