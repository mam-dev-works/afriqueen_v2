import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class LikeRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> likeUser(String likedUserId) async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) throw Exception('User not authenticated');

      await _firestore.collection('likes').add({
        'likerId': currentUserId,
        'likedUserId': likedUserId,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error liking user: $e');
      rethrow;
    }
  }

  Future<void> unlikeUser(String likedUserId) async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) throw Exception('User not authenticated');

      final likeQuery = await _firestore
          .collection('likes')
          .where('likerId', isEqualTo: currentUserId)
          .where('likedUserId', isEqualTo: likedUserId)
          .get();

      for (var doc in likeQuery.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      debugPrint('Error unliking user: $e');
      rethrow;
    }
  }

  Future<bool> hasLikedUser(String likedUserId) async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) return false;

      final likeQuery = await _firestore
          .collection('likes')
          .where('likerId', isEqualTo: currentUserId)
          .where('likedUserId', isEqualTo: likedUserId)
          .get();

      return likeQuery.docs.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking if user liked: $e');
      return false;
    }
  }

  Future<bool> isLikedByUser(String likerUserId) async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) return false;

      final likeQuery = await _firestore
          .collection('likes')
          .where('likerId', isEqualTo: likerUserId)
          .where('likedUserId', isEqualTo: currentUserId)
          .get();

      return likeQuery.docs.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking if user is liked by: $e');
      return false;
    }
  }

  Future<List<String>> getLikedUserIds() async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) return [];

      final likeQuery = await _firestore
          .collection('likes')
          .where('likerId', isEqualTo: currentUserId)
          .get();

      return likeQuery.docs.map((doc) => doc.data()['likedUserId'] as String).toList();
    } catch (e) {
      debugPrint('Error getting liked user IDs: $e');
      return [];
    }
  }
} 