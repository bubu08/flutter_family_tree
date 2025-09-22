import 'package:bloc/bloc.dart';
import 'package:database_repository/database_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:family_tree/family_tree/family_tree.dart';
import 'package:formz/formz.dart';

part 'edit_person_state.dart';

class EditPersonCubit extends Cubit<EditPersonState> {
  EditPersonCubit(
    this._dataBaseRepository, {
    this.familyTreeId = DataBaseRepository.defaultFamilyTreeId,
  }) : super(const EditPersonState());

  final DataBaseRepository _dataBaseRepository;
  final String familyTreeId;

  void firstNamesChanged(String value) {
    final firstNames = FirstNames.dirty(value);
    emit(state.copyWith(
      firstNames: firstNames,
    ));
  }

  void lastNamesChanged(String value) {
    final lastNames = LastNames.dirty(value);
    emit(state.copyWith(
      lastNames: lastNames,
    ));
  }

  void descriptionChanged(String value) {
    emit(state.copyWith(description: value));
  }

  Future<void> savePerson() async {
    if (!Formz.validate([state.firstNames, state.lastNames])) {
      emit(state.copyWith(status: FormzSubmissionStatus.failure));
      return;
    }

    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    try {
      await _dataBaseRepository.savePerson(
        familyTreeId: familyTreeId,
        firstNames: state.firstNames.value,
        lastNames: state.lastNames.value,
        description: state.description,
      );
      emit(state.copyWith(status: FormzSubmissionStatus.success));
    } catch (_) {
      emit(state.copyWith(status: FormzSubmissionStatus.failure));
    }
  }
}
