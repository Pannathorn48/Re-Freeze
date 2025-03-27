import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_project/exceptions/user_exception.dart';
import 'package:mobile_project/models/user.dart';

class UserController {
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
      throw UserException(e.toString(), "get-user-error");
    }
  }

  Future<bool> updateDisplayName(String uid, String newName) {
    try {
      _users.doc(uid).update({'displayName': newName});
      return Future.value(true);
    } catch (e) {
      throw UserException(e.toString(), "update-display-name-error");
    }
  }
}
