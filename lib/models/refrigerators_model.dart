class Refrigerator {
  final String uid;
  final String name;
  const Refrigerator({
    required this.uid,
    required this.name,
  });

  factory Refrigerator.fromJSON(Map<String, dynamic> data) {
    return Refrigerator(
      uid: data['uid'],
      name: data['name'],
    );
  }

  static Refrigerator fromJson(Map<String, dynamic> ref) {
    return Refrigerator(
      uid: ref['uid'] as String,
      name: ref['name'] as String,
    );
  }
}
