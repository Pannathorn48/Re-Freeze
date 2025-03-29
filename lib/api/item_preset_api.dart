import 'package:cloud_firestore/cloud_firestore.dart';

class ItemPresetApi {
  final CollectionReference _itemPresets =
      FirebaseFirestore.instance.collection('item-presets');

  Future<void> createItemPreset(
      {required String name,
      required String imageUrl,
      required String unit,
      required int quantity,
      required DateTime expiryDate,
      required DateTime warningDate,
      required List<DocumentReference> tags}) async {
    try {
      final docRef = _itemPresets.doc();
      await docRef.set({
        'uid': docRef.id,
        'name': name,
        'imageUrl': imageUrl,
        'unit': unit,
        'quantity': quantity,
        'expiryDate': Timestamp.fromDate(expiryDate),
        'warningDate': Timestamp.fromDate(warningDate),
        'tags': tags
      });
    } catch (e) {
      throw Exception('Failed to create item preset: $e');
    }
  }
}
