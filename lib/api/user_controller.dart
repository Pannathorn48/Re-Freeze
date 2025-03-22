import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_project/exceptions/user_exception.dart';
import 'package:mobile_project/models/user.dart';

class UserDatabase {
  final CollectionReference _users =
      FirebaseFirestore.instance.collection('users');

  Future<void> initUser(String uid, String displayName) {
    return _users.doc(uid).set({
      'uid': uid,
      'displayName': displayName,
    });
  }

  Future<PlatformUser?> getUser(String uid) async {
    try {
      return _users.doc(uid).get().then((DocumentSnapshot documentSnapshot) {
        if (documentSnapshot.exists) {
          return PlatformUser.fromJSON(
              documentSnapshot.data() as Map<String, dynamic>);
        } else {
          return null;
        }
      });
    } catch (e) {
      throw UserException(e.toString(), "get-user-error");
    }
  }
}
