import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:afriqueen/features/gifts/model/gift_sent_model.dart';
import 'package:afriqueen/features/gifts/service/gift_recharge_service.dart';

class GiftSendService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Send a gift to another user
  static Future<bool> sendGift({
    required String recipientId,
    required String giftType,
    required String giftName,
    String? message,
  }) async {
    print('GiftSendService: sendGift called with recipientId=$recipientId, giftType=$giftType, giftName=$giftName');
    
    final senderId = _auth.currentUser?.uid;
    if (senderId == null) {
      print('GiftSendService: No authenticated user found');
      return false;
    }
    
    print('GiftSendService: Sender ID: $senderId');

    try {
      // First, check if sender has the gift available and deduct it
      final hasGift = await GiftRechargeService.sendGift(giftType);
      if (!hasGift) {
        return false;
      }

      // Fetch sender and recipient user data
      print('GiftSendService: Fetching sender data for: $senderId');
      final senderData = await _getUserData(senderId);
      print('GiftSendService: Sender data: $senderData');
      
      print('GiftSendService: Fetching recipient data for: $recipientId');
      final recipientData = await _getUserData(recipientId);
      print('GiftSendService: Recipient data: $recipientData');
      
      // Debug: Check if user data is null
      if (senderData['name'] == null || senderData['age'] == null) {
        print('GiftSendService: WARNING - Sender data is null or incomplete');
      }
      if (recipientData['name'] == null || recipientData['age'] == null) {
        print('GiftSendService: WARNING - Recipient data is null or incomplete');
      }

      // Create the gift sent record
      final giftSent = GiftSentModel(
        id: '', // Will be set by Firestore
        senderId: senderId,
        recipientId: recipientId,
        giftType: giftType,
        giftName: giftName,
        sentAt: DateTime.now(),
        message: message,
        senderName: senderData['name'],
        senderAge: senderData['age'],
        senderPhotoUrl: senderData['photoUrl'],
        recipientName: recipientData['name'],
        recipientAge: recipientData['age'],
        recipientPhotoUrl: recipientData['photoUrl'],
      );
      
      print('GiftSendService: Created gift sent model: ${giftSent.toMap()}');

      // Save to gifts_sent collection
      final giftData = giftSent.toMap();
      print('GiftSendService: Saving gift data to Firestore: $giftData');
      
      // Debug: Check if user data is in the map
      if (!giftData.containsKey('senderName') || giftData['senderName'] == null) {
        print('GiftSendService: ERROR - senderName is missing from giftData');
      }
      if (!giftData.containsKey('recipientName') || giftData['recipientName'] == null) {
        print('GiftSendService: ERROR - recipientName is missing from giftData');
      }
      
      final docRef = await _firestore
          .collection('gifts_sent')
          .add(giftData);
          
      print('GiftSendService: Gift saved with document ID: ${docRef.id}');

      return true;
    } catch (e) {
      print('Error sending gift: $e');
      return false;
    }
  }

  /// Get user data from Firestore
  static Future<Map<String, dynamic>> _getUserData(String userId) async {
    try {
      print('GiftSendService: Fetching user data for userId: $userId');
      final doc = await _firestore.collection('user').doc(userId).get();
      
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        print('GiftSendService: User document exists, data: $data');
        
        // Get the first photo from the photos array
        String? photoUrl;
        if (data['photos'] != null && (data['photos'] as List).isNotEmpty) {
          photoUrl = (data['photos'] as List).first;
        }
        
        final result = {
          'name': data['name'] ?? 'Unknown',
          'age': data['age'] ?? 0,
          'photoUrl': photoUrl,
        };
        
        print('GiftSendService: Returning user data: $result');
        return result;
      } else {
        print('GiftSendService: User document does not exist for userId: $userId');
      }
    } catch (e) {
      print('GiftSendService: Error fetching user data for $userId: $e');
    }
    
    print('GiftSendService: Returning default user data');
    return {
      'name': 'Unknown',
      'age': 0,
      'photoUrl': null,
    };
  }

  /// Get gifts sent by the current user
  static Stream<List<GiftSentModel>> getGiftsSentByUser() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('gifts_sent')
        .where('senderId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final gifts = snapshot.docs.map((doc) {
        return GiftSentModel.fromFirestore(doc);
      }).toList();
      
      // Sort by sentAt descending in memory
      gifts.sort((a, b) => b.sentAt.compareTo(a.sentAt));
      return gifts;
    });
  }

  /// Get gifts received by the current user
  static Stream<List<GiftSentModel>> getGiftsReceivedByUser() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('gifts_sent')
        .where('recipientId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final gifts = snapshot.docs.map((doc) {
        return GiftSentModel.fromFirestore(doc);
      }).toList();
      
      // Sort by sentAt descending in memory
      gifts.sort((a, b) => b.sentAt.compareTo(a.sentAt));
      return gifts;
    });
  }

  /// Get gifts sent between two specific users
  static Stream<List<GiftSentModel>> getGiftsBetweenUsers(String otherUserId) {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('gifts_sent')
        .where('senderId', isEqualTo: currentUserId)
        .where('recipientId', isEqualTo: otherUserId)
        .snapshots()
        .map((snapshot) {
      final gifts = snapshot.docs.map((doc) {
        return GiftSentModel.fromFirestore(doc);
      }).toList();
      
      // Sort by sentAt descending in memory
      gifts.sort((a, b) => b.sentAt.compareTo(a.sentAt));
      return gifts;
    });
  }

  /// Get total gifts sent count for a user
  static Future<int> getTotalGiftsSentCount(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('gifts_sent')
          .where('senderId', isEqualTo: userId)
          .get();
      return snapshot.docs.length;
    } catch (e) {
      print('Error getting gifts sent count: $e');
      return 0;
    }
  }

  /// Get total gifts received count for a user
  static Future<int> getTotalGiftsReceivedCount(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('gifts_sent')
          .where('recipientId', isEqualTo: userId)
          .get();
      return snapshot.docs.length;
    } catch (e) {
      print('Error getting gifts received count: $e');
      return 0;
    }
  }

  /// Get gifts sent count in the last 7 days
  static Future<int> getGiftsSentLast7Days(String userId) async {
    try {
      final sevenDaysAgo = DateTime.now().subtract(Duration(days: 7));
      final snapshot = await _firestore
          .collection('gifts_sent')
          .where('senderId', isEqualTo: userId)
          .where('sentAt', isGreaterThan: Timestamp.fromDate(sevenDaysAgo))
          .get();
      return snapshot.docs.length;
    } catch (e) {
      print('Error getting gifts sent last 7 days: $e');
      return 0;
    }
  }

  /// Get gifts received count in the last 7 days
  static Future<int> getGiftsReceivedLast7Days(String userId) async {
    try {
      final sevenDaysAgo = DateTime.now().subtract(Duration(days: 7));
      final snapshot = await _firestore
          .collection('gifts_sent')
          .where('recipientId', isEqualTo: userId)
          .where('sentAt', isGreaterThan: Timestamp.fromDate(sevenDaysAgo))
          .get();
      return snapshot.docs.length;
    } catch (e) {
      print('Error getting gifts received last 7 days: $e');
      return 0;
    }
  }
}
