import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:mobile_project/exceptions/tag_exception.dart';
import 'package:mobile_project/models/item_model.dart';

class TagApi {
  final CollectionReference _tags =
      FirebaseFirestore.instance.collection('tags');

  Future<void> createTag({required String name, required Color color}) async {
    try {
      final docRef = _tags.doc();
      await docRef.set({
        'uid': docRef.id,
        'name': name,
        'color': color.toHexString(),
      });
    } catch (e) {
      throw TagException(
          'Failed to create tag: $e', TagException.createTagException);
    }
  }

  Future<List<Tag>> getTags() async {
    try {
      final snapshot = await _tags.get();
      return snapshot.docs
          .map((doc) => Tag.fromJSON(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw TagException(
          'Failed to fetch tags: $e', TagException.getTagException);
    }
  }
}
