import 'package:afriqueen/features/event/model/event_message_model.dart';
import 'package:afriqueen/features/event/model/event_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EventMessageRepository {
  EventMessageRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;
  static const String _eventsCollection = 'events';
  static const String _eventMessagesCollection = 'event_messages';

  // Getter for accessing _db from service
  FirebaseFirestore get db => _db;

  /// Stream event messages for a specific event
  Stream<List<EventMessageModel>> streamEventMessages(String eventId) {
    return _db
        .collection(_eventsCollection)
        .doc(eventId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => EventMessageModel.fromDoc(doc))
            .toList());
  }

  /// Stream all event messages for the current user
  Stream<List<EventMessageModel>> streamUserEventMessages() {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) return Stream.value([]);

    // For now, return empty list since we need to implement proper event message fetching
    // This will be updated based on the actual Firebase structure
    return Stream.value(<EventMessageModel>[]);
  }

  /// Stream event messages grouped by event
  Stream<Map<String, List<EventMessageModel>>> streamEventMessagesGrouped() {
    return streamUserEventMessages().map((messages) {
      final Map<String, List<EventMessageModel>> grouped = {};
      for (final message in messages) {
        if (!grouped.containsKey(message.eventId)) {
          grouped[message.eventId] = [];
        }
        grouped[message.eventId]!.add(message);
      }
      return grouped;
    });
  }

  /// Send a message to an event
  Future<void> sendEventMessage({
    required String eventId,
    required String content,
    required String eventTitle,
    required String eventImageUrl,
    required bool isEventFinished,
    required String eventStatus,
  }) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) throw Exception('User not authenticated');

    // Get user profile data
    final userDoc = await _db.collection('users').doc(currentUser.uid).get();
    final userData = userDoc.data();
    
    final senderName = userData?['pseudo'] ?? userData?['name'] ?? 'Unknown User';
    final senderPhotoUrl = userData?['photos']?.isNotEmpty == true 
        ? userData!['photos'][0] 
        : '';

    final message = EventMessageModel(
      id: '', // Will be set by Firestore
      eventId: eventId,
      senderId: currentUser.uid,
      senderName: senderName,
      senderPhotoUrl: senderPhotoUrl,
      content: content,
      timestamp: DateTime.now(),
      eventTitle: eventTitle,
      eventImageUrl: eventImageUrl,
      isEventFinished: isEventFinished,
      eventStatus: eventStatus,
    );

    // Add message to the event's messages subcollection
    await _db
        .collection(_eventsCollection)
        .doc(eventId)
        .collection('messages')
        .add(message.toJson());
  }

  /// Get event details for a message
  Future<EventModel?> getEventDetails(String eventId) async {
    try {
      final doc = await _db.collection('events').doc(eventId).get();
      if (doc.exists) {
        return EventModel.fromDoc(doc);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Delete finished event discussions
  Future<void> deleteFinishedEventDiscussions() async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) return;

    // Get all finished events
    final finishedEvents = await _db
        .collection(_eventsCollection)
        .where('date', isLessThan: Timestamp.fromDate(DateTime.now()))
        .get();

    final finishedEventIds = finishedEvents.docs.map((doc) => doc.id).toList();

    if (finishedEventIds.isEmpty) return;

    // Delete messages for finished events
    final batch = _db.batch();
    for (final eventId in finishedEventIds) {
      final messages = await _db
          .collection(_eventsCollection)
          .doc(eventId)
          .collection('messages')
          .get();
      
      for (final message in messages.docs) {
        batch.delete(message.reference);
      }
    }

    await batch.commit();
  }

  /// Get event participation status
  Future<bool> isUserParticipatingInEvent(String eventId) async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) return false;

    try {
      final doc = await _db
          .collection('event_participants')
          .doc('${eventId}_$currentUserId')
          .get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  /// Get events where user participated
  Stream<List<String>> streamUserParticipatedEvents() {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) return Stream.value([]);

    return _db
        .collection('event_participants')
        .where('userId', isEqualTo: currentUserId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => doc.data()['eventId'] as String)
            .toList());
  }
}
