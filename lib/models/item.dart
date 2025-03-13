import 'dart:ui';

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
      tags: (json['tags'] as List).map((tag) => Tag.fromJson(tag)).toList(),
    );
  }
}

class Tag {
  String name;
  Color color;
  Tag({required this.name, required this.color});

  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      name: json['name'],
      color: Color(json['color']),
    );
  }
}
