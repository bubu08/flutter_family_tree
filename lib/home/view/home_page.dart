import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:family_tree/authentication/authentication.dart';

import 'package:family_tree/person/person.dart' as person;
import 'package:family_tree/profile/profile.dart' as profile;

import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class HomePage extends StatelessWidget {

  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => HomePage());
  }

  @override
  Widget build(BuildContext context) {
    // final textTheme = Theme.of(context).textTheme;
    // final user = context.select((AuthenticationBloc bloc) => bloc.state.user);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Family Tree'),
        actions: <Widget>[
          IconButton(
            key: const Key('homePage_profile_iconButton'),
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.of(context).push(profile.ProfilePage.route());
            },
          ),
          IconButton(
            key: const Key('homePage_logout_iconButton'),
            icon: const Icon(Icons.exit_to_app),
            onPressed: () => context
                .read<AuthenticationBloc>()
                .add(AuthenticationLogoutRequested()),
          )
        ],
      ),
      floatingActionButton: SpeedDial(
        animationDuration: const Duration(milliseconds: 300),
        animationCurve: Curves.linear,
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add),
        children: [
          SpeedDialChild(
            child: const Icon(Icons.share),
            label: 'Share Tree',
            onTap: () {},
          ),
          SpeedDialChild(
            child: const Icon(Icons.person_add),
            label: 'Add Person',
            onTap: () {
              Navigator.of(context).push(person.PersonPage.route());
            },
          ),
        ],
      ),
      body: Align(
        alignment: const Alignment(0, -1 / 3),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // Avatar(photo: user.photo),
            // const SizedBox(height: 4.0),
            // Text(user.email, style: textTheme.headline6),
            // const SizedBox(height: 4.0),
            // Text(user.name ?? '', style: textTheme.headline5),
          ],
        ),
      ),
    );
  }
}
