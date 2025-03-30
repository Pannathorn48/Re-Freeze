import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:mobile_project/exceptions/app_exception.dart';
import 'package:mobile_project/exceptions/item_exception.dart';
import 'package:mobile_project/exceptions/user_exception.dart';
import 'package:mobile_project/models/item_model.dart';

/// API for managing items in refrigerators
class ItemApi {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  ItemApi({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  CollectionReference get _items => _firestore.collection('items');
  CollectionReference get _itemPresets => _firestore.collection('item_presets');

  /// Get items for a specific refrigerator
  Stream<List<Item>> getItemsForRefrigerator(String refrigeratorId) {
    return _items
        .where('refrigeratorId', isEqualTo: refrigeratorId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Item.fromJSON(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  /// Get item by ID
  Future<Item?> getItemById(String itemId) async {
    try {
      final doc = await _items.doc(itemId).get();
      if (!doc.exists) {
        return null;
      }

      return Item.fromJSON(doc.data() as Map<String, dynamic>);
    } catch (e) {
      throw AppException(
          'Error fetching item: $e', ItemException.getItemException);
    }
  }

  /// Create a new item from scratch
  Future<Item> createItem({
    required String refrigeratorId,
    required String name,
    required int quantity,
    required DateTime expiryDate,
    required DateTime warningDate,
    required String imageUrl,
    required String unit,
    required List<Tag> tags,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw UserException(
            "No user logged in", UserException.getUserException);
      }

      // Create a new document reference
      final docRef = _items.doc();

      // Convert tags to format for storage
      final List<Map<String, dynamic>> tagData = tags
          .map((tag) => {'uid': tag.uid, 'name': tag.name, 'color': tag.color})
          .toList();

      // Prepare data to save
      final itemData = {
        'uid': docRef.id,
        'refrigeratorId': refrigeratorId,
        'name': name,
        'quantity': quantity,
        'expiryDate': Timestamp.fromDate(expiryDate),
        'warningDate': Timestamp.fromDate(warningDate),
        'imageUrl': imageUrl,
        'unit': unit,
        'tags': tagData,
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': currentUser.uid,
      };

      // Save to Firestore
      await docRef.set(itemData);

      // Create and return the item object
      return Item(
        name: name,
        quantity: quantity,
        expiryDate: expiryDate,
        warningDate: warningDate,
        imageUrl: imageUrl,
        unit: unit,
        tags: tags,
      );
    } catch (e) {
      throw AppException(
          'Error creating item: $e', ItemException.createItemException);
    }
  }

  /// Create a new item from a preset
  Future<Item> createItemFromPreset({
    required String refrigeratorId,
    required String presetId,
    DateTime? customExpiryDate,
    int? customQuantity,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw UserException(
            "No user logged in", UserException.getUserException);
      }

      // Get the preset from the item_presets collection, not from items
      final presetDoc =
          await _firestore.collection('item_presets').doc(presetId).get();
      if (!presetDoc.exists) {
        throw AppException(
            'Item preset not found', ItemException.presetNotFoundException);
      }

      final presetData = presetDoc.data() as Map<String, dynamic>;
      print('Retrieved preset: ${presetData['name']}');

      // Create a new document reference
      final docRef = _items.doc();

      // Parse tags directly from the preset document
      List<Tag> tags = [];
      if (presetData['tags'] != null && presetData['tags'] is List) {
        final tagList = presetData['tags'] as List<dynamic>;
        print('Found ${tagList.length} tags in preset data');

        for (var tagData in tagList) {
          if (tagData is Map<String, dynamic>) {
            try {
              final tag = Tag.fromJSON(tagData);
              print(
                  'Parsed tag: ${tag.name} with color ${tag.color.toHexString()}');
              tags.add(tag);
            } catch (e) {
              print('Error parsing tag: $e');
            }
          }
        }
      } else {
        print('No tags found in preset data');
      }

      // Convert tags to format for storage
      final List<Map<String, dynamic>> tagData = tags
          .map((tag) => {
                'uid': tag.uid,
                'name': tag.name,
                'color': tag.color.toHexString().replaceAll('#', ''),
              })
          .toList();

      print('Converted ${tagData.length} tags for storage');

      // Use custom values or defaults from preset
      final expiryDate =
          customExpiryDate ?? (presetData['expiryDate'] as Timestamp).toDate();
      final quantity = customQuantity ?? presetData['quantity'] as int;

      // Prepare data to save
      final itemData = {
        'uid': docRef.id,
        'refrigeratorId': refrigeratorId,
        'presetId': presetId, // Reference to the preset
        'name': presetData['name'],
        'quantity': quantity,
        'expiryDate': Timestamp.fromDate(expiryDate),
        'warningDate': presetData['warningDate'] is Timestamp
            ? (presetData['warningDate'] as Timestamp).toDate()
            : DateTime.now().add(const Duration(days: 1)),
        'imageUrl': presetData['imageUrl'],
        'unit': presetData['unit'],
        'tags': tagData,
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': currentUser.uid,
      };

      // Save to Firestore
      await docRef.set(itemData);
      print('Item created with ${tagData.length} tags');

      // Create and return the item object
      return Item(
        name: presetData['name'],
        quantity: quantity,
        expiryDate: expiryDate,
        warningDate: itemData['warningDate'] is DateTime
            ? itemData['warningDate'] as DateTime
            : DateTime.now().add(const Duration(days: 1)),
        imageUrl: presetData['imageUrl'],
        unit: presetData['unit'],
        tags: tags,
      );
    } catch (e) {
      print('Error creating item from preset: $e');
      throw AppException('Error creating item from preset: $e',
          ItemException.createItemFromPresetException);
    }
  }

  /// Update an existing item
  Future<void> updateItem({
    required String itemId,
    String? name,
    int? quantity,
    DateTime? expiryDate,
    DateTime? warningDate,
    String? imageUrl,
    String? unit,
    List<Tag>? tags,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw UserException(
            "No user logged in", UserException.getUserException);
      }

      // Prepare update data
      final Map<String, dynamic> updateData = {};

      if (name != null) updateData['name'] = name;
      if (quantity != null) updateData['quantity'] = quantity;
      if (expiryDate != null) {
        updateData['expiryDate'] = Timestamp.fromDate(expiryDate);
      }
      if (warningDate != null) {
        updateData['warningDate'] = Timestamp.fromDate(warningDate);
      }
      if (imageUrl != null) updateData['imageUrl'] = imageUrl;
      if (unit != null) updateData['unit'] = unit;

      if (tags != null) {
        final List<Map<String, dynamic>> tagData = tags
            .map((tag) => {
                  'uid': tag.uid,
                  'name': tag.name,
                  'color': tag.color.toHexString(),
                })
            .toList();
        updateData['tags'] = tagData;
      }

      updateData['updatedAt'] = FieldValue.serverTimestamp();
      updateData['updatedBy'] = currentUser.uid;

      // Update document
      await _items.doc(itemId).update(updateData);
    } catch (e) {
      throw AppException(
          'Error updating item: $e', ItemException.updateItemException);
    }
  }

  /// Delete an item
  Future<void> deleteItem(String itemId) async {
    try {
      await _items.doc(itemId).delete();
    } catch (e) {
      throw AppException(
          'Error deleting item: $e', ItemException.deleteItemException);
    }
  }

  /// Update item quantity
  Future<void> updateItemQuantity(String itemId, int newQuantity) async {
    try {
      await _items.doc(itemId).update({
        'quantity': newQuantity,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw AppException('Error updating item quantity: $e',
          ItemException.updateItemException);
    }
  }

  /// Get all items expiring soon for a user
  Future<List<Item>> getExpiringItems(String userId,
      {int daysThreshold = 3}) async {
    try {
      // Get all refrigerators this user has access to
      final refrigeratorsSnapshot = await _firestore
          .collection('refrigerators')
          .where('users', arrayContains: userId)
          .get();

      final refrigeratorIds =
          refrigeratorsSnapshot.docs.map((doc) => doc.id).toList();

      // Calculate the threshold date
      final thresholdDate = DateTime.now().add(Duration(days: daysThreshold));

      // Query items from those refrigerators that expire soon
      final expiringItemsQuery = await _items
          .where('refrigeratorId', whereIn: refrigeratorIds)
          .where('expiryDate', isLessThan: Timestamp.fromDate(thresholdDate))
          .get();

      // Convert to Item objects
      return expiringItemsQuery.docs
          .map((doc) => Item.fromJSON(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw AppException('Error getting expiring items: $e',
          ItemException.getExpiringItemsException);
    }
  }
}
