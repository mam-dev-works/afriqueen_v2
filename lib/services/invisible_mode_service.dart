import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Service to handle invisible mode functionality
/// Checks if users have interacted (likes, gifts, requests, events, conversations)
class InvisibleModeService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  InvisibleModeService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  /// Check if a user is in invisible mode
  Future<bool> isUserInvisible(String userId) async {
    try {
      final userQuery = await _firestore
          .collection('user')
          .where('id', isEqualTo: userId)
          .limit(1)
          .get();

      if (userQuery.docs.isEmpty) return false;

      final userData = userQuery.docs.first.data();
      return userData['isInvisibleMode'] as bool? ?? false;
    } catch (e) {
      debugPrint('Error checking invisible mode: $e');
      return false;
    }
  }

  /// Check if current user has interacted with another user
  /// Interactions include: likes, gifts, requests, event participations, conversations
  Future<bool> hasInteractedWith(String otherUserId) async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) return false;

      // Check for likes (either direction)
      final hasLiked = await _checkLikes(currentUserId, otherUserId);
      if (hasLiked) return true;

      // Check for gifts (either direction)
      final hasGifts = await _checkGifts(currentUserId, otherUserId);
      if (hasGifts) return true;

      // Check for message requests (either direction)
      final hasRequests = await _checkMessageRequests(currentUserId, otherUserId);
      if (hasRequests) return true;

      // Check for event participations
      final hasEventParticipation = await _checkEventParticipation(currentUserId, otherUserId);
      if (hasEventParticipation) return true;

      // Check for conversations/chats
      final hasConversation = await _checkConversations(currentUserId, otherUserId);
      if (hasConversation) return true;

      return false;
    } catch (e) {
      debugPrint('Error checking interactions: $e');
      return false;
    }
  }

  /// Check if users have liked each other
  Future<bool> _checkLikes(String userId1, String userId2) async {
    try {
      // Check if userId1 liked userId2
      final like1 = await _firestore
          .collection('likes')
          .where('likerId', isEqualTo: userId1)
          .where('likedUserId', isEqualTo: userId2)
          .limit(1)
          .get();

      if (like1.docs.isNotEmpty) return true;

      // Check if userId2 liked userId1
      final like2 = await _firestore
          .collection('likes')
          .where('likerId', isEqualTo: userId2)
          .where('likedUserId', isEqualTo: userId1)
          .limit(1)
          .get();

      return like2.docs.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking likes: $e');
      return false;
    }
  }

  /// Check if users have sent gifts to each other
  Future<bool> _checkGifts(String userId1, String userId2) async {
    try {
      // Check if userId1 sent gift to userId2
      final gift1 = await _firestore
          .collection('gifts_sent')
          .where('senderId', isEqualTo: userId1)
          .where('recipientId', isEqualTo: userId2)
          .limit(1)
          .get();

      if (gift1.docs.isNotEmpty) return true;

      // Check if userId2 sent gift to userId1
      final gift2 = await _firestore
          .collection('gifts_sent')
          .where('senderId', isEqualTo: userId2)
          .where('recipientId', isEqualTo: userId1)
          .limit(1)
          .get();

      return gift2.docs.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking gifts: $e');
      return false;
    }
  }

  /// Check if users have message requests
  Future<bool> _checkMessageRequests(String userId1, String userId2) async {
    try {
      // Check if userId1 sent request to userId2
      final request1 = await _firestore
          .collection('messageRequests')
          .where('senderId', isEqualTo: userId1)
          .where('receiverId', isEqualTo: userId2)
          .limit(1)
          .get();

      if (request1.docs.isNotEmpty) return true;

      // Check if userId2 sent request to userId1
      final request2 = await _firestore
          .collection('messageRequests')
          .where('senderId', isEqualTo: userId2)
          .where('receiverId', isEqualTo: userId1)
          .limit(1)
          .get();

      return request2.docs.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking message requests: $e');
      return false;
    }
  }

  /// Check if users have participated in same events
  Future<bool> _checkEventParticipation(String userId1, String userId2) async {
    try {
      // Get events where userId1 is creator
      final eventsCreatedByUser1 = await _firestore
          .collection('events')
          .where('creatorId', isEqualTo: userId1)
          .get();

      // Check if userId2 participated in any of these events
      for (var eventDoc in eventsCreatedByUser1.docs) {
        final participants = await _firestore
            .collection('events')
            .doc(eventDoc.id)
            .collection('participants')
            .where('userId', isEqualTo: userId2)
            .limit(1)
            .get();

        if (participants.docs.isNotEmpty) return true;
      }

      // Get events where userId2 is creator
      final eventsCreatedByUser2 = await _firestore
          .collection('events')
          .where('creatorId', isEqualTo: userId2)
          .get();

      // Check if userId1 participated in any of these events
      for (var eventDoc in eventsCreatedByUser2.docs) {
        final participants = await _firestore
            .collection('events')
            .doc(eventDoc.id)
            .collection('participants')
            .where('userId', isEqualTo: userId1)
            .limit(1)
            .get();

        if (participants.docs.isNotEmpty) return true;
      }

      return false;
    } catch (e) {
      debugPrint('Error checking event participation: $e');
      return false;
    }
  }

  /// Check if users have conversations
  Future<bool> _checkConversations(String userId1, String userId2) async {
    try {
      // Check if there's a chat between the two users
      final chats = await _firestore
          .collection('chats')
          .where('participants', arrayContains: userId1)
          .get();

      for (var chatDoc in chats.docs) {
        final participants = chatDoc.data()['participants'] as List<dynamic>? ?? [];
        if (participants.contains(userId2)) {
          return true;
        }
      }

      return false;
    } catch (e) {
      debugPrint('Error checking conversations: $e');
      return false;
    }
  }

  /// Filter out invisible users that current user hasn't interacted with
  Future<List<String>> filterInvisibleUsers(List<String> userIds) async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) return userIds;

      final List<String> visibleUserIds = [];

      for (final userId in userIds) {
        // Skip current user
        if (userId == currentUserId) {
          visibleUserIds.add(userId);
          continue;
        }

        // Check if user is invisible
        final isInvisible = await isUserInvisible(userId);
        if (!isInvisible) {
          // User is not invisible, include them
          visibleUserIds.add(userId);
          continue;
        }

        // User is invisible, check if we have interacted
        final hasInteracted = await hasInteractedWith(userId);
        if (hasInteracted) {
          // We have interacted, include them
          visibleUserIds.add(userId);
        }
        // If no interaction, exclude them (don't add to visibleUserIds)
      }

      return visibleUserIds;
    } catch (e) {
      debugPrint('Error filtering invisible users: $e');
      // On error, return all users to avoid breaking the app
      return userIds;
    }
  }
}

