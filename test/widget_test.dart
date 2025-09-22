// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:authentication_repository/authentication_repository.dart'
    as auth;
import 'package:database_repository/database_repository.dart' as db;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:family_tree/app.dart';

class MockAuthenticationRepository extends Mock
    implements auth.AuthenticationRepository {
  @override
  Stream<auth.User> get user => super.noSuchMethod(
        Invocation.getter(#user),
        returnValue: Stream<auth.User>.fromIterable([auth.User.empty]),
        returnValueForMissingStub:
            Stream<auth.User>.fromIterable([auth.User.empty]),
      );

  @override
  auth.User get getCurrentUser => super.noSuchMethod(
        Invocation.getter(#getCurrentUser),
        returnValue: auth.User.empty,
        returnValueForMissingStub: auth.User.empty,
      );

  @override
  String get getCurrentUserUid => super.noSuchMethod(
        Invocation.getter(#getCurrentUserUid),
        returnValue: '',
        returnValueForMissingStub: '',
      );

  @override
  Future<void> logOut() => super.noSuchMethod(
        Invocation.method(#logOut, const []),
        returnValue: Future.value(),
        returnValueForMissingStub: Future.value(),
      );
}

class MockDataBaseRepository extends Mock implements db.DataBaseRepository {}

void main() {
  testWidgets('App widget test', (WidgetTester tester) async {
    final auth.AuthenticationRepository authenticationRepository =
        MockAuthenticationRepository();
    final db.DataBaseRepository dataBaseRepository =
        MockDataBaseRepository();

    await tester.pumpWidget(App(
      authenticationRepository: authenticationRepository,
      dataBaseRepository: dataBaseRepository,
    ));

    // Verify that the app loads without crashing
    await tester.pumpAndSettle();

    // This is a basic smoke test to ensure the app can be instantiated
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
