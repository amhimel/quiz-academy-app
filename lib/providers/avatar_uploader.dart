import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// EXACT bucket id (use the one that worked in your test UI).
/// If your bucket is named "profiles", keep it. If it's "avatars"/"avators", change it here.
const kAvatarBucket = 'profiles';

final avatarUploaderProvider =
StateNotifierProvider<AvatarUploader, AsyncValue<String?>>(
      (ref) => AvatarUploader(),
);

class AvatarUploader extends StateNotifier<AsyncValue<String?>> {
  AvatarUploader() : super(const AsyncData(null));

  Future<String?> uploadFile(File file) async {
    try {
      state = const AsyncLoading();

      final sb = Supabase.instance.client;
      final user = sb.auth.currentUser;
      if (user == null) {
        throw AuthException('Not logged in yet (no session)');
      }

      // stable key: overwrite one file per user; change to timestamped if you prefer
      String ext = file.path.split('.').last.toLowerCase();
      if (ext == 'jpeg') ext = 'jpg';
      final key = '${user.id}/profile.$ext'; // INSIDE bucket (no leading slash)

      final bytes = await file.readAsBytes();
      await sb.storage.from(kAvatarBucket).uploadBinary(
        key,
        bytes,
        fileOptions: FileOptions(
          upsert: true,
          contentType: 'image/$ext',
        ),
      );

      // Public URL (for private bucket, use createSignedUrl)
      var url = sb.storage.from(kAvatarBucket).getPublicUrl(key);
      // cache-bust so UI refreshes immediately
      url = Uri.parse(url).replace(queryParameters: {
        't': DateTime.now().millisecondsSinceEpoch.toString(),
      }).toString();

      // save in DB
      await sb.from('profiles').update({'avatar_url': url}).eq('id', user.id);

      state = AsyncData(url);
      return url;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}
