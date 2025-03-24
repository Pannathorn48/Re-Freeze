import 'dart:ui';

import 'package:mobile_project/models/dropdownable.dart';

class Item {
  String name;
  int quantity;
  DateTime expiryDate;
  String imageUrl;
  String unit;
  String get expiryDateString =>
      "${expiryDate.day}/${expiryDate.month}/${expiryDate.year}";
  List<Tag> tags;
  Item({
    required this.name,
    required this.quantity,
    required this.expiryDate,
    required this.imageUrl,
    required this.tags,
    required this.unit,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      name: json['name'],
      quantity: json['quantity'],
      expiryDate: DateTime.parse(json['expiryDate']),
      imageUrl: json['imageUrl'],
      unit: json['unit'],
      tags: (json['tags'] as List?)?.map((tag) => Tag.fromJson(tag)).toList() ??
          <Tag>[],
    );
  }
}

class Tag extends Dropdownable {
  final String uuid = "12345";
  Tag({required super.name, required super.color});

  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      name: json['name'],
      color: Color(json['color']),
    );
  }

  @override
  bool operator ==(Object other) {
    return name == (other as Tag).name;
  }

  @override
  int get hashCode => name.hashCode ^ color.hashCode;
}
