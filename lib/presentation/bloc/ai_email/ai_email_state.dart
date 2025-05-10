import 'package:equatable/equatable.dart';

/// Base class for all AI Email states
abstract class AiEmailState extends Equatable {
  const AiEmailState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class AiEmailInitial extends AiEmailState {}

/// Loading state while generating email
class AiEmailLoading extends AiEmailState {}

/// Success state with the generated email
class AiEmailSuccess extends AiEmailState {
  final String email;
  final int remainingUsage;
  final List<String> improvedActions;

  const AiEmailSuccess({
    required this.email,
    required this.remainingUsage,
    required this.improvedActions,
  });

  @override
  List<Object?> get props => [email, remainingUsage, improvedActions];
}

/// Failure state when email generation fails
class AiEmailFailure extends AiEmailState {
  final String error;

  const AiEmailFailure(this.error);

  @override
  List<Object?> get props => [error];
}
