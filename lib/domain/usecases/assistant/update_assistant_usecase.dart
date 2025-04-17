import 'package:aichatbot/data/models/assistant/assistant_model.dart';
import 'package:aichatbot/domain/repositories/assistant_repository.dart';

/// Use case for updating an existing AI assistant
class UpdateAssistantUseCase {
  final AssistantRepository _repository;

  /// Creates a new instance of [UpdateAssistantUseCase]
  UpdateAssistantUseCase(this._repository);

  /// Executes the use case to update an assistant
  ///
  /// [assistantId] - Required ID of the assistant to update
  /// [assistantName] - Required new name for the assistant
  /// [instructions] - Optional new instructions for the assistant
  /// [description] - Optional new description for the assistant
  /// [xJarvisGuid] - Optional GUID for tracking
  Future<AssistantModel> call({
    required String assistantId,
    required String assistantName,
    String? instructions,
    String? description,
    String? xJarvisGuid,
  }) {
    return _repository.updateAssistant(
      assistantId: assistantId,
      assistantName: assistantName,
      instructions: instructions,
      description: description,
      xJarvisGuid: xJarvisGuid,
    );
  }
}
