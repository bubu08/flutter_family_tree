part of 'edit_person_cubit.dart';

class EditPersonState extends Equatable {
  const EditPersonState({
    this.firstNames = const FirstNames.pure(),
    this.lastNames = const LastNames.pure(),
    this.description = '',
    this.status = FormzSubmissionStatus.initial,
  });

  final FirstNames firstNames;
  final LastNames lastNames;
  final String description;
  final FormzSubmissionStatus status;

  @override
  List<Object> get props => [firstNames, lastNames, description, status];

  EditPersonState copyWith({
    FirstNames? firstNames,
    LastNames? lastNames,
    String? description,
    FormzSubmissionStatus? status,
  }) {
    return EditPersonState(
      firstNames: firstNames ?? this.firstNames,
      lastNames: lastNames ?? this.lastNames,
      description: description ?? this.description,
      status: status ?? this.status,
    );
  }
}
