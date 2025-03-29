import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_project/exceptions/user_exception.dart';
import 'package:mobile_project/models/user.dart';
import 'package:mobile_project/services/image_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserApi {
  final CollectionReference _users =
      FirebaseFirestore.instance.collection('users');

  Future<void> initUser(String uid, String displayName) {
    return _users.doc(uid).set({
      'uid': uid,
      'displayName': displayName,
    });
  }

  Future<PlatformUser?> getUser(String? uid) async {
    if (uid == null) {
      return null;
    }
    try {
      final user = await _users.doc(uid).get();
      if (user.exists) {
        return PlatformUser.fromJSON(user.data() as Map<String, dynamic>);
      } else {
        return null;
      }
    } catch (e) {
      throw UserException(e.toString(), UserException.getUserException);
    }
  }

  Future<void> updateDisplayName(String uid, String newName) async {
    try {
      _users.doc(uid).update({'displayName': newName});
    } catch (e) {
      throw UserException(
          e.toString(), UserException.updateDisplayNameException);
    }
  }

  Future<void> updateProfilePicture(String uid, String imageURL) async {
    try {
      _users.doc(uid).update({'profilePictureURL': imageURL});
    } catch (e) {
      throw UserException(
          e.toString(), UserException.updateProfilePictureException);
    }
  }

  Future<String?> getProfilePicture(String uid) async {
    try {
      PlatformUser? user = await getUser(uid);
      if (user != null && user.profilePictureURL != null) {
        String path = user.profilePictureURL!;
        String? result = ImageService.getSignURL(path);

        return result;
      } else {
        return null;
      }
    } catch (e) {
      throw UserException(e.toString(), UserException.imageFetchException);
    }
  }

  Stream<QuerySnapshot<Object?>> getFavritesRefrigerators(String uid) {
    return _users.doc(uid).collection('refrigerators').snapshots();
  }
}
