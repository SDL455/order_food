import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import '../utils/app_logger.dart';
import 'firebase_service.dart';

/// Handles image uploads to Firebase Storage and returns download URLs.
class StorageService {
  StorageService._();
  static final StorageService instance = StorageService._();

  final _uuid = const Uuid();

  /// Upload [file] under [folder] in Firebase Storage.
  /// Returns the public download URL.
  Future<String> uploadImage(File file, String folder) async {
    final ext = file.path.split('.').last;
    final fileName = '${_uuid.v4()}.$ext';
    final ref = FirebaseService.storage.ref().child(folder).child(fileName);

    final uploadTask = await ref.putFile(
      file,
      SettableMetadata(contentType: 'image/$ext'),
    );

    return await uploadTask.ref.getDownloadURL();
  }

  /// Delete file at [url] from Firebase Storage.
  Future<void> deleteImage(String url) async {
    try {
      final ref = FirebaseService.storage.refFromURL(url);
      await ref.delete();
    } catch (e, st) {
      AppLogger.w('deleteImage failed (file may not exist)', e, st);
    }
  }
}
