import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AccountManagementService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  AccountManagementService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  /// Suspend user account by setting isSuspended to true
  Future<bool> suspendAccount() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        debugPrint('No current user found');
        return false;
      }

      // Update user document in Firestore
      await _firestore.collection('user').doc(currentUser.uid).update({
        'isSuspended': true,
        'suspendedAt': FieldValue.serverTimestamp(),
      });

      debugPrint('Account suspended successfully');
      return true;
    } catch (e) {
      debugPrint('Error suspending account: $e');
      return false;
    }
  }

  /// Delete user account by setting isDeleted to true
  Future<bool> deleteAccount() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        debugPrint('No current user found');
        return false;
      }

      // Update user document in Firestore
      await _firestore.collection('user').doc(currentUser.uid).update({
        'isDeleted': true,
        'deletedAt': FieldValue.serverTimestamp(),
      });

      // Optionally, you can also delete the user from Firebase Auth
      // await currentUser.delete();

      debugPrint('Account deleted successfully');
      return true;
    } catch (e) {
      debugPrint('Error deleting account: $e');
      return false;
    }
  }

  /// Restore suspended account by setting isSuspended to false
  Future<bool> restoreAccount() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        debugPrint('No current user found');
        return false;
      }

      // Update user document in Firestore
      await _firestore.collection('user').doc(currentUser.uid).update({
        'isSuspended': false,
        'restoredAt': FieldValue.serverTimestamp(),
      });

      debugPrint('Account restored successfully');
      return true;
    } catch (e) {
      debugPrint('Error restoring account: $e');
      return false;
    }
  }

  /// Check if current user account is suspended
  Future<bool> isAccountSuspended() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        return false;
      }

      final doc = await _firestore.collection('user').doc(currentUser.uid).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return data['isSuspended'] as bool? ?? false;
      }
      return false;
    } catch (e) {
      debugPrint('Error checking account suspension status: $e');
      return false;
    }
  }

  /// Check if current user account is deleted
  Future<bool> isAccountDeleted() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        return false;
      }

      final doc = await _firestore.collection('user').doc(currentUser.uid).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return data['isDeleted'] as bool? ?? false;
      }
      return false;
    } catch (e) {
      debugPrint('Error checking account deletion status: $e');
      return false;
    }
  }
}
