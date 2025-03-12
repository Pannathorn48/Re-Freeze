class PlatformUser {
  final String uid;
  final String displayName;
  final String profilePictureURL;
  final String email;

  PlatformUser(this.uid, this.profilePictureURL, this.email,
      {required this.displayName});

  factory PlatformUser.fromJSON(Map<String, dynamic> data) {
    final String displayName = data['displayName'];
    final String profilePictureURL = data['profilePictureURL'];
    final String email = data['email'];

    return PlatformUser(
      data['uid'],
      profilePictureURL,
      email,
      displayName: displayName,
    );
  }
}
