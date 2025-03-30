// models/user.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class PlatformUser {
  final String uid;
  final String? displayName;
  final String? profilePictureURL;
  final String? email;
  final List<dynamic> refrigeratorsArray;

  PlatformUser(
    this.uid,
    this.profilePictureURL,
    this.email,
    this.displayName,
    this.refrigeratorsArray,
  );

  factory PlatformUser.fromJSON(Map<String, dynamic> data) {
    final String? displayName = data['displayName'];
    final String? profilePictureURL = data['profilePictureURL'];
    final String? email = data['email'];

    // Handle different structures of refrigeratorsArray
    List<dynamic> refrigeratorsArray = [];
    if (data.containsKey('refrigeratorsArray') &&
        data['refrigeratorsArray'] != null) {
      // Array of maps with id and name
      refrigeratorsArray = data['refrigeratorsArray'];
    } else if (data.containsKey('refrigerators') &&
        data['refrigerators'] != null) {
      // Array of document references
      refrigeratorsArray = (data['refrigerators'] as List<dynamic>)
          .map((docRef) => docRef as DocumentReference)
          .toList();
    }

    return PlatformUser(
      data['uid'],
      profilePictureURL,
      email,
      displayName,
      refrigeratorsArray,
    );
  }

  Map<String, dynamic> toJSON() {
    return {
      'uid': uid,
      'displayName': displayName,
      'profilePictureURL': profilePictureURL,
      'email': email,
      'refrigeratorsArray': refrigeratorsArray,
    };
  }
}
