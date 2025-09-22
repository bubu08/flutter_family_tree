import 'package:family_tree/family_tree/family_tree.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';

part 'edit_person_state.dart';

class EditPersonCubit extends Cubit<EditPersonState> {
  EditPersonCubit() : super(const EditPersonState());

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

  Future<void> savePerson() async {
    if (!Formz.validate([state.firstNames, state.lastNames])) {
      emit(state.copyWith(status: FormzSubmissionStatus.failure));
      return;
    }

    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    try {
      // TODO: integrate with repository once backend is ready.
      await Future<void>.delayed(const Duration(milliseconds: 300));
      emit(state.copyWith(status: FormzSubmissionStatus.success));
    } catch (_) {
      emit(state.copyWith(status: FormzSubmissionStatus.failure));
    }
  }
}
