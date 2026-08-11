import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/config/app_config.dart';
import '../supabase_client.dart';

/// Uploads and deletes images in Supabase Storage.
///
/// Returns the public URL of an uploaded file. Uses [uploadBinary] with raw
/// bytes so it works identically on mobile and web.
class StorageRepository {
  Future<String> uploadImage({
    required String bucket,
    required Uint8List bytes,
    required String extension,
    String? prefix,
  }) async {
    final name = '${DateTime.now().millisecondsSinceEpoch}$extension';
    final path = '${prefix ?? 'uploads'}/$name';
    await supabase.storage.from(bucket).uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(upsert: true, cacheControl: '3600'),
        );
    return supabase.storage.from(bucket).getPublicUrl(path);
  }

  Future<void> deleteImage(String bucket, String publicUrl) async {
    final base = '${AppConfig.supabaseUrl}/storage/v1/object/public/$bucket/';
    if (!publicUrl.startsWith(base)) return;
    final path = publicUrl.substring(base.length);
    try {
      await supabase.storage.from(bucket).remove([path]);
    } catch (_) {
      // The object may already be gone.
    }
  }
}
