import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
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

    // Parse tags with improved error handling
    List<Tag> parseTags(dynamic tagData) {
      if (tagData == null) {
        print('No tag data found in preset JSON');
        return [];
      }

      // Make sure we're dealing with a list
      if (tagData is! List) {
        print('Tag data is not a list: ${tagData.runtimeType}');
        return [];
      }

      print('Found ${tagData.length} tags in preset JSON');

      return tagData.map((tag) {
        try {
          if (tag is Map<String, dynamic>) {
            if (tag.containsKey('uid') &&
                tag.containsKey('name') &&
                tag.containsKey('color')) {
              final colorString = tag['color'] as String;

              // Handle color parsing
              Color parsedColor;
              try {
                // Make sure we have a valid hex string
                String hexColor = colorString;
                if (!hexColor.startsWith('0X') &&
                    !hexColor.startsWith('0x') &&
                    !hexColor.startsWith('#')) {
                  hexColor = '0X$hexColor';
                }
                parsedColor = Color(int.parse(hexColor.replaceAll('#', '')));
              } catch (e) {
                parsedColor = const Color(0xFF000000); // Default black
              }

              return Tag(
                uid: tag['uid'] as String,
                name: tag['name'] as String,
                color: parsedColor,
              );
            } else {
              print('Tag missing required fields: $tag');
            }
          } else {
            print('Tag is not a Map: ${tag.runtimeType}');
          }
        } catch (e) {
          print('Error parsing tag: $e');
        }

        // Fallback for any parsing errors
        return Tag(uid: '', name: 'Unknown', color: const Color(0xFF000000));
      }).toList();
    }

    final tagList = parseTags(json['tags']);
    print('Successfully parsed ${tagList.length} tags for preset');

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
      tags: tagList,
      createdBy: json['createdBy'] ?? '',
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] as Timestamp).toDate()
          : null,
    );
  }

  // Convert to Item model
  Item toItem(String refrigeratorId) {
    return Item(
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
    // Convert tags to a serializable format
    final List<Map<String, dynamic>> tagData = tags
        .map((tag) => {
              'uid': tag.uid,
              'name': tag.name,
              'color': tag.color.toHexString()
            })
        .toList();

    return {
      'uid': uid,
      'name': name,
      'imageUrl': imageUrl,
      'unit': unit,
      'quantity': quantity,
      'expiryDate': Timestamp.fromDate(expiryDate),
      'warningDate': Timestamp.fromDate(warningDate),
      'tags': tagData,
      'createdBy': createdBy,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
    };
  }
}
