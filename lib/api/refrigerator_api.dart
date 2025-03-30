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

  /// Get refrigerator by ID
  Future<Refrigerator?> getRefrigeratorById(String id) async {
    try {
      final doc = await _refrigerators.doc(id).get();
      if (!doc.exists) {
        return null;
      }

      return Refrigerator.fromJSON(doc.data() as Map<String, dynamic>);
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

      // If user has no favorites, return empty list
      if (user.refrigeratorsArray.isEmpty) {
        return [];
      }

      final List<Refrigerator> favoriteRefrigerators = [];

      // Handle different types of refrigerator references
      for (var ref in user.refrigeratorsArray) {
        String? refrigeratorId;

        if (ref is DocumentReference) {
          // It's a document reference
          refrigeratorId = ref.id;
        } else if (ref is Map<String, dynamic> && ref.containsKey('id')) {
          // It's a map with an id field
          refrigeratorId = ref['id'] as String;
        }

        if (refrigeratorId != null) {
          final doc = await _refrigerators.doc(refrigeratorId).get();
          if (doc.exists) {
            favoriteRefrigerators
                .add(Refrigerator.fromJSON(doc.data() as Map<String, dynamic>));
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

      // Create and return the refrigerator object
      return Refrigerator(
        uid: docRef.id,
        name: name,
        groupId: groupId ?? "",
        imageUrl: imageUrl,
        isPrivate: !isPublic,
      );
    } catch (e) {
      throw AppException('Error creating refrigerator: $e',
          RefrigeratorException.createRefrigeratorException);
    }
  }

  /// Update an existing refrigerator
  Future<void> updateRefrigerator({
    required String refrigeratorId,
    required String name,
    required bool isPublic,
    String? imageUrl,
    String? groupId,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw UserException(
            "No user logged in", UserException.getUserException);
      }

      // Prepare data to update
      final Map<String, dynamic> data = {
        'name': name,
        'isPrivate': !isPublic, // Note: inverting isPublic to match the schema
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Add optional fields if they're provided
      if (imageUrl != null) {
        data['imageUrl'] = imageUrl;
      }

      if (isPublic && groupId != null) {
        data['groupId'] = groupId;
      } else {
        data['groupId'] = "";
      }

      await _refrigerators.doc(refrigeratorId).update(data);
    } catch (e) {
      throw AppException('Error updating refrigerator: $e',
          RefrigeratorException.updateRefrigeratorException);
    }
  }

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

      // Check if refrigerator exists
      final refrigerator = await getRefrigeratorById(refrigeratorId);
      if (refrigerator == null) {
        throw AppException('Refrigerator not found',
            RefrigeratorException.getRefrigeratorException);
      }

      // Delete document
      await _refrigerators.doc(refrigeratorId).delete();
    } catch (e) {
      throw AppException('Error deleting refrigerator: $e',
          RefrigeratorException.deleteRefrigeratorException);
    }
  }
}
