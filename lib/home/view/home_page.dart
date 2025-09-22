import 'package:database_repository/database_repository.dart' as db;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:family_tree/authentication/authentication.dart';
import 'package:family_tree/person/person.dart' as person;
import 'package:family_tree/profile/profile.dart' as profile;

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
      body: StreamBuilder<List<db.Person>>(
        stream: context.read<db.DataBaseRepository>().peopleStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Unable to load family tree.'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final people = snapshot.data ?? <db.Person>[];

          if (people.isEmpty) {
            return const Center(
              child: Text('No relatives yet. Tap the + button to add someone.'),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 96),
            itemCount: people.length,
            itemBuilder: (context, index) {
              final person = people[index];
              return ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person_outline)),
                title: Text('${person.firstNames} ${person.surname}'.trim()),
                subtitle: person.description.isNotEmpty
                    ? Text(person.description)
                    : null,
              );
            },
            separatorBuilder: (_, __) => const Divider(height: 1),
          );
        },
      ),
    );
  }
}
