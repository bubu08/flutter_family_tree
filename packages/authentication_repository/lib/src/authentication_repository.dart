import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';

import 'models/models.dart';

/// Thrown if during the sign up process if a failure occurs.
class SignUpFailure implements Exception {}

// Thrown during the login process if a failure occurs.
class LogInWithEmailAndPasswordFailure implements Exception {}

/// Thrown during the sign in with google process if a failure occurs.
class LogInWithGoogleFailure implements Exception {}

/// Thrown during the logout process if a failure occurs.
class LogOutFailure implements Exception {}

/// {@template authentication_repository}
/// Repository which manages user authentication.
/// {@endtemplate}
class AuthenticationRepository {
  /// {@macro authentication_repository}
  AuthenticationRepository({
    firebase_auth.FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  }) {
    _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance;
    _googleSignIn = googleSignIn ?? GoogleSignIn.instance;
    _shouldInitializeGoogleSignIn = googleSignIn == null;
    _currentUser = User.empty;
    _currentUserUid = '';

    _firebaseAuth.authStateChanges().listen((firebaseUser) {
      _currentUser = firebaseUser?.toUser ?? User.empty;
      _currentUserUid = firebaseUser?.uid ?? '';
    });
  }

  late firebase_auth.FirebaseAuth _firebaseAuth;
  late GoogleSignIn _googleSignIn;
  late final bool _shouldInitializeGoogleSignIn;
  Future<void>? _googleSignInInitialization;

  late User _currentUser;
  late String _currentUserUid;

  /// Stream of [User] which will emit the current user when
  /// the authentication state changes.
  ///
  /// Emits [User.empty] if the user is not authenticated.
  Stream<User> get user {
    return _firebaseAuth.authStateChanges().map((firebaseUser) {
      return firebaseUser?.toUser ?? User.empty;
    });
  }

  User get getCurrentUser {
    return _currentUser;
  }

  String get getCurrentUserUid {
    return _currentUserUid;
  }

  /// Creates a new user with the provided [email] and [password].
  ///
  /// Throws a [SignUpFailure] if an exception occurs.
  Future<void> signUp({
    required String email,
    required String password,
  }) async {
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on Exception {
      throw SignUpFailure();
    }
  }

  /// Starts the Sign In with Google Flow.
  ///
  /// Throws a [LogInWithGoogleFailure] if an exception occurs.
  Future<void> logInWithGoogle() async {
    try {
      await _ensureGoogleSignInInitialized();
      final googleUser = await _googleSignIn.authenticate();
      final googleAuth = googleUser.authentication;
      final idToken = googleAuth.idToken;
      if (idToken == null || idToken.isEmpty) {
        throw LogInWithGoogleFailure();
      }
      final credential = firebase_auth.GoogleAuthProvider.credential(
        idToken: idToken,
      );
      await _firebaseAuth.signInWithCredential(credential);
    } on Exception {
      throw LogInWithGoogleFailure();
    }
  }

  /// Signs in with the provided [email] and [password].
  ///
  /// Throws a [LogInWithEmailAndPasswordFailure] if an exception occurs.
  Future<void> logInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on Exception {
      throw LogInWithEmailAndPasswordFailure();
    }
  }

  /// Signs out the current user which will emit
  /// [User.empty] from the [user] Stream.
  ///
  /// Throws a [LogOutFailure] if an exception occurs.
  Future<void> logOut() async {
    try {
      await _firebaseAuth.signOut();
      await _ensureGoogleSignInInitialized();
      await _googleSignIn.signOut();
    } on Exception {
      throw LogOutFailure();
    }
  }

  Future<void> _ensureGoogleSignInInitialized() {
    if (!_shouldInitializeGoogleSignIn) {
      return Future.value();
    }
    return _googleSignInInitialization ??=
        _googleSignIn.initialize();
  }
}

extension on firebase_auth.User {
  User get toUser {
    return User(
      id: uid, 
      email: email ?? '', 
      name: displayName ?? '', 
      photo: photoURL ?? ''
    );
  }
}
