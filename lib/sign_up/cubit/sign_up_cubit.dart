import 'package:authentication_repository/authentication_repository.dart';
import 'package:database_repository/database_repository.dart';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:family_tree/authentication/authentication.dart';
import 'package:formz/formz.dart';

part 'sign_up_state.dart';

class SignUpCubit extends Cubit<SignUpState> {
  SignUpCubit(this._authenticationRepository, this._dataBaseRepository)
      : super(const SignUpState());

  final AuthenticationRepository _authenticationRepository;
  final DataBaseRepository _dataBaseRepository;

  void emailChanged(String value) {
    final email = Email.dirty(value);
    emit(state.copyWith(
      email: email,
    ));
  }

  void passwordChanged(String value) {
    final password = Password.dirty(value);
    final confirmedPassword = ConfirmedPassword.dirty(
      password: password.value,
      value: state.confirmedPassword.value,
    );
    emit(state.copyWith(
      email: state.email,
      password: password,
      confirmedPassword: confirmedPassword,
    ));
  }

  void confirmedPasswordChanged(String value) {
    final confirmedPassword = ConfirmedPassword.dirty(
      password: state.password.value,
      value: value,
    );
    emit(state.copyWith(
      confirmedPassword: confirmedPassword,
    ));
  }

  Future<void> signUpFormSubmitted() async {
    if (!Formz.validate([
      state.email,
      state.password,
      state.confirmedPassword,
    ])) return;
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    try {
      await _authenticationRepository.signUp(
        email: state.email.value,
        password: state.password.value,
      );
      final user = _authenticationRepository.getCurrentUser;
      final userUid = _authenticationRepository.getCurrentUserUid;
      await _dataBaseRepository.insertUser(user: user, uid: userUid);
      emit(state.copyWith(status: FormzSubmissionStatus.success));
    } on Exception {
      emit(state.copyWith(status: FormzSubmissionStatus.failure));
    }
  }
}
