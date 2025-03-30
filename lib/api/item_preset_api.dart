import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:mobile_project/exceptions/user_exception.dart';
import 'package:mobile_project/models/item_model.dart';
import 'package:mobile_project/models/item_preset_model.dart';

class ItemPresetApi {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  ItemPresetApi({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  CollectionReference get _itemPresets => _firestore.collection('item_presets');

  Future<void> createItemPreset({
    required String name,
    required String imageUrl,
    required String unit,
    required int quantity,
    required DateTime expiryDate,
    required DateTime warningDate,
    required List<Tag> tags,
  }) async {
    try {
      // Get current user
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw UserException(
            "No user logged in", UserException.getUserException);
      }

      final docRef = _itemPresets.doc();

      // Convert tags to format for storage
      final List<Map<String, dynamic>> tagData = tags
          .map((tag) => {
                'uid': tag.uid,
                'name': tag.name,
                'color': tag.color.toHexString(),
              })
          .toList();

      await docRef.set({
        'uid': docRef.id,
        'name': name,
        'imageUrl': imageUrl,
        'unit': unit,
        'quantity': quantity,
        'expiryDate': Timestamp.fromDate(expiryDate),
        'warningDate': Timestamp.fromDate(warningDate),
        'tags': tagData,
        'createdBy': currentUser.uid,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to create item preset: $e');
    }
  }

  // Get all available presets
  Future<List<ItemPreset>> getAllPresets() async {
    try {
      final snapshot = await _itemPresets.get();
      return snapshot.docs
          .map((doc) => ItemPreset.fromJSON(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch item presets: $e');
    }
  }

  // Get presets created by the current user
  Future<List<ItemPreset>> getUserPresets() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw UserException(
            "No user logged in", UserException.getUserException);
      }

      final snapshot = await _itemPresets
          .where('createdBy', isEqualTo: currentUser.uid)
          .get();

      return snapshot.docs
          .map((doc) => ItemPreset.fromJSON(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch user presets: $e');
    }
  }

  // Get a specific preset by ID
  Future<ItemPreset?> getPresetById(String presetId) async {
    try {
      final doc = await _itemPresets.doc(presetId).get();
      if (!doc.exists) {
        return null;
      }

      return ItemPreset.fromJSON(doc.data() as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to fetch item preset: $e');
    }
  }

  // Create a preset from an existing item
  Future<void> createPresetFromItem(Item item, {String? customName}) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw UserException(
            "No user logged in", UserException.getUserException);
      }

      // Create a new preset using the item's data
      await createItemPreset(
        name: customName ?? item.name,
        imageUrl: item.imageUrl,
        unit: item.unit,
        quantity: item.quantity,
        expiryDate: item.expiryDate,
        warningDate: item.warningDate,
        tags: item.tags,
      );
    } catch (e) {
      throw Exception('Failed to create preset from item: $e');
    }
  }
}
