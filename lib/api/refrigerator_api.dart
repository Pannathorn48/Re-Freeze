import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_project/api/user_api.dart';
import 'package:mobile_project/exceptions/user_exception.dart';
import 'package:mobile_project/models/refrigerators_model.dart';
import 'package:mobile_project/models/user.dart';

class RefrigeratorApi {
  final UserApi _userApi = UserApi();
  final CollectionReference _refrigerators =
      FirebaseFirestore.instance.collection('refrigerators');

  Stream<QuerySnapshot> getRefrigeratorsFromUserId(String uid) {
    return _refrigerators.where('users', arrayContains: uid).snapshots();
  }

  Future<Refrigerator?> getRefrigeratorById(String id) async {
    try {
      final doc = await _refrigerators.doc(id).get();
      if (doc.exists) {
        return Refrigerator.fromJson(doc.data() as Map<String, dynamic>);
      } else {
        return null;
      }
    } catch (e) {
      throw Exception('Error fetching refrigerator: $e');
    }
  }

  Future<List<Refrigerator>> getFavoriteRefrigerators(String uid) async {
    try {
      final PlatformUser? user = await _userApi.getUser(uid);
      if (user == null) {
        throw UserException("user not found", UserException.getUserException);
      }

      final List<Refrigerator> favoriteRefrigerators = [];

      for (var ref in user.refrigeratorsArray) {
        final doc = await _refrigerators.doc(ref.id).get();
        if (doc.exists) {
          favoriteRefrigerators
              .add(Refrigerator.fromJson(doc.data() as Map<String, dynamic>));
        }
      }

      return favoriteRefrigerators;
    } catch (e) {
      throw Exception('Error fetching favorite refrigerators: $e');
    }
  }
}
