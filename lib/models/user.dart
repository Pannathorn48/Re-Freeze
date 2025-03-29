import 'package:cloud_firestore/cloud_firestore.dart';

class PlatformUser {
  final String uid;
  final String? displayName;
  final String? profilePictureURL;
  final String? email;
  final List<DocumentReference> refrigeratorsArray;

  PlatformUser(this.uid, this.profilePictureURL, this.email, this.displayName,
      this.refrigeratorsArray);

  factory PlatformUser.fromJSON(Map<String, dynamic> data) {
    final String? displayName = data['displayName'];
    final String? profilePictureURL = data['profilePictureURL'];
    final String? email = data['email'];
    final List<DocumentReference> refrigeratorsArray =
        (data['refrigerators'] as List<dynamic>?)
                ?.map((docRef) => docRef as DocumentReference)
                .toList() ??
            [];
    return PlatformUser(
      data['uid'],
      profilePictureURL,
      email,
      displayName,
      refrigeratorsArray,
    );
  }
}
