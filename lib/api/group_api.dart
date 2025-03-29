import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile_project/api/user_api.dart';
import 'package:mobile_project/exceptions/app_exception.dart';
import 'package:mobile_project/exceptions/group_exception.dart';
import 'package:mobile_project/exceptions/user_exception.dart';
import 'package:mobile_project/models/group_model.dart';

class GroupApi {
  final UserApi _userApi = UserApi();
  final CollectionReference _groups =
      FirebaseFirestore.instance.collection('groups');

  Future<void> createGroup({
    required String name,
    required String color,
    required String description,
  }) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final user = await _userApi.getUser(currentUser?.uid);
    try {
      final docRef = _groups.doc();
      await docRef.set({
        'uid': docRef.id,
        'name': name,
        'color': color,
        'creatorName': user?.displayName ?? "Unknown",
        'description': description,
      });

      await FirebaseFirestore.instance.collection('group_members').add({
        'groupId': docRef.id,
        'userId': user!.uid,
        'role': 'owner',
        'joinedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw AppException(
          'Failed to create group: $e', GroupException.createGroupException);
    }
  }

  Future<List<Group>> getUserGroups() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    // Find all groups the user is a member of
    final membershipQuery = await FirebaseFirestore.instance
        .collection('group_members')
        .where('userId', isEqualTo: user.uid)
        .get();

    // Extract group IDs
    final groupIds = membershipQuery.docs
        .map((doc) => doc.data()['groupId'] as String)
        .toList();

    // Fetch group details
    final groups = <Group>[];
    for (final groupId in groupIds) {
      final groupDoc = await FirebaseFirestore.instance
          .collection('groups')
          .doc(groupId)
          .get();

      if (groupDoc.exists) {
        final data = groupDoc.data()!;
        final colorData = data['color'];
        final color = Color(int.parse("0X$colorData"));

        groups.add(Group(
          name: data['name'],
          color: color,
          creatorName: data['creatorName'],
          description: data['description'],
        ));
      }
    }

    return groups;
  }
}
