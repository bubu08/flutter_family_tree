import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:family_tree/sign_up/sign_up.dart';
import 'package:formz/formz.dart';

class SignUpForm extends StatelessWidget {
  const SignUpForm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // blocListener is a Flutter widget which takes a BlocWidgetListener and an optional cubit and invokes the listener in response to state changes in the cubit.
    // should be used for functionality that needs to occur once per state change such as navigation, showing a SnackBar
    // is a void function
    return BlocListener<SignUpCubit, SignUpState>(
      listener: (context, state) {
        if (state.status == FormzSubmissionStatus.failure) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(content: Text('Sign Up Failure')),
            );
        }
      },
      child: const Align(
        alignment: Alignment(0, 0 / 3),
        child: _SignUpFormBody(),
      ),
    );
  }
}

class _SignUpFormBody extends StatelessWidget {
  const _SignUpFormBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _EmailInput(),
          SizedBox(height: 8.0),
          _PasswordInput(),
          SizedBox(height: 8.0),
          _ConfirmPasswordInput(),
          SizedBox(height: 8.0),
          _SignUpButton(),
        ],
      ),
    );
  }
}

class _EmailInput extends StatelessWidget {
  const _EmailInput({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // handles building the widget in response to new states
    // should only be used when it is necessary to both rebuild UI and execute other reactions to state changes in the cubit
    return BlocBuilder<SignUpCubit, SignUpState>(
      buildWhen: (previous, current) => previous.email != current.email,
      builder: (context, state) {
        return TextField(
          key: const Key('signUpForm_emailInput_textField'),
          onChanged: (email) => context.read<SignUpCubit>().emailChanged(email),
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.email_outlined),
            labelText: 'email',
            helperText: '',
            errorText: state.email.isNotValid ? 'invalid email' : null,
          ),
        );
      },
    );
  }
}

class _PasswordInput extends StatelessWidget {
  const _PasswordInput({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignUpCubit, SignUpState>(
      buildWhen: (previous, current) => previous.password != current.password,
      builder: (context, state) {
        return TextField(
          key: const Key('signUpForm_passwordInput_textField'),
          onChanged: (password) =>
              context.read<SignUpCubit>().passwordChanged(password),
          obscureText: true,
          decoration: InputDecoration(
            prefixIcon: const Icon(
              Icons.lock_outline,
              // color: !state.password.isNotValid
              //     ? Theme.of(context).errorColor
              //     : Colors.green,
            ),
            labelText: 'password',
            helperText: '',
            errorText: state.password.isNotValid ? 'invalid password' : null,
          ),
        );
      },
    );
  }
}

class _ConfirmPasswordInput extends StatelessWidget {
  const _ConfirmPasswordInput({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignUpCubit, SignUpState>(
      buildWhen: (previous, current) =>
          previous.password != current.password ||
          previous.confirmedPassword != current.confirmedPassword,
      builder: (context, state) {
        return TextField(
          key: const Key('signUpForm_confirmedPasswordInput_textField'),
          onChanged: (confirmPassword) => context
              .read<SignUpCubit>()
              .confirmedPasswordChanged(confirmPassword),
          obscureText: true,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.lock_outline),
            labelText: 'confirm password',
            helperText: '',
            errorText: state.confirmedPassword.isNotValid
                ? 'passwords do not match'
                : null,
          ),
        );
      },
    );
  }
}

class _SignUpButton extends StatelessWidget {
  const _SignUpButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignUpCubit, SignUpState>(
      buildWhen: (previous, current) =>
          previous.status != current.status ||
          previous.email != current.email ||
          previous.password != current.password ||
          previous.confirmedPassword != current.confirmedPassword,
      builder: (context, state) {
        return state.status == FormzSubmissionStatus.inProgress
            ? const CircularProgressIndicator()
            : ElevatedButton.icon(
                icon: const Icon(Icons.check_box_outlined),
                key: const Key('signUpForm_continue_raisedButton'),
                label: const Text('SIGN UP'),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  backgroundColor: Colors.orangeAccent,
                ),
                onPressed: Formz.validate([
                  state.email,
                  state.password,
                  state.confirmedPassword,
                ])
                    ? () => context.read<SignUpCubit>().signUpFormSubmitted()
                    : null,
              );
      },
    );
  }
}
