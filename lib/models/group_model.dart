import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_project/models/dropdownable_model.dart';

class Group extends Dropdownable {
  final String uid; // Added uid property
  final String creatorName;
  final String description;
  final int? memberCount; // Added optional member count
  final DateTime? createdAt; // Added optional created date

  Group({
    required this.uid,
    required super.name,
    required super.color,
    required this.creatorName,
    required this.description,
    this.memberCount,
    this.createdAt,
  });

  factory Group.fromJSON(Map<String, dynamic> data) {
    final colorData = data['color'];
    final color = Color(int.parse("0X$colorData"));

    return Group(
      uid: data['uid'] as String,
      name: data['name'] as String,
      color: color,
      creatorName: data['creatorName'] as String,
      description: data['description'] as String,
      memberCount: data['memberCount'] as int?,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
    );
  }
}
