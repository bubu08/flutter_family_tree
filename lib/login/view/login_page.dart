import 'package:authentication_repository/authentication_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:family_tree/login/login.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => const LoginPage());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: BlocProvider(
          create: (_) => LoginCubit(context.read<AuthenticationRepository>()),
          child: const Align(
            alignment: Alignment(0, 0),
            child: _LoginPageBody(),
          ),
        ),
      ),
    );
  }
}

class _LoginPageHeader extends StatelessWidget {
  const _LoginPageHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Image.asset('assets/bloc_logo_small.png', height: 60),
          const Text(
            'Family Tree',
            style: TextStyle(
              fontFamily: 'HangingTree',
              fontSize: 60,
              color: Colors.brown,
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginPageBody extends StatelessWidget {
  const _LoginPageBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _LoginPageHeader(),
        LoginForm(),
      ],
    );
  }
}
