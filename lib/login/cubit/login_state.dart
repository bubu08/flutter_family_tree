part of 'login_cubit.dart';

class LoginState extends Equatable {
  const LoginState({
    this.email = const Email.pure(),
    this.password = const Password.pure(),
    this.status = FormzSubmissionStatus.initial,
  });

  final Email email;
  final Password password;
  final FormzSubmissionStatus status;

  @override
  List<Object> get props => [email, password, status];

  LoginState copyWith({
    Email? email,
    Password? password,
    FormzSubmissionStatus? status,
  }) {
    return LoginState(
      email: email ?? this.email,
      password: password ?? this.password,
      status: status ?? this.status,
    );
  }
}
