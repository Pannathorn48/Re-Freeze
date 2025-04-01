import 'dart:io';
import 'package:mobile_project/exceptions/user_exception.dart';
import 'package:path/path.dart' as path;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class ImageService {
  static String getSignURL(String path) {
    try {
      if (path.startsWith('mobile-image/')) {
        path = path.replaceFirst('mobile-image/', '');
      }

      final String signedURL = Supabase.instance.client.storage
          .from('mobile-image')
          .getPublicUrl(path);

      return signedURL;
    } catch (e) {
      throw UserException(
          'Error getting signed URL: $e', UserException.imageFetchException);
    }
  }

  static Future<String> uploadImage(String imagePath, String dest) async {
    String fileExtension = path.extension(imagePath);
    String uuid = const Uuid().v4();

    String storagePath = '/$dest/$uuid$fileExtension';

    String fullPath = await Supabase.instance.client.storage
        .from('mobile-image')
        .upload(storagePath, File(imagePath));

    return fullPath;
  }
}
