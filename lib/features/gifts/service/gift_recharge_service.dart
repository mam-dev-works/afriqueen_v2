import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:afriqueen/features/activity/model/user_gift_model.dart';

class GiftRechargeService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Recharge times in hours for each gift type
  static const Map<String, int> _rechargeTimes = {
    'rose': 8,
    'chocolat': 12,
    'bouquet': 32,
    'vetement': 72, // 3 days
    'coeur': 552, // 23 days
    'bague': 2160, // 90 days
    'papillon': 552, // 23 days
    'trophee': 2,
    'donut': 48,
    'pizza': 1,
    'sac': 48,
    'chiot': 1, // 30 minutes = 0.5 hours, but we'll use 1 hour for simplicity
  };

  /// Initialize recharge timers for all gifts
  static Future<void> initializeRechargeTimers() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    try {
      // Get current user gifts
      final giftsSnapshot = await _firestore
          .collection('user')
          .doc(userId)
          .collection('gifts')
          .get();

      // Create a map of existing gifts
      final Map<String, UserGiftModel> existingGifts = {};
      for (var doc in giftsSnapshot.docs) {
        final gift = UserGiftModel.fromFirestore(doc);
        existingGifts[gift.giftType] = gift;
      }

      // Check and recharge gifts
      await _checkAndRechargeGifts(userId, existingGifts);
    } catch (e) {
      print('Error initializing recharge timers: $e');
    }
  }

  /// Check and recharge gifts based on their recharge times
  static Future<void> _checkAndRechargeGifts(String userId, Map<String, UserGiftModel> existingGifts) async {
    final now = DateTime.now();
    bool hasUpdates = false;

    // Check each gift type
    for (String giftType in GiftTypes.regularGifts + GiftTypes.premiumGifts) {
      final rechargeTimeHours = _rechargeTimes[giftType] ?? 24;
      final existingGift = existingGifts[giftType];
      
      if (existingGift != null) {
        // Check if it's time to recharge
        final lastRechargeTime = existingGift.lastRechargeTime ?? now;
        final hoursSinceLastRecharge = now.difference(lastRechargeTime).inHours;
        
        if (hoursSinceLastRecharge >= rechargeTimeHours) {
          // Calculate how many gifts to add (could be multiple if user was offline for a while)
          final giftsToAdd = (hoursSinceLastRecharge / rechargeTimeHours).floor();
          final newCount = existingGift.remainingCount + giftsToAdd;
          
          // Update the gift
          await _updateGift(userId, giftType, newCount, now);
          hasUpdates = true;
        }
      } else {
        // Gift doesn't exist, create it with 1 gift
        await _createGift(userId, giftType, 1, now);
        hasUpdates = true;
      }
    }

    if (hasUpdates) {
      print('Gifts recharged successfully');
    }
  }

  /// Update an existing gift
  static Future<void> _updateGift(String userId, String giftType, int newCount, DateTime lastRechargeTime) async {
    try {
      await _firestore
          .collection('user')
          .doc(userId)
          .collection('gifts')
          .doc(giftType)
          .update({
        'remainingCount': newCount,
        'lastRechargeTime': Timestamp.fromDate(lastRechargeTime),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      print('Error updating gift $giftType: $e');
    }
  }

  /// Create a new gift
  static Future<void> _createGift(String userId, String giftType, int count, DateTime lastRechargeTime) async {
    try {
      final isPremium = GiftTypes.premiumGifts.contains(giftType);
      
      await _firestore
          .collection('user')
          .doc(userId)
          .collection('gifts')
          .doc(giftType)
          .set({
        'remainingCount': count,
        'isPremium': isPremium,
        'lastRechargeTime': Timestamp.fromDate(lastRechargeTime),
        'createdAt': Timestamp.fromDate(DateTime.now()),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      print('Error creating gift $giftType: $e');
    }
  }

  /// Send a gift (decrease count and update last recharge time)
  static Future<bool> sendGift(String giftType) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return false;

    try {
      final giftDoc = await _firestore
          .collection('user')
          .doc(userId)
          .collection('gifts')
          .doc(giftType)
          .get();

      if (!giftDoc.exists) {
        return false;
      }

      final gift = UserGiftModel.fromFirestore(giftDoc);
      if (gift.remainingCount <= 0) {
        return false;
      }

      // Decrease count
      final newCount = gift.remainingCount - 1;
      await _updateGift(userId, giftType, newCount, DateTime.now());

      return true;
    } catch (e) {
      print('Error sending gift $giftType: $e');
      return false;
    }
  }

  /// Check if user has a specific gift available
  static Future<bool> hasGiftAvailable(String giftType) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return false;

    try {
      final giftDoc = await _firestore
          .collection('user')
          .doc(userId)
          .collection('gifts')
          .doc(giftType)
          .get();

      if (!giftDoc.exists) {
        return false;
      }

      final gift = UserGiftModel.fromFirestore(giftDoc);
      return gift.remainingCount > 0;
    } catch (e) {
      print('Error checking gift availability $giftType: $e');
      return false;
    }
  }

  /// Get remaining time until next recharge for a gift
  static Future<Duration?> getTimeUntilNextRecharge(String giftType) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return null;

    try {
      final giftDoc = await _firestore
          .collection('user')
          .doc(userId)
          .collection('gifts')
          .doc(giftType)
          .get();

      if (!giftDoc.exists) return null;

      final gift = UserGiftModel.fromFirestore(giftDoc);
      final lastRechargeTime = gift.lastRechargeTime ?? DateTime.now();
      final rechargeTimeHours = _rechargeTimes[giftType] ?? 24;
      final nextRechargeTime = lastRechargeTime.add(Duration(hours: rechargeTimeHours));
      final now = DateTime.now();

      if (nextRechargeTime.isAfter(now)) {
        return nextRechargeTime.difference(now);
      } else {
        return Duration.zero; // Ready to recharge
      }
    } catch (e) {
      print('Error getting time until next recharge for $giftType: $e');
      return null;
    }
  }

  /// Start periodic recharge check (call this when app starts)
  static void startPeriodicRechargeCheck() {
    // Check every hour
    Future.delayed(Duration(hours: 1), () {
      initializeRechargeTimers();
      startPeriodicRechargeCheck(); // Schedule next check
    });
  }

  /// Get recharge time in hours for a gift type
  static int getRechargeTimeHours(String giftType) {
    return _rechargeTimes[giftType] ?? 24;
  }

  /// Format duration to human readable string
  static String formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays} jour${duration.inDays > 1 ? 's' : ''}';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}min';
    } else {
      return '0min';
    }
  }
}
