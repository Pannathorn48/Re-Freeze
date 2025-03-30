// models/refrigerators_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Refrigerator {
  final String uid;
  final String name;
  final String? imageUrl;
  final String groupId;
  final bool isPrivate;
  final DateTime? createdAt;
  final String? ownerId;
  final String? createdBy;
  final List<String>? users;

  Refrigerator({
    required this.uid,
    required this.name,
    this.imageUrl,
    required this.groupId,
    required this.isPrivate,
    this.createdAt,
    this.ownerId,
    this.createdBy,
    this.users,
  });

  factory Refrigerator.fromJSON(Map<String, dynamic> data) {
    return Refrigerator(
      uid: data['uid'] as String,
      name: data['name'] as String,
      imageUrl: data["imageUrl"] as String?,
      groupId: data['groupId'] as String? ?? "",
      isPrivate: data['isPrivate'] as bool? ?? false,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
      ownerId: data['ownerId'] as String?,
      createdBy: data['createdBy'] as String?,
      users: data['users'] != null ? List<String>.from(data['users']) : null,
    );
  }

  Map<String, dynamic> toJSON() {
    return {
      'uid': uid,
      'name': name,
      'imageUrl': imageUrl,
      'groupId': groupId,
      'isPrivate': isPrivate,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'ownerId': ownerId,
      'createdBy': createdBy,
      'users': users,
    };
  }
}
