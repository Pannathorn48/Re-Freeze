class Refrigerator {
  final String uid;
  final String name;
  final String groupId;
  final String? imageUrl;
  final bool isPrivate;
  const Refrigerator({
    required this.groupId,
    required this.imageUrl,
    required this.isPrivate,
    required this.uid,
    required this.name,
  });

  factory Refrigerator.fromJSON(Map<String, dynamic> data) {
    return Refrigerator(
      uid: data['uid'] as String,
      name: data['name'] as String,
      groupId: data['groupId'] as String? ?? "",
      imageUrl: data["imageUrl"] as String?,
      isPrivate: data['isPrivate'] as bool? ?? false,
    );
  }
}
