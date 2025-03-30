import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_project/models/item_model.dart';

class ItemPreset {
  final String uid;
  final String name;
  final String imageUrl;
  final String unit;
  final int quantity;
  final DateTime expiryDate;
  final DateTime warningDate;
  final List<Tag> tags;
  final String createdBy; // User ID of the creator
  final DateTime? createdAt; // When this preset was created

  ItemPreset({
    required this.uid,
    required this.name,
    required this.imageUrl,
    required this.unit,
    required this.quantity,
    required this.expiryDate,
    required this.warningDate,
    required this.tags,
    required this.createdBy,
    this.createdAt,
  });

  factory ItemPreset.fromJSON(Map<String, dynamic> json) {
    // Handle Timestamp or String for dates
    DateTime parseDate(dynamic dateValue) {
      if (dateValue is Timestamp) {
        return dateValue.toDate();
      } else if (dateValue is String) {
        return DateTime.parse(dateValue);
      }
      return DateTime.now(); // Fallback
    }

    // Parse tags
    List<Tag> parseTags(List<dynamic>? tagData) {
      if (tagData == null) return [];

      return tagData.map((tag) {
        if (tag is Map<String, dynamic>) {
          return Tag.fromJSON(tag);
        }
        return Tag(uid: '', name: 'Unknown', color: const Color(0xFF000000));
      }).toList();
    }

    return ItemPreset(
      uid: json['uid'] ?? '',
      name: json['name'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      unit: json['unit'] ?? '',
      quantity: json['quantity'] ?? 0,
      expiryDate: json['expiryDate'] != null
          ? parseDate(json['expiryDate'])
          : DateTime.now(),
      warningDate: json['warningDate'] != null
          ? parseDate(json['warningDate'])
          : DateTime.now(),
      tags: parseTags(json['tags']),
      createdBy: json['createdBy'] ?? '',
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] as Timestamp).toDate()
          : null,
    );
  }

  // Convert to Item model
  Item toItem(String refrigeratorId) {
    return Item(
      uid: '',
      name: name,
      quantity: quantity,
      expiryDate: expiryDate,
      warningDate: warningDate,
      imageUrl: imageUrl,
      unit: unit,
      refrigeratorId: refrigeratorId,
      tags: tags,
    );
  }

  // Convert to a Map for Firestore
  Map<String, dynamic> toJSON() {
    return {
      'uid': uid,
      'name': name,
      'imageUrl': imageUrl,
      'unit': unit,
      'quantity': quantity,
      'expiryDate': Timestamp.fromDate(expiryDate),
      'warningDate': Timestamp.fromDate(warningDate),
      'tags': tags.map((tag) => tag.toJSON()).toList(),
      'createdBy': createdBy,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
    };
  }
}
