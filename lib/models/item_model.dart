import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_project/models/dropdownable_model.dart';

class Item {
  String uid; // Added for Firebase document ID
  String name;
  int quantity;
  DateTime warningDate;
  DateTime expiryDate;
  String imageUrl;
  String unit;
  String refrigeratorId; // Added for referencing parent refrigerator

  String get expiryDateString =>
      "${expiryDate.day}/${expiryDate.month}/${expiryDate.year}";

  List<Tag> tags;

  Item({
    required this.name,
    required this.quantity,
    required this.expiryDate,
    required this.warningDate,
    required this.imageUrl,
    required this.tags,
    required this.unit,
    this.uid = '', // Default empty string for new items
    this.refrigeratorId = '', // Default empty string for new items
  });

  factory Item.fromJSON(Map<String, dynamic> json) {
    // Handle Timestamp or String for dates
    DateTime parseDate(dynamic dateValue) {
      if (dateValue is Timestamp) {
        return dateValue.toDate();
      } else if (dateValue is String) {
        return DateTime.parse(dateValue);
      }
      return DateTime.now(); // Fallback
    }

    return Item(
      uid: json['uid'] ?? '',
      name: json['name'] ?? '',
      quantity: json['quantity'] ?? 0,
      expiryDate: json['expiryDate'] != null
          ? parseDate(json['expiryDate'])
          : DateTime.now(),
      warningDate: json['warningDate'] != null
          ? parseDate(json['warningDate'])
          : DateTime.now(),
      imageUrl: json['imageUrl'] ?? '',
      unit: json['unit'] ?? '',
      refrigeratorId: json['refrigeratorId'] ?? '',
      tags: (json['tags'] as List?)?.map((tag) => Tag.fromJSON(tag)).toList() ??
          <Tag>[],
    );
  }

  // Added toJSON method for saving to Firebase
  Map<String, dynamic> toJSON() {
    return {
      'uid': uid,
      'name': name,
      'quantity': quantity,
      'expiryDate': Timestamp.fromDate(expiryDate),
      'warningDate': Timestamp.fromDate(warningDate),
      'imageUrl': imageUrl,
      'unit': unit,
      'refrigeratorId': refrigeratorId,
      'tags': tags.map((tag) => tag.toJSON()).toList(),
    };
  }
}

class Tag extends Dropdownable {
  final String uid;

  Tag({required this.uid, required super.name, required super.color});

  factory Tag.fromJSON(Map<String, dynamic> json) {
    // Maintain your original implementation
    return Tag(
      uid: json['uid'] ?? '',
      name: json['name'] ?? '',
      color: json['color'] != null
          ? Color(int.parse("0X${json['color']}"))
          : const Color(0xFF000000), // Default black
    );
  }

  // Added toJSON method for saving to Firebase
  Map<String, dynamic> toJSON() {
    // Convert color to hex string without 0X prefix for storage
    String colorHex = color.value.toRadixString(16).substring(2);

    return {
      'uid': uid,
      'name': name,
      'color': colorHex,
    };
  }

  @override
  bool operator ==(Object other) {
    return name == (other as Tag).name;
  }

  @override
  int get hashCode => name.hashCode ^ color.hashCode;
}
