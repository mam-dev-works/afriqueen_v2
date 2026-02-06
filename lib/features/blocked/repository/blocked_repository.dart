import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';

import '../model/blocked_model.dart';

class BlockedRepository {
  final FirebaseFirestore _firebaseFirestore;

  BlockedRepository({FirebaseFirestore? firestore})
      : _firebaseFirestore = firestore ?? FirebaseFirestore.instance;

  //--------------------------adding blocked user--------------------------
  Future<void> addBlockedUser(String blockedUserId) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final currentUserId = currentUser.uid;

    // Find the user document where 'id' == Firebase UID
    final userQuery = await _firebaseFirestore
        .collection('user')
        .where('id', isEqualTo: currentUserId)
        .get();

    if (userQuery.docs.isEmpty) return; // User not found

    final userDocId = userQuery.docs.first.id;

    // Use fixed document 'main' under blocked subcollection
    final blockedDocRef = _firebaseFirestore
        .collection('user')
        .doc(userDocId)
        .collection('blocked')
        .doc('main');

    final docSnapshot = await blockedDocRef.get();

    if (!docSnapshot.exists) {
      await blockedDocRef.set({
        'id': currentUserId,
        'blockedUserId': [blockedUserId],
      });
    } else {
      await blockedDocRef.update({
        'blockedUserId': FieldValue.arrayUnion([blockedUserId]),
      });
    }
  }

  //-----------------unblocking user or removing from blocked list
  Future<void> removeBlockedUser(String blockedUserId) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final currentUserId = currentUser.uid;

    // Find the correct user document using 'id' == currentUserId
    final userQuery = await _firebaseFirestore
        .collection('user')
        .where('id', isEqualTo: currentUserId)
        .get();

    if (userQuery.docs.isEmpty) return; // User not found

    final userDocId = userQuery.docs.first.id;

    final blockedDocRef = _firebaseFirestore
        .collection('user')
        .doc(userDocId)
        .collection('blocked')
        .doc('main');

    final docSnapshot = await blockedDocRef.get();

    if (!docSnapshot.exists) return;

    // Remove the blockedUserId from the list
    await blockedDocRef.update({
      'blockedUserId': FieldValue.arrayRemove([blockedUserId]),
    });

    // Re-check the updated document to see if list is now empty
    final updatedDoc = await blockedDocRef.get();
    final data = updatedDoc.data();

    if (data != null) {
      final List<dynamic>? blockedUserId = data['blockedUserId'];
      if (blockedUserId == null || blockedUserId.isEmpty) {
        // Delete the 'main' document if no more blocked IDs
        await blockedDocRef.delete();
      }
    }
  }

  // Fetch blocked users from blocks collection
  Future<BlockedModel?> fetchBlockedUsers() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) return null;

    final currentUserId = currentUser.uid;
    debugPrint("currentUserId : ${currentUserId}");

    // Query the blocks collection for current user as blocker
    final blocksQuery = await _firebaseFirestore
        .collection('blocks')
        .where('blockerId', isEqualTo: currentUserId)
        .get();

    if (blocksQuery.docs.isEmpty) return null;

    // Extract all blocked user IDs
    final List<String> blockedUserIds = blocksQuery.docs
        .map((doc) => doc.data()['blockedUserId'] as String)
        .toList();

    return BlockedModel(
      id: currentUserId,
      blockedUserId: blockedUserIds,
    );
  }

  // Check if a user is blocked by current user
  Future<bool> isUserBlocked(String userId) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return false;

    final currentUserId = currentUser.uid;

    final blockQuery = await _firebaseFirestore
        .collection('blocks')
        .where('blockerId', isEqualTo: currentUserId)
        .where('blockedUserId', isEqualTo: userId)
        .get();

    return blockQuery.docs.isNotEmpty;
  }

  // Block a user (add to blocks collection)
  Future<void> blockUser(String userIdToBlock) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final currentUserId = currentUser.uid;

    // Check if already blocked
    final existingBlock = await _firebaseFirestore
        .collection('blocks')
        .where('blockerId', isEqualTo: currentUserId)
        .where('blockedUserId', isEqualTo: userIdToBlock)
        .get();

    if (existingBlock.docs.isNotEmpty) return; // Already blocked

    // Add to blocks collection
    await _firebaseFirestore.collection('blocks').add({
      'blockerId': currentUserId,
      'blockedUserId': userIdToBlock,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // Unblock a user (remove from blocks collection)
  Future<void> unblockUser(String userIdToUnblock) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final currentUserId = currentUser.uid;

    // Find and delete the block document
    final blockQuery = await _firebaseFirestore
        .collection('blocks')
        .where('blockerId', isEqualTo: currentUserId)
        .where('blockedUserId', isEqualTo: userIdToUnblock)
        .get();

    if (blockQuery.docs.isNotEmpty) {
      await blockQuery.docs.first.reference.delete();
    }
  }
} 