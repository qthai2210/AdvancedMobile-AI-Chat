import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aichatbot/presentation/bloc/prompt/prompt_event.dart';
import 'package:aichatbot/presentation/bloc/prompt/prompt_state.dart';
import 'package:aichatbot/domain/usecases/prompt/create_prompt_usecase.dart';
//import 'package:aichatbot/domain/usecases/prompt/update_prompt_usecase.dart';
//import 'package:aichatbot/domain/usecases/prompt/delete_prompt_usecase.dart';
//import 'package:aichatbot/domain/usecases/prompt/get_prompts_usecase.dart';
import 'package:aichatbot/core/errors/failures.dart';

class PromptBloc extends Bloc<PromptEvent, PromptState> {
  final CreatePromptUsecase createPromptUsecase;
  //final UpdatePromptUsecase updatePromptUsecase;
  //final DeletePromptUsecase deletePromptUsecase;
  //final GetPromptsUsecase getPromptsUsecase;

  PromptBloc({
    required this.createPromptUsecase,
    //required this.updatePromptUsecase,
    //required this.deletePromptUsecase,
    //required this.getPromptsUsecase,
  }) : super(const PromptState()) {
    on<CreatePromptRequested>(_onCreatePromptRequested);
    //on<UpdatePromptRequested>(_onUpdatePromptRequested);
    //on<DeletePromptRequested>(_onDeletePromptRequested);
    //on<PromptListRequested>(_onPromptListRequested);
  }

  void _onCreatePromptRequested(
    CreatePromptRequested event,
    Emitter<PromptState> emit,
  ) async {
    emit(state.copyWith(status: PromptStatus.loading));

    try {
      final prompt = await createPromptUsecase(
        accessToken: event.accessToken,
        title: event.title,
        content: event.content,
        description: event.description,
        categories: event.categories,
        isPublic: event.isPublic,
        language: event.language,
      );

      emit(state.copyWith(
        status: PromptStatus.success,
        currentPrompt: prompt,
        prompts: [...state.prompts, prompt],
      ));
    } on PromptFailure catch (failure) {
      emit(state.copyWith(
        status: PromptStatus.failure,
        errorMessage: failure.message,
      ));
    } catch (error) {
      emit(state.copyWith(
        status: PromptStatus.failure,
        errorMessage: error.toString(),
      ));
    }
  }

  // void _onUpdatePromptRequested(
  //   UpdatePromptRequested event,
  //   Emitter<PromptState> emit,
  // ) async {
  //   emit(state.copyWith(status: PromptStatus.loading));

  //   try {
  //     final updatedPrompt = await updatePromptUsecase(
  //       accessToken: event.accessToken,
  //       prompt: event.prompt,
  //     );

  //     final updatedPrompts = state.prompts.map((p) {
  //       return p.id == updatedPrompt.id ? updatedPrompt : p;
  //     }).toList();

  //     emit(state.copyWith(
  //       status: PromptStatus.success,
  //       currentPrompt: updatedPrompt,
  //       prompts: updatedPrompts,
  //     ));
  //   } on PromptFailure catch (failure) {
  //     emit(state.copyWith(
  //       status: PromptStatus.failure,
  //       errorMessage: failure.message,
  //     ));
  //   } catch (error) {
  //     emit(state.copyWith(
  //       status: PromptStatus.failure,
  //       errorMessage: error.toString(),
  //     ));
  //   }
  //}

  // void _onDeletePromptRequested(
  //   DeletePromptRequested event,
  //   Emitter<PromptState> emit,
  // ) async {
  //   emit(state.copyWith(status: PromptStatus.loading));

  //   try {
  //     await deletePromptUsecase(
  //       accessToken: event.accessToken,
  //       promptId: event.promptId,
  //     );

  //     final updatedPrompts =
  //         state.prompts.where((prompt) => prompt.id != event.promptId).toList();

  //     emit(state.copyWith(
  //       status: PromptStatus.success,
  //       prompts: updatedPrompts,
  //     ));
  //   } on PromptFailure catch (failure) {
  //     emit(state.copyWith(
  //       status: PromptStatus.failure,
  //       errorMessage: failure.message,
  //     ));
  //   } catch (error) {
  //     emit(state.copyWith(
  //       status: PromptStatus.failure,
  //       errorMessage: error.toString(),
  //     ));
  //   }
  // }

  // void _onPromptListRequested(
  //   PromptListRequested event,
  //   Emitter<PromptState> emit,
  // ) async {
  //   emit(state.copyWith(status: PromptStatus.loading));

  //   try {
  //     final prompts = await getPromptsUsecase(
  //       accessToken: event.accessToken,
  //     );

  //     emit(state.copyWith(
  //       status: PromptStatus.success,
  //       prompts: prompts,
  //     ));
  //   } on PromptFailure catch (failure) {
  //     emit(state.copyWith(
  //       status: PromptStatus.failure,
  //       errorMessage: failure.message,
  //     ));
  //   } catch (error) {
  //     emit(state.copyWith(
  //       status: PromptStatus.failure,
  //       errorMessage: error.toString(),
  //     ));
  //   }
  // }
}
