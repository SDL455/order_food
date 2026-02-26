import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

/// Singleton convenience accessors for Firebase services.
class FirebaseService {
  FirebaseService._();

  static final FirebaseAuth auth = FirebaseAuth.instance;
  static final FirebaseFirestore firestore = FirebaseFirestore.instance;
  static final FirebaseStorage storage = FirebaseStorage.instance;

  /// Current authenticated user (nullable).
  static User? get currentUser => auth.currentUser;

  /// Current user UID or empty string.
  static String get uid => currentUser?.uid ?? '';

  /// Whether user is signed in.
  static bool get isLoggedIn => currentUser != null;
}
