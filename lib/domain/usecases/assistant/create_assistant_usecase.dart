import 'package:aichatbot/data/models/assistant/assistant_model.dart';
import 'package:aichatbot/domain/repositories/assistant_repository.dart';

/// Use case for creating a new assistant
class CreateAssistantUseCase {
  final AssistantRepository repository;

  CreateAssistantUseCase(this.repository);

  /// Creates a new assistant with the provided details
  ///
  /// [assistantName] is required
  /// [instructions] and [description] are optional parameters
  /// [guidId] is an optional tracking ID
  Future<AssistantModel> call({
    required String assistantName,
    String? instructions,
    String? description,
    String? guidId,
  }) {
    return repository.createAssistant(
      assistantName: assistantName,
      instructions: instructions,
      description: description,
      guidId: guidId,
    );
  }
}
