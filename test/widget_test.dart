// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:authentication_repository/authentication_repository.dart';
import 'package:database_repository/database_repository.dart';

import 'package:family_tree/app.dart';

void main() {
  testWidgets('App widget test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    final authenticationRepository = AuthenticationRepository();
    final dataBaseRepository = DataBaseRepository(
      authenticationRepository: authenticationRepository,
    );
    
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
