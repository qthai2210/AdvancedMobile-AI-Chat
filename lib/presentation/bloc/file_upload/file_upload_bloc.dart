import 'package:aichatbot/domain/usecases/knowledge_unit/upload_local_file_use_case.dart';
import 'package:aichatbot/presentation/bloc/file_upload/file_upload_event.dart';
import 'package:aichatbot/presentation/bloc/file_upload/file_upload_state.dart';
import 'package:aichatbot/utils/logger.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FileUploadBloc extends Bloc<FileUploadEvent, FileUploadState> {
  final UploadLocalFileUseCase _uploadLocalFileUseCase;

  FileUploadBloc({
    required UploadLocalFileUseCase uploadLocalFileUseCase,
  })  : _uploadLocalFileUseCase = uploadLocalFileUseCase,
        super(FileUploadInitial()) {
    on<UploadLocalFileEvent>(_onUploadLocalFile);
    on<ResetUploadEvent>(_onResetUpload);
  }

  Future<void> _onUploadLocalFile(
    UploadLocalFileEvent event,
    Emitter<FileUploadState> emit,
  ) async {
    emit(FileUploadLoading());

    try {
      final response = await _uploadLocalFileUseCase.execute(
        knowledgeId: event.knowledgeId,
        file: event.file,
        accessToken: event.accessToken,
        guid: event.guid,
      );

      AppLogger.d('File uploaded successfully: ${response.name}');
      emit(FileUploadSuccess(response: response));
    } catch (e) {
      AppLogger.e('Error uploading file: $e');
      emit(FileUploadError(message: e.toString()));
    }
  }

  void _onResetUpload(
    ResetUploadEvent event,
    Emitter<FileUploadState> emit,
  ) {
    emit(FileUploadInitial());
  }
}
