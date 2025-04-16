import 'package:aichatbot/domain/repositories/assistant_repository.dart';

/// Use case for deleting an existing AI assistant
class DeleteAssistantUseCase {
  final AssistantRepository _repository;

  /// Creates a new instance of [DeleteAssistantUseCase]
  DeleteAssistantUseCase(this._repository);

  /// Executes the use case to delete an assistant
  ///
  /// [assistantId] - Required ID of the assistant to delete
  /// [xJarvisGuid] - Optional GUID for tracking
  /// Returns true if deletion was successful
  Future<bool> call({
    required String assistantId,
    String? xJarvisGuid,
  }) {
    return _repository.deleteAssistant(
      assistantId: assistantId,
      xJarvisGuid: xJarvisGuid,
    );
  }
}
