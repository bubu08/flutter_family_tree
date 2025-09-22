import 'package:authentication_repository/authentication_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:database_repository/database_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:family_tree/app.dart';
import 'package:family_tree/simple_bloc_observer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase with proper web configuration
  if (kIsWeb) {
    // For web, Firebase is already initialized in index.html
    // We just need to ensure it's ready
    try {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "demo-api-key",
          authDomain: "demo-project.firebaseapp.com",
          projectId: "demo-project",
          storageBucket: "demo-project.appspot.com",
          messagingSenderId: "123456789",
          appId: "1:123456789:web:abcdef123456",
        ),
      );
    } catch (e) {
      // Firebase might already be initialized
      if (e.toString().contains('already exists')) {
        print('Firebase already initialized');
      } else {
        print('Firebase initialization error: $e');
      }
    }
  } else {
    // For mobile platforms
    await Firebase.initializeApp();
  }
  
  EquatableConfig.stringify = kDebugMode;
  Bloc.observer = SimpleBlocObserver();
  final authenticationRepository = AuthenticationRepository();
  final dataBaseRepository = DataBaseRepository(
    authenticationRepository: authenticationRepository,
  );
  runApp(App(
    authenticationRepository: authenticationRepository,
    dataBaseRepository: dataBaseRepository,
  ));
}
