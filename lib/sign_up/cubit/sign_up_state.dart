part of 'sign_up_cubit.dart';

enum ConfirmPasswordValidationError { invalid }

class SignUpState extends Equatable {
  const SignUpState({
    this.email = const Email.pure(),
    this.password = const Password.pure(),
    this.confirmedPassword = const ConfirmedPassword.pure(),
    this.firstNames = const FirstNames.pure(),
    this.lastNames = const LastNames.pure(),
    this.status = FormzSubmissionStatus.initial,
  });

  final Email email;
  final Password password;
  final ConfirmedPassword confirmedPassword;
  final FirstNames firstNames;
  final LastNames lastNames;
  final FormzSubmissionStatus status;

  @override
  List<Object> get props => [email, password, confirmedPassword, firstNames, lastNames, status];

  SignUpState copyWith({
    Email? email,
    Password? password,
    ConfirmedPassword? confirmedPassword,
    FirstNames? firstNames,
    LastNames? lastNames,
    FormzSubmissionStatus? status,
  }) {
    return SignUpState(
      email: email ?? this.email,
      password: password ?? this.password,
      confirmedPassword: confirmedPassword ?? this.confirmedPassword,
      firstNames: firstNames ?? this.firstNames,
      lastNames: lastNames ?? this.lastNames,
      status: status ?? this.status,
    );
  }
}