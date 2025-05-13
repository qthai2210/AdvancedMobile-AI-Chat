import 'dart:async';
import 'dart:convert';

import 'package:aichatbot/core/config/api_config.dart';
import 'package:aichatbot/core/network/api_service_factory.dart';
import 'package:aichatbot/data/models/chat/assistant_message_chunk.dart';
import 'package:aichatbot/utils/logger.dart';
import 'package:aichatbot/utils/secure_storage_util.dart';
import 'package:http/http.dart' as http;

/// Service for interacting with the AI Assistant Ask API using Server-Sent Events (SSE)
class AiAssistantAskApiService {
  /// Base URL for the knowledge API
  final String baseUrl = ApiConfig.knowledgeUrl;

  /// HTTP client for making requests
  final http.Client _client = http.Client();

  /// Creates a new instance of [AiAssistantAskApiService]
  AiAssistantAskApiService();

  /// Sends a message to the AI assistant and returns a stream of response chunks
  Stream<AssistantMessageChunk> askAssistant({
    required String assistantId,
    required String message,
    required String openAiThreadId,
    String additionalInstruction = "",
    String? jarvisGuid,
    String? authToken,
  }) {
    // Create a stream controller to emit chunks
    final StreamController<AssistantMessageChunk> controller =
        StreamController<AssistantMessageChunk>();

    // Process the request asynchronously
    _processRequest(
      controller: controller,
      assistantId: assistantId,
      message: message,
      openAiThreadId: openAiThreadId,
      additionalInstruction: additionalInstruction,
      jarvisGuid: jarvisGuid,
      authToken: authToken,
    );

    // Return the stream of message chunks
    return controller.stream;
  }

  /// Internal method to process the SSE request and handle the response
  Future<void> _processRequest({
    required StreamController<AssistantMessageChunk> controller,
    required String assistantId,
    required String message,
    required String openAiThreadId,
    required String additionalInstruction,
    String? jarvisGuid,
    String? authToken,
  }) async {
    try {
      // If no auth token provided, try to get it from secure storage
      if (authToken == null) {
        authToken = await SecureStorageUtil().getAccessToken();
      }

      // Construct the URL for the API endpoint
      final url =
          Uri.parse('$baseUrl/kb-core/v1/ai-assistant/$assistantId/ask');

      // Prepare the request body
      final body = jsonEncode({
        'message': message,
        'openAiThreadId': openAiThreadId,
        'additionalInstruction': additionalInstruction,
      });

      // Prepare the headers
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'text/event-stream',
      };

      // Add optional headers if available
      if (jarvisGuid != null && jarvisGuid.isNotEmpty) {
        headers['x-jarvis-guid'] = jarvisGuid;
      }

      if (authToken != null && authToken.isNotEmpty) {
        headers['Authorization'] = 'Bearer $authToken';
      }

      AppLogger.i('Making SSE request to AI Assistant Ask API: $url');

      // Create and send the request
      final request = http.Request('POST', url);
      request.headers.addAll(headers);
      request.body = body;

      // Send the request and get the response
      final response = await _client.send(request);

      if (response.statusCode == 200) {
        // Process the SSE stream
        String buffer = '';

        // Listen to the response stream and process events
        response.stream.transform(utf8.decoder).listen(
          (data) {
            // Add data to buffer
            buffer += data;

            // Process all complete events in the buffer
            while (true) {
              final eventEnd = buffer.indexOf('\n\n');
              if (eventEnd == -1) break; // No complete event in buffer

              final event = buffer.substring(0, eventEnd);
              buffer = buffer.substring(eventEnd + 2); // Remove processed event

              _processEvent(event, controller);
            }
          },
          onDone: () {
            // Process any remaining data in the buffer
            if (buffer.isNotEmpty) {
              _processEvent(buffer, controller);
            }

            // Close the controller when done
            if (!controller.isClosed) {
              AppLogger.i('SSE stream completed');
              controller.close();
            }
          },
          onError: (error) {
            AppLogger.e('SSE stream error: $error');
            controller.addError(error);
            if (!controller.isClosed) {
              controller.close();
            }
          },
          cancelOnError: true,
        );
      } else {
        // Handle non-200 response
        final errorMsg = 'Failed to connect to SSE: ${response.statusCode}';
        AppLogger.e(errorMsg);
        controller.addError(Exception(errorMsg));
        controller.close();
      }
    } catch (e) {
      // Handle any errors in the request
      AppLogger.e('Error in SSE request: $e');
      if (!controller.isClosed) {
        controller.addError(e);
        controller.close();
      }
    }
  }

  /// Process a single SSE event and emit the appropriate chunk
  void _processEvent(
      String eventText, StreamController<AssistantMessageChunk> controller) {
    try {
      // Parse the event text to extract event type and data
      final lines = eventText.split('\n');
      String? eventType;
      String? eventData;

      for (var line in lines) {
        if (line.startsWith('event:')) {
          eventType = line.substring(6).trim();
        } else if (line.startsWith('data:')) {
          eventData = line.substring(5).trim();
        }
      }

      // Process the event based on its type
      if (eventType != null && eventData != null) {
        if (eventType == 'message') {
          // Parse the data as JSON and create a chunk
          final data = jsonDecode(eventData);
          final chunk = AssistantMessageChunk.fromJson(data);

          // Only add the chunk to the stream if it's not closed
          if (!controller.isClosed) {
            controller.add(chunk);
          }
        } else if (eventType == 'message_end') {
          // Message end event indicates the end of the response
          AppLogger.i('Received message_end event');
          // We could add a special event here if needed
        }
      }
    } catch (e) {
      AppLogger.e('Error processing SSE event: $e');
    }
  }

  /// Closes the HTTP client
  void dispose() {
    _client.close();
  }
}
