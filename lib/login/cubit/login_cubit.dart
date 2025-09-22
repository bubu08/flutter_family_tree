import 'package:authentication_repository/authentication_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:family_tree/authentication/authentication.dart';
import 'package:formz/formz.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this._authenticationRepository) : super(const LoginState());

  final AuthenticationRepository _authenticationRepository;

  void emailChanged(String value) {
    final email = Email.dirty(value);
    emit(state.copyWith(
      email: email,
    ));
  }

  void passwordChanged(String value) {
    final password = Password.dirty(value);
    emit(state.copyWith(
      password: password,
    ));
  }

  Future<void> logInWithCredentials() async {
    if (!Formz.validate([state.email, state.password])) return;
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    try {
      await _authenticationRepository.logInWithEmailAndPassword(
        email: state.email.value,
        password: state.password.value,
      );
      emit(state.copyWith(status: FormzSubmissionStatus.success));
    } catch (_) {
      emit(state.copyWith(status: FormzSubmissionStatus.failure));
    }
  }

  Future<void> logInWithGoogle() async {
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    try {
      await _authenticationRepository.logInWithGoogle();
      emit(state.copyWith(status: FormzSubmissionStatus.success));
    } on NoSuchMethodError {
      emit(state.copyWith(status: FormzSubmissionStatus.initial));
    } catch (_) {
      emit(state.copyWith(status: FormzSubmissionStatus.failure));
    }
  }
}