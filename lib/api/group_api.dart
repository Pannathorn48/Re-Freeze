import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile_project/api/user_api.dart';
import 'package:mobile_project/exceptions/app_exception.dart';
import 'package:mobile_project/exceptions/group_exception.dart';
import 'package:mobile_project/exceptions/user_exception.dart';
import 'package:mobile_project/models/group_model.dart';

/// API for managing groups in the system
class GroupApi {
  final UserApi _userApi;
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  GroupApi({
    UserApi? userApi,
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _userApi = userApi ?? UserApi(),
        _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  CollectionReference get _groups => _firestore.collection('groups');

  CollectionReference get _groupMembers =>
      _firestore.collection('group_members');

  /// Create a new group with the current user as owner
  Future<Group> createGroup({
    required String name,
    required String color,
    required String description,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw UserException("No user logged in", UserException.getUserException);
    }

    final user = await _userApi.getUser(currentUser.uid);
    if (user == null) {
      throw UserException(
          "User profile not found", UserException.getUserException);
    }

    try {
      // Create group document
      final docRef = _groups.doc();
      final groupData = {
        'uid': docRef.id,
        'name': name,
        'color': color,
        'creatorName': user.displayName ?? "Unknown",
        'creatorId': currentUser.uid,
        'description': description,
        'createdAt': FieldValue.serverTimestamp(),
        'memberCount': 1,
      };

      await docRef.set(groupData);

      // Add creator as owner in group_members
      await _groupMembers.add({
        'groupId': docRef.id,
        'userId': user.uid,
        'role': 'owner',
        'joinedAt': FieldValue.serverTimestamp(),
      });

      // Create Group object
      final colorObj = Color(int.parse("0X$color"));
      final group = Group(
        uid: docRef.id,
        name: name,
        color: colorObj,
        creatorName: user.displayName ?? "Unknown",
        description: description,
      );

      return group;
    } catch (e) {
      throw AppException(
          'Failed to create group: $e', GroupException.createGroupException);
    }
  }

  /// Get all groups the user is a member of
  Future<List<Group>> getUserGroups() async {
    final user = _auth.currentUser;
    if (user == null) return [];

    try {
      // Find all groups the user is a member of
      final membershipQuery =
          await _groupMembers.where('userId', isEqualTo: user.uid).get();

      // Extract group IDs
      final groupIds = membershipQuery.docs
          .map((doc) =>
              (doc.data() as Map<String, dynamic>)['groupId'] as String)
          .toList();

      if (groupIds.isEmpty) return [];

      final groups = <Group>[];

      // Split into chunks of 10 for whereIn queries
      final chunks = _chunkList(groupIds, 10);

      for (final chunk in chunks) {
        final querySnapshot =
            await _groups.where(FieldPath.documentId, whereIn: chunk).get();

        for (final doc in querySnapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          final colorData = data['color'];
          final color = Color(int.parse("0X$colorData"));

          final group = Group(
            uid: doc.id,
            name: data['name'],
            color: color,
            creatorName: data['creatorName'],
            description: data['description'],
          );

          groups.add(group);
        }
      }

      return groups;
    } catch (e) {
      throw AppException('Failed to get user groups: $e',
          GroupException.getUserGroupsException);
    }
  }

  /// Get a single group by ID
  Future<Group?> getGroupById(String groupId) async {
    try {
      // Fetch from Firestore
      final doc = await _groups.doc(groupId).get();
      if (!doc.exists) {
        return null;
      }

      final data = doc.data() as Map<String, dynamic>;
      final colorData = data['color'];
      final color = Color(int.parse("0X$colorData"));

      final group = Group(
        uid: doc.id,
        name: data['name'],
        color: color,
        creatorName: data['creatorName'],
        description: data['description'],
      );

      return group;
    } catch (e) {
      throw AppException(
          'Failed to get group: $e', GroupException.getGroupException);
    }
  }

  /// Add a user to a group
  Future<void> addUserToGroup(String groupId, String userId,
      {String role = 'member'}) async {
    try {
      // Check if user is already a member
      final existingMember = await _groupMembers
          .where('groupId', isEqualTo: groupId)
          .where('userId', isEqualTo: userId)
          .get();

      if (existingMember.docs.isNotEmpty) {
        // User is already a member, nothing to do
        return;
      }

      // Add to group_members
      await _groupMembers.add({
        'groupId': groupId,
        'userId': userId,
        'role': role,
        'joinedAt': FieldValue.serverTimestamp(),
      });

      // Update member count
      await _groups
          .doc(groupId)
          .update({'memberCount': FieldValue.increment(1)});
    } catch (e) {
      throw AppException('Failed to add user to group: $e',
          GroupException.addUserToGroupException);
    }
  }

  /// Remove a user from a group
  Future<void> removeUserFromGroup(String groupId, String userId) async {
    try {
      // Find the membership document
      final membershipQuery = await _groupMembers
          .where('groupId', isEqualTo: groupId)
          .where('userId', isEqualTo: userId)
          .get();

      if (membershipQuery.docs.isEmpty) {
        // User is not a member, nothing to do
        return;
      }

      // Check if user is the owner
      final memberData =
          membershipQuery.docs.first.data() as Map<String, dynamic>;
      if (memberData['role'] == 'owner') {
        // Cannot remove the owner
        throw AppException('Cannot remove the owner from the group',
            GroupException.removeOwnerException);
      }

      // Delete membership
      await _groupMembers.doc(membershipQuery.docs.first.id).delete();

      // Update member count
      await _groups
          .doc(groupId)
          .update({'memberCount': FieldValue.increment(-1)});
    } catch (e) {
      throw AppException('Failed to remove user from group: $e',
          GroupException.removeUserFromGroupException);
    }
  }

  /// Get all members of a group with their roles
  Future<List<Map<String, dynamic>>> getGroupMembers(String groupId) async {
    try {
      final membersQuery =
          await _groupMembers.where('groupId', isEqualTo: groupId).get();

      final membersList = <Map<String, dynamic>>[];

      for (final doc in membersQuery.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final userId = data['userId'] as String;

        // Get user details
        final user = await _userApi.getUser(userId);
        if (user != null) {
          membersList.add({
            'user': user,
            'role': data['role'],
            'joinedAt': data['joinedAt'],
          });
        }
      }

      return membersList;
    } catch (e) {
      throw AppException('Failed to get group members: $e',
          GroupException.getGroupMembersException);
    }
  }

  /// Delete a group (only owner can do this)
  Future<void> deleteGroup(String groupId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw UserException("No user logged in", UserException.getUserException);
    }

    try {
      // Check if user is the owner
      final membershipQuery = await _groupMembers
          .where('groupId', isEqualTo: groupId)
          .where('userId', isEqualTo: currentUser.uid)
          .where('role', isEqualTo: 'owner')
          .get();

      if (membershipQuery.docs.isEmpty) {
        throw AppException('Only the owner can delete the group',
            GroupException.unauthorizedDeleteException);
      }

      // Delete all memberships
      final allMemberships =
          await _groupMembers.where('groupId', isEqualTo: groupId).get();

      final batch = _firestore.batch();
      for (final doc in allMemberships.docs) {
        batch.delete(doc.reference);
      }

      // Delete the group
      batch.delete(_groups.doc(groupId));
      await batch.commit();
    } catch (e) {
      throw AppException(
          'Failed to delete group: $e', GroupException.deleteGroupException);
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
}
