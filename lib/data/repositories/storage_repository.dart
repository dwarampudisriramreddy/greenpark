import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/config/app_config.dart';
import '../supabase_client.dart';

/// Uploads and deletes images in Supabase Storage.
///
/// Returns the public URL of an uploaded file.
class StorageRepository {
  Future<String> uploadImage({
    required String bucket,
    required File file,
    String? prefix,
  }) async {
    final name = file.path.split('/').last;
    final dot = name.lastIndexOf('.');
    final ext = dot >= 0 ? name.substring(dot) : '.jpg';
    final path =
        '${prefix ?? 'uploads'}/${DateTime.now().millisecondsSinceEpoch}$ext';
    await supabase.storage.from(bucket).upload(
          path,
          file,
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
