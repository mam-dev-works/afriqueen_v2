import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PremiumService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  PremiumService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  /// Check if user is premium
  Future<bool> isUserPremium() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return false;

      final userDoc = await _firestore
          .collection('user')
          .where('id', isEqualTo: currentUser.uid)
          .get();

      if (userDoc.docs.isEmpty) return false;

      final userData = userDoc.docs.first.data();
      return userData['isPremium'] as bool? ?? false;
    } catch (e) {
      debugPrint('Error checking premium status: $e');
      return false;
    }
  }

  /// Check if user is Elite
  Future<bool> isUserElite() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return false;

      final userDoc = await _firestore
          .collection('user')
          .where('id', isEqualTo: currentUser.uid)
          .get();

      if (userDoc.docs.isEmpty) return false;

      final userData = userDoc.docs.first.data();
      return userData['isElite'] as bool? ?? false;
    } catch (e) {
      debugPrint('Error checking elite status: $e');
      return false;
    }
  }

  /// Check if user is Premium or Elite
  Future<bool> isUserPremiumOrElite() async {
    final isPremium = await isUserPremium();
    final isElite = await isUserElite();
    return isPremium || isElite;
  }

  /// Check if user has reached their event limit
  Future<bool> hasReachedEventLimit() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return true;

      // Check if user is premium
      final isPremium = await isUserPremium();
      
      if (isPremium) {
        // Premium users can have up to 5 events
        final eventsQuery = await _firestore
            .collection('events')
            .where('creatorId', isEqualTo: currentUser.uid)
            .get();
        
        return eventsQuery.docs.length >= 5;
      } else {
        // Non-premium users can have only 1 event
        final eventsQuery = await _firestore
            .collection('events')
            .where('creatorId', isEqualTo: currentUser.uid)
            .get();
        
        return eventsQuery.docs.length >= 1;
      }
    } catch (e) {
      debugPrint('Error checking event limit: $e');
      return true; // Assume limit reached on error
    }
  }

  /// Get user's current event count
  Future<int> getUserEventCount() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return 0;

      final eventsQuery = await _firestore
          .collection('events')
          .where('creatorId', isEqualTo: currentUser.uid)
          .get();

      return eventsQuery.docs.length;
    } catch (e) {
      debugPrint('Error getting event count: $e');
      return 0;
    }
  }

  /// Get user's maximum allowed events
  Future<int> getMaxAllowedEvents() async {
    final isPremium = await isUserPremium();
    return isPremium ? 5 : 1;
  }

  /// Set user's premium status (for testing purposes)
  Future<bool> setPremiumStatus(bool isPremium) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return false;

      final userQuery = await _firestore
          .collection('user')
          .where('id', isEqualTo: currentUser.uid)
          .get();

      if (userQuery.docs.isEmpty) return false;

      final userDocId = userQuery.docs.first.id;
      await _firestore.collection('user').doc(userDocId).update({
        'isPremium': isPremium,
      });

      debugPrint('Premium status updated to: $isPremium');
      return true;
    } catch (e) {
      debugPrint('Error setting premium status: $e');
      return false;
    }
  }

  /// Debug method to check user status
  Future<void> debugUserStatus() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        debugPrint('No current user');
        return;
      }

      final isPremium = await isUserPremium();
      final eventCount = await getUserEventCount();
      final maxEvents = await getMaxAllowedEvents();
      final hasReachedLimit = await hasReachedEventLimit();

      debugPrint('=== User Status Debug ===');
      debugPrint('User ID: ${currentUser.uid}');
      debugPrint('Is Premium: $isPremium');
      debugPrint('Event Count: $eventCount');
      debugPrint('Max Allowed Events: $maxEvents');
      debugPrint('Has Reached Limit: $hasReachedLimit');
      debugPrint('========================');
    } catch (e) {
      debugPrint('Error in debugUserStatus: $e');
    }
  }
}
