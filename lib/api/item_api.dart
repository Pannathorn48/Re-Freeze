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
          .map((tag) => {
                'uid': tag.uid,
                'name': tag.name,
                'color': tag.color.toHexString()
              })
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

      // Create a new document reference
      final docRef = _items.doc();

      // Parse tags directly from the preset document
      List<Tag> tags = [];
      if (presetData['tags'] != null && presetData['tags'] is List) {
        final tagList = presetData['tags'] as List<dynamic>;
        for (var tagData in tagList) {
          if (tagData is Map<String, dynamic>) {
            try {
              final tag = Tag.fromJSON(tagData);
              tags.add(tag);
            } catch (e) {}
          }
        }
      } else {}

      // Convert tags to format for storage
      final List<Map<String, dynamic>> tagData = tags
          .map((tag) => {
                'uid': tag.uid,
                'name': tag.name,
                'color': tag.color.toHexString(),
              })
          .toList();

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
  // Add these methods to your ItemApi class in item_api.dart

  /// Get all items that have reached their warning date (today equals warning date)
  Future<List<Item>> getWarningItems(String userId) async {
    try {
      // Get all refrigerators this user has access to
      final refrigeratorsSnapshot = await _firestore
          .collection('refrigerators')
          .where('users', arrayContains: userId)
          .get();

      final refrigeratorIds =
          refrigeratorsSnapshot.docs.map((doc) => doc.id).toList();

      if (refrigeratorIds.isEmpty) return [];

      // Calculate today's date at midnight for comparison
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

      final allWarningItems = <Item>[];

      // Split refrigeratorIds into batches if needed (Firestore limit)
      final batches = _chunkList(refrigeratorIds, 10);

      for (final batch in batches) {
        // Query all items for these refrigerators
        final itemsQuery =
            await _items.where('refrigeratorId', whereIn: batch).get();

        // Filter locally for warning date
        for (final doc in itemsQuery.docs) {
          final data = doc.data() as Map<String, dynamic>;
          if (data['warningDate'] != null) {
            final warningDate = (data['warningDate'] as Timestamp).toDate();
            // Check if warning date is today
            if (warningDate
                    .isAfter(startOfDay.subtract(const Duration(minutes: 1))) &&
                warningDate
                    .isBefore(endOfDay.add(const Duration(minutes: 1)))) {
              allWarningItems.add(Item.fromJSON(data));
            }
          }
        }
      }

      return allWarningItems;
    } catch (e) {
      throw AppException('Error getting warning items: $e',
          ItemException.getWarningItemsException);
    }
  }

  /// Get all items that have reached or passed their expiry date
  Future<List<Item>> getExpiredItems(String userId) async {
    try {
      // Get all refrigerators this user has access to
      final refrigeratorsSnapshot = await _firestore
          .collection('refrigerators')
          .where('users', arrayContains: userId)
          .get();

      final refrigeratorIds =
          refrigeratorsSnapshot.docs.map((doc) => doc.id).toList();

      if (refrigeratorIds.isEmpty) return [];

      // Calculate today's date at midnight for comparison
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);

      final allExpiredItems = <Item>[];

      // Split refrigeratorIds into batches if needed (Firestore limit)
      final batches = _chunkList(refrigeratorIds, 10);

      for (final batch in batches) {
        // Query all items for these refrigerators
        final itemsQuery =
            await _items.where('refrigeratorId', whereIn: batch).get();

        // Filter locally for expiry date
        for (final doc in itemsQuery.docs) {
          final data = doc.data() as Map<String, dynamic>;
          if (data['expiryDate'] != null) {
            final expiryDate = (data['expiryDate'] as Timestamp).toDate();
            // Check if expiry date is today or earlier
            if (expiryDate
                .isBefore(startOfDay.add(const Duration(minutes: 1)))) {
              allExpiredItems.add(Item.fromJSON(data));
            }
          }
        }
      }

      return allExpiredItems;
    } catch (e) {
      throw AppException('Error getting expired items: $e',
          ItemException.getExpiredItemsException);
    }
  }

  /// Helper method to chunk list for batch processing
  List<List<T>> _chunkList<T>(List<T> list, int chunkSize) {
    final chunks = <List<T>>[];
    for (var i = 0; i < list.length; i += chunkSize) {
      chunks.add(list.sublist(
          i, i + chunkSize <= list.length ? i + chunkSize : list.length));
    }
    return chunks;
  }

  /// Get refrigerators with warning or expired items
  Future<Map<String, Map<String, List<Item>>>>
      getRefrigeratorsWithNotifications(String userId) async {
    try {
      final warningItems = await getWarningItems(userId);
      final expiredItems = await getExpiredItems(userId);

      // Group items by refrigerator
      final Map<String, Map<String, List<Item>>> result = {};

      // Process warning items
      for (final item in warningItems) {
        if (!result.containsKey(item.refrigeratorId)) {
          result[item.refrigeratorId] = {
            'warning': [],
            'expired': [],
          };
        }
        result[item.refrigeratorId]!['warning']!.add(item);
      }

      // Process expired items
      for (final item in expiredItems) {
        if (!result.containsKey(item.refrigeratorId)) {
          result[item.refrigeratorId] = {
            'warning': [],
            'expired': [],
          };
        }
        result[item.refrigeratorId]!['expired']!.add(item);
      }

      return result;
    } catch (e) {
      throw AppException('Error getting refrigerators with notifications: $e',
          ItemException.getNotificationsException);
    }
  }

  Future<List<Item>> getLowQuantityItems(String userId,
      {int minQuantity = 5}) async {
    try {
      // Get all refrigerators this user has access to
      final refrigeratorsSnapshot = await _firestore
          .collection('refrigerators')
          .where('users', arrayContains: userId)
          .get();

      final refrigeratorIds =
          refrigeratorsSnapshot.docs.map((doc) => doc.id).toList();

      if (refrigeratorIds.isEmpty) return [];

      final lowQuantityItems = <Item>[];

      // Split refrigeratorIds into batches if needed (Firestore limit)
      final batches = _chunkList(refrigeratorIds, 10);

      for (final batch in batches) {
        // Query all items for these refrigerators
        final itemsQuery =
            await _items.where('refrigeratorId', whereIn: batch).get();

        // Filter locally for low quantity
        for (final doc in itemsQuery.docs) {
          final data = doc.data() as Map<String, dynamic>;
          if (data['quantity'] != null && data['quantity'] <= minQuantity) {
            lowQuantityItems.add(Item.fromJSON(data));
          }
        }
      }

      return lowQuantityItems;
    } catch (e) {
      throw AppException('Error getting low quantity items: $e',
          ItemException.getLowQuantityItemsException);
    }
  }
}
