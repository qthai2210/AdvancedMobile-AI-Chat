import 'dart:io';
import 'package:aichatbot/data/models/knowledge/uploaded_file_model.dart';
import 'package:aichatbot/domain/repositories/knowledge_repository.dart';

class UploadRawFileUseCase {
  final KnowledgeRepository repo;
  UploadRawFileUseCase(this.repo);

  Future<UploadedFile> execute(
      {required File file, required String accessToken}) {
    return repo.uploadRawFile(file: file, accessToken: accessToken);
  }
}
