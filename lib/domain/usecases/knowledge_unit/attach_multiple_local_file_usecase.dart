import 'package:aichatbot/data/models/knowledge/file_upload_response.dart';
import 'package:aichatbot/data/models/knowledge/uploaded_file_model.dart';
import 'package:aichatbot/domain/repositories/knowledge_repository.dart';

class AttachMultipleLocalFilesUseCase {
  final KnowledgeRepository _repo;
  AttachMultipleLocalFilesUseCase(this._repo);

  Future<FileUploadResponse> execute({
    required String knowledgeId,
    required List<UploadedFile> uploadedFiles,
    required String accessToken,
  }) {
    return _repo.attachMultipleLocalFiles(
      knowledgeId: knowledgeId,
      uploadedFiles: uploadedFiles,
      accessToken: accessToken,
    );
  }
}
