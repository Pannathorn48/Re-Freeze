import 'package:mobile_project/models/dropdownable.dart';

class Group extends Dropdownable {
  final String creatorName;
  final String description;
  Group(
      {required super.name,
      required super.color,
      required this.creatorName,
      required this.description});
}
