import 'package:afriqueen/features/favorite/model/favorite_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';

class FavoriteRepository {
  final FirebaseFirestore _firebaseFirestore;

  FavoriteRepository({FirebaseFirestore? firestore})
      : _firebaseFirestore = firestore ?? FirebaseFirestore.instance;
//--------------------------adding favourite--------------------------
  Future<void> addFavorite(String favId) async {
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

    // Use fixed document 'main' under favourite subcollection
    final favouriteDocRef = _firebaseFirestore
        .collection('user')
        .doc(userDocId)
        .collection('favourite')
        .doc('main');

    final docSnapshot = await favouriteDocRef.get();

    if (!docSnapshot.exists) {
      await favouriteDocRef.set({
        'id': currentUserId,
        'favId': [favId],
      });
    } else {
      await favouriteDocRef.update({
        'favId': FieldValue.arrayUnion([favId]),
      });
    }
  }

//-----------------deleting block user or removing  favourite
  Future<void> removeFavorite(String favId) async {
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

    final favouriteDocRef = _firebaseFirestore
        .collection('user')
        .doc(userDocId)
        .collection('favourite')
        .doc('main');

    final docSnapshot = await favouriteDocRef.get();

    if (!docSnapshot.exists) return;

    // Remove the favId from the list
    await favouriteDocRef.update({
      'favId': FieldValue.arrayRemove([favId]),
    });

    // Re-check the updated document to see if list is now empty
    final updatedDoc = await favouriteDocRef.get();
    final data = updatedDoc.data();

    if (data != null) {
      final List<dynamic>? favIds = data['favId'];
      if (favIds == null || favIds.isEmpty) {
        // Delete the 'main' document if no more blocked IDs
        await favouriteDocRef.delete();
      }
    }
  }

  Future<FavoriteModel?> fetchFavorites() async {
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

    final favouriteDocRef = _firebaseFirestore
        .collection('user')
        .doc(userDocId)
        .collection('favourite')
        .doc('main');

    final docSnapshot = await favouriteDocRef.get();

    if (!docSnapshot.exists || docSnapshot.data() == null) return null;

    return FavoriteModel.fromMap(docSnapshot.data()!);
  }
}
