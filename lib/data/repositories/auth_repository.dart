import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/constants/app_constants.dart';
import '../../core/services/firebase_service.dart';
import '../../core/services/notification_service.dart';
import '../models/user_model.dart';

/// Handles authentication and user-document CRUD.
class AuthRepository {
  final _auth = FirebaseService.auth;
  final _users = FirebaseService.firestore.collection(AppConstants.usersCol);

  /// Register with email + password, then create Firestore user doc.
  Future<UserModel> register({
    required String email,
    required String password,
    required String displayName,
    String role = AppConstants.roleCustomer,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final uid = cred.user!.uid;

    final user = UserModel(uid: uid, role: role, displayName: displayName);
    await _users.doc(uid).set(user.toMap());
    await _saveFcmToken(uid);
    return user;
  }

  /// Sign in with email + password.
  Future<UserModel?> login({
    required String email,
    required String password,
  }) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final uid = cred.user!.uid;
    await _saveFcmToken(uid);
    return await getUser(uid);
  }

  /// Sign out.
  Future<void> logout() async {
    await _auth.signOut();
  }

  /// Fetch the Firestore user document.
  Future<UserModel?> getUser(String uid) async {
    final doc = await _users.doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromMap(doc.data()!, uid);
  }

  /// Update user profile fields.
  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _users.doc(uid).update(data);
  }

  /// Save current FCM token to the user's fcmTokens array.
  Future<void> _saveFcmToken(String uid) async {
    final token = await NotificationService.instance.getToken();
    if (token != null) {
      await _users.doc(uid).update({
        'fcmTokens': FieldValue.arrayUnion([token]),
      });
    }
  }

  /// Refresh FCM token (call on app start if logged in).
  Future<void> refreshFcmToken() async {
    final uid = FirebaseService.uid;
    if (uid.isNotEmpty) await _saveFcmToken(uid);
  }
}
