import 'package:mobile_project/exceptions/user_exception.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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


}
