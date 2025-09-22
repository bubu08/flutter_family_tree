import 'dart:async';

import 'package:authentication_repository/authentication_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;

import 'models/models.dart' show FamilyTree, Person;

/// Thrown during the database insert process if a failure occurs.
class InsertFailure implements Exception {}

/// Thrown during the database insert process if a failure occurs due to loss in furebase_auth status.
class LoginStatusFailure implements Exception {}

/// {@template database_repository}
/// Repository which database requests.
/// {@endtemplate}
class DataBaseRepository {
  static const String defaultFamilyTreeId = 'default_tree';

  /// {@macro database_repository}
  DataBaseRepository({
    firestore.FirebaseFirestore? firestoreDatabase,
    required AuthenticationRepository authenticationRepository,
  })  
  // {
  //   this._authenticationRepository = authenticationRepository;
  //   this._firestoreDatabase = firestoreDatabase;
  //   print('========= DATABASE REPO CONSTRUCTOR');
  //   print(this.hashCode);
  // }
  : _firestoreDatabase =
            firestoreDatabase ?? firestore.FirebaseFirestore.instance,
        _authenticationRepository = authenticationRepository;

  final firestore.FirebaseFirestore _firestoreDatabase;
  final AuthenticationRepository _authenticationRepository;

  firestore.CollectionReference<Map<String, dynamic>> _treeCollection(String familyTreeId) {
    return _firestoreDatabase
        .collection('family_trees')
        .doc(familyTreeId)
        .collection('people');
  }

  /// Stream of [FamilyTree] which will emit the current family tree when
  /// the database is changed.
  ///
  /// Emits [FamilyTree.empty] if the family tree does not exist.
  Stream<FamilyTree> get familyTree {
    return _firestoreDatabase
        .collection('family_trees')
        .doc(defaultFamilyTreeId)
        .snapshots()
        .map((query) => query.toFamilyTree);

    // return _firebaseAuth.authStateChanges().map((firebaseUser) {
    //   return firebaseUser == null ? User.empty : firebaseUser.toUser;
    // });
  }

  /// Insets a new user into FireStore using information provided by the authentification package.
  ///
  /// Throws an [InsertFailure] if an exception occurs.
  Future<void> insertUser({User? user, String? uid}) async {
    final resolvedUser = user ?? _authenticationRepository.getCurrentUser;
    final resolvedUid = uid ?? _authenticationRepository.getCurrentUserUid;
    assert(resolvedUser != User.empty);
    try {
      final users = _firestoreDatabase.collection('users');
      await users.doc(resolvedUid).set({
        'username': resolvedUser.name,
        'email': resolvedUser.email,
        'imageUrl': resolvedUser.photo,
      });
    } on Exception {
      throw InsertFailure();
    }
  }

  /// Persists a person document within the provided family tree.
  Future<void> savePerson({
    required String familyTreeId,
    required String firstNames,
    required String lastNames,
    String description = '',
  }) async {
    try {
      final treeRef = _firestoreDatabase.collection('family_trees').doc(familyTreeId);
      await treeRef.set(
        {
          'updatedAt': firestore.FieldValue.serverTimestamp(),
        },
        firestore.SetOptions(merge: true),
      );

      final people = treeRef.collection('people');
      await people.add({
        'firstNames': firstNames,
        'lastNames': lastNames,
        'description': description,
        'createdAt': firestore.FieldValue.serverTimestamp(),
      });
    } on Exception {
      throw InsertFailure();
    }
  }

  /// Emits a stream of people for the provided family tree.
  Stream<List<Person>> peopleStream({
    String familyTreeId = defaultFamilyTreeId,
  }) {
    return _treeCollection(familyTreeId).orderBy('createdAt', descending: true).snapshots().map(
      (snapshot) => snapshot.docs
          .map(
            (doc) => doc.toPerson(familyTreeId),
          )
          .toList(),
    );
  }
}

extension on firestore.QueryDocumentSnapshot<Map<String, dynamic>> {
  Person toPerson(String familyTreeId) {
    final data = this.data();
    final birthDate = (data['birthDate'] as firestore.Timestamp?)?.toDate() ?? DateTime.fromMillisecondsSinceEpoch(0);
    final deathDate = (data['deathDate'] as firestore.Timestamp?)?.toDate();

    return Person(
      id: id,
      familyTreeId: familyTreeId,
      firstNames: data['firstNames'] as String? ?? '',
      surname: data['lastNames'] as String? ?? '',
      birthDate: birthDate,
      deathDate: deathDate,
      description: data['description'] as String? ?? '',
      mother: null,
      father: null,
      spouses: const [],
      children: const [],
    );
  }
}

extension on firestore.DocumentSnapshot<Map<String, dynamic>> {
  FamilyTree get toFamilyTree {
    return FamilyTree.empty;
  }
}
