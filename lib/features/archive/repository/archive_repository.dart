import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';

import '../model/archive_model.dart';

class ArchiveRepository {
  final FirebaseFirestore _firebaseFirestore;

  ArchiveRepository({FirebaseFirestore? firestore})
      : _firebaseFirestore = firestore ?? FirebaseFirestore.instance;
//--------------------------adding archive--------------------------
  Future<void> addArchive(String archiveId) async {
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

    // Use fixed document 'main' under archive subcollection
    final archiveDocRef = _firebaseFirestore
        .collection('user')
        .doc(userDocId)
        .collection('archive')
        .doc('main');

    final docSnapshot = await archiveDocRef.get();

    if (!docSnapshot.exists) {
      await archiveDocRef.set({
        'id': currentUserId,
        'archiveId': [archiveId],
      });
    } else {
      await archiveDocRef.update({
        'archiveId': FieldValue.arrayUnion([archiveId]),
      });
    }
  }

//-----------------deleting block user or removing archive
  Future<void> removeArchive(String archiveId) async {
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

    final archiveDocRef = _firebaseFirestore
        .collection('user')
        .doc(userDocId)
        .collection('archive')
        .doc('main');

    final docSnapshot = await archiveDocRef.get();

    if (!docSnapshot.exists) return;

    // Remove the archiveId from the list
    await archiveDocRef.update({
      'archiveId': FieldValue.arrayRemove([archiveId]),
    });

    // Re-check the updated document to see if list is now empty
    final updatedDoc = await archiveDocRef.get();
    final data = updatedDoc.data();

    if (data != null) {
      final List<dynamic>? archiveId = data['archiveId'];
      if (archiveId == null || archiveId.isEmpty) {
        // Delete the 'main' document if no more blocked IDs
        await archiveDocRef.delete();
      }
    }
  }

  Future<ArchiveModel?> fetchArchives() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) return null;

    final currentUserId = currentUser.uid;
    debugPrint("currentUserId : ${currentUserId}");
    final userQuery = await _firebaseFirestore
        .collection('user')
        .where('id', isEqualTo: currentUserId)
        .get();

    if (userQuery.docs.isEmpty) return null;

    final userDocId = userQuery.docs.first.id;

    final archiveDocRef = _firebaseFirestore
        .collection('user')
        .doc(userDocId)
        .collection('archive')
        .doc('main');

    final docSnapshot = await archiveDocRef.get();

    if (!docSnapshot.exists || docSnapshot.data() == null) return null;

    return ArchiveModel.fromMap(docSnapshot.data()!);
  }
}
