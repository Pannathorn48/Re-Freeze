import 'dart:ui';

import 'package:mobile_project/models/dropdownable_model.dart';

class Item {
  String name;
  int quantity;
  DateTime warningDate;
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
    required this.warningDate,
    required this.imageUrl,
    required this.tags,
    required this.unit,
  });

  factory Item.fromJSON(Map<String, dynamic> json) {
    return Item(
      name: json['name'],
      quantity: json['quantity'],
      expiryDate: DateTime.parse(json['expiryDate']),
      warningDate: DateTime.parse(json['warningDate']),
      imageUrl: json['imageUrl'],
      unit: json['unit'],
      tags: (json['tags'] as List?)?.map((tag) => Tag.fromJSON(tag)).toList() ??
          <Tag>[],
    );
  }
}

class Tag extends Dropdownable {
  final String uid;
  Tag({required this.uid, required super.name, required super.color});

  factory Tag.fromJSON(Map<String, dynamic> json) {
    return Tag(
      uid: json['uid'],
      name: json['name'],
      color: Color(int.parse("0X" + json['color'])),
    );
  }

  @override
  bool operator ==(Object other) {
    return name == (other as Tag).name;
  }

  @override
  int get hashCode => name.hashCode ^ color.hashCode;
}
