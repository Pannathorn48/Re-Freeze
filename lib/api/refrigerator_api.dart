import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile_project/api/user_api.dart';
import 'package:mobile_project/exceptions/app_exception.dart';
import 'package:mobile_project/exceptions/refrigerator_exception.dart';
import 'package:mobile_project/exceptions/user_exception.dart';
import 'package:mobile_project/models/refrigerators_model.dart';
import 'package:mobile_project/models/user.dart';

/// API for managing refrigerators in the system
class RefrigeratorApi {
  final UserApi _userApi;
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final Map<String, Refrigerator> _cache = {};

  RefrigeratorApi({
    UserApi? userApi,
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _userApi = userApi ?? UserApi(),
        _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  CollectionReference get _refrigerators =>
      _firestore.collection('refrigerators');

  /// Get a stream of refrigerators accessible to the specified user
  Stream<QuerySnapshot> getRefrigeratorsFromUserId(String uid) {
    return _refrigerators.where('users', arrayContains: uid).snapshots();
  }

  /// Get refrigerator by ID, with optional caching
  Future<Refrigerator?> getRefrigeratorById(String id,
      {bool useCache = true}) async {
    // Try to get from cache first if enabled
    if (useCache && _cache.containsKey(id)) {
      return _cache[id];
    }

    try {
      final doc = await _refrigerators.doc(id).get();
      if (!doc.exists) {
        return null;
      }

      final refrigerator =
          Refrigerator.fromJSON(doc.data() as Map<String, dynamic>);

      // Store in cache for future use
      _cache[id] = refrigerator;
      return refrigerator;
    } catch (e) {
      throw AppException('Error fetching refrigerator: $e',
          RefrigeratorException.getRefrigeratorException);
    }
  }

  /// Get list of refrigerators favorited by a user
  Future<List<Refrigerator>> getFavoriteRefrigerators(String uid) async {
    try {
      final PlatformUser? user = await _userApi.getUser(uid);
      if (user == null) {
        throw UserException("User not found", UserException.getUserException);
      }

      final List<Refrigerator> favoriteRefrigerators = [];
      final List<String> missingRefIds = [];

      // First check cache for each refrigerator
      for (var ref in user.refrigeratorsArray) {
        if (_cache.containsKey(ref.id)) {
          favoriteRefrigerators.add(_cache[ref.id]!);
        } else {
          missingRefIds.add(ref.id);
        }
      }

      // For missing refrigerators, batch query them
      if (missingRefIds.isNotEmpty) {
        final chunkedIds =
            _chunkList(missingRefIds, 10); // Firestore limitations

        for (final chunk in chunkedIds) {
          final snapshot = await _refrigerators
              .where(FieldPath.documentId, whereIn: chunk)
              .get();

          for (final doc in snapshot.docs) {
            final refrigerator =
                Refrigerator.fromJSON(doc.data() as Map<String, dynamic>);
            favoriteRefrigerators.add(refrigerator);
            _cache[refrigerator.uid] = refrigerator; // Update cache
          }
        }
      }

      return favoriteRefrigerators;
    } catch (e) {
      throw AppException('Error fetching favorite refrigerators: $e',
          RefrigeratorException.getFavoriteRefrigeratorsException);
    }
  }

  /// Create a new refrigerator
  Future<Refrigerator> addRefrigerators({
    required String name,
    required bool isPublic,
    String? groupId,
    String? imageUrl,
  }) async {
    try {
      // Get current user
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw UserException(
            "No user logged in", UserException.getUserException);
      }

      // Create a new document reference
      final docRef = _refrigerators.doc();

      // Prepare data to save
      final refrigeratorData = {
        'uid': docRef.id,
        'name': name,
        'isPrivate': !isPublic,
        'imageUrl': imageUrl,
        'groupId': groupId ?? "",
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': currentUser.uid,
        'ownerId': currentUser.uid,
        'users': [currentUser.uid], // Initialize with current user
      };

      // Save to Firestore
      await docRef.set(refrigeratorData);

      // Create the refrigerator object
      final refrigerator = Refrigerator(
        uid: docRef.id,
        name: name,
        groupId: groupId ?? "",
        imageUrl: imageUrl,
        isPrivate: !isPublic,
      );

      // Cache the new refrigerator
      _cache[refrigerator.uid] = refrigerator;

      return refrigerator;
    } catch (e) {
      throw AppException('Error creating refrigerator: $e',
          RefrigeratorException.createRefrigeratorException);
    }
  }

  /// Add refrigerator to user's favorites
  Future<void> addToFavorites(String refrigeratorId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw UserException(
            "No user logged in", UserException.getUserException);
      }

      // Get refrigerator to add
      final refrigerator = await getRefrigeratorById(refrigeratorId);
      if (refrigerator == null) {
        throw AppException('Refrigerator not found',
            RefrigeratorException.getRefrigeratorException);
      }

      // Add to user's favorites
      await _firestore.collection('users').doc(currentUser.uid).update({
        'refrigeratorsArray': FieldValue.arrayUnion([
          {'id': refrigeratorId, 'name': refrigerator.name}
        ])
      });
    } catch (e) {
      throw AppException('Error adding refrigerator to favorites: $e',
          RefrigeratorException.addToFavoritesException);
    }
  }

  /// Remove refrigerator from user's favorites
  Future<void> removeFromFavorites(String refrigeratorId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw UserException(
            "No user logged in", UserException.getUserException);
      }

      // Get refrigerator name
      final refrigerator = await getRefrigeratorById(refrigeratorId);
      if (refrigerator == null) {
        throw AppException('Refrigerator not found',
            RefrigeratorException.getRefrigeratorException);
      }

      // Remove from user's favorites
      await _firestore.collection('users').doc(currentUser.uid).update({
        'refrigeratorsArray': FieldValue.arrayRemove([
          {'id': refrigeratorId, 'name': refrigerator.name}
        ])
      });
    } catch (e) {
      throw AppException('Error removing refrigerator from favorites: $e',
          RefrigeratorException.removeFromFavoritesException);
    }
  }

  /// Delete a refrigerator
  Future<void> deleteRefrigerator(String refrigeratorId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw UserException(
            "No user logged in", UserException.getUserException);
      }

      // Check if user is the owner
      final refrigerator =
          await getRefrigeratorById(refrigeratorId, useCache: false);
      if (refrigerator == null) {
        throw AppException('Refrigerator not found',
            RefrigeratorException.getRefrigeratorException);
      }

      // Delete document
      await _refrigerators.doc(refrigeratorId).delete();

      // Remove from cache
      _cache.remove(refrigeratorId);
    } catch (e) {
      throw AppException('Error deleting refrigerator: $e',
          RefrigeratorException.deleteRefrigeratorException);
    }
  }

  /// Helper method to chunk a list for batch operations
  List<List<T>> _chunkList<T>(List<T> list, int chunkSize) {
    final chunks = <List<T>>[];
    for (var i = 0; i < list.length; i += chunkSize) {
      chunks.add(list.sublist(
          i, i + chunkSize <= list.length ? i + chunkSize : list.length));
    }
    return chunks;
  }

  /// Clear the cache
  void clearCache() {
    _cache.clear();
  }
}
