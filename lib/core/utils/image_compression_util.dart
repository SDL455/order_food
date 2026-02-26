import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:uuid/uuid.dart';

/// Utility for compressing images before upload.
class ImageCompressionUtil {
  ImageCompressionUtil._();

  static const _uuid = Uuid();

  /// Compress [file] and return a new compressed File.
  /// Uses quality 80 and max width 800 for good balance of size/quality.
  static Future<File?> compressImage(File file) async {
    try {
      final ext = file.path.split('.').last.toLowerCase();
      final dir = Directory.systemTemp;
      final targetPath =
          '${dir.path}/${_uuid.v4()}_compressed.${ext == 'png' ? 'png' : 'jpg'}';

      final result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: 80,
        minWidth: 800,
        minHeight: 800,
        format: ext == 'png' ? CompressFormat.png : CompressFormat.jpeg,
      );

      return result != null ? File(result.path) : null;
    } catch (_) {
      return null;
    }
  }

  /// Compress multiple files. Returns list of compressed files (skips nulls).
  static Future<List<File>> compressImages(List<File> files) async {
    final results = <File>[];
    for (final f in files) {
      final compressed = await compressImage(f);
      if (compressed != null) results.add(compressed);
    }
    return results;
  }
}
