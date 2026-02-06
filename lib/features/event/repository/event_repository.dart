import 'package:afriqueen/features/event/model/event_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../services/invisible_mode_service.dart';

class EventRepository {
  EventRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;
  final InvisibleModeService _invisibleModeService = InvisibleModeService();
  static const String _collection = 'events';

  Future<String> createEvent(EventModel model) async {
    final ref = await _db.collection(_collection).add(model.toJson());
    return ref.id;
  }

  Stream<List<EventModel>> streamEvents({EventStatus? status}) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    Query<Map<String, dynamic>> query = _db.collection(_collection);
    final bool isFiltered = status != null;
    if (isFiltered) {
      // Avoid composite index by not combining where + orderBy server-side
      query = query.where('status', whereIn: [status!.name, 'EventStatus.${status.name}']);
    } else {
      query = query.orderBy('date');
    }
    return query.snapshots().asyncMap((snapshot) async {
      final List<EventModel> visibleEvents = [];
      
      for (final doc in snapshot.docs) {
        final event = EventModel.fromDoc(doc);
        final creatorId = event.creatorId;
        
        // Skip current user's own events
        if (currentUserId != null && creatorId == currentUserId) {
          visibleEvents.add(event);
          continue;
        }
        
        // Check if event creator is invisible and we haven't interacted
        final isInvisible = await _invisibleModeService.isUserInvisible(creatorId);
        if (!isInvisible) {
          visibleEvents.add(event);
        } else {
          final hasInteracted = await _invisibleModeService.hasInteractedWith(creatorId);
          if (hasInteracted) {
            visibleEvents.add(event);
          }
        }
      }
      
      if (isFiltered) {
        visibleEvents.sort((a, b) => a.date.compareTo(b.date));
      }
      
      return visibleEvents;
    });
  }

  /// Stream events created by a specific user
  Stream<List<EventModel>> streamEventsByCreator(String creatorId) {
    final query = _db
        .collection(_collection)
        .where('creatorId', isEqualTo: creatorId);
    return query.snapshots().map(
      (snapshot) => snapshot.docs.map((d) => EventModel.fromDoc(d)).toList(),
    );
  }

  /// Add a participant to an event
  Future<void> addParticipantToEvent({
    required String eventId,
    required String userId,
    String? userName,
    String? userPhotoUrl,
  }) async {
    await _db.collection(_collection).doc(eventId).collection('participants').doc(userId).set({
      'userId': userId,
      'userName': userName,
      'userPhotoUrl': userPhotoUrl,
      'joinedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Remove a participant from an event
  Future<void> removeParticipantFromEvent({
    required String eventId,
    required String userId,
  }) async {
    await _db.collection(_collection).doc(eventId).collection('participants').doc(userId).delete();
  }

  /// Get participants for an event
  Stream<List<Map<String, dynamic>>> streamEventParticipants(String eventId) {
    return _db
        .collection(_collection)
        .doc(eventId)
        .collection('participants')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {
                  'userId': doc.id,
                  ...doc.data(),
                })
            .toList());
  }

  /// Check if user is participating in an event
  Future<bool> isUserParticipatingInEvent({
    required String eventId,
    required String userId,
  }) async {
    final doc = await _db
        .collection(_collection)
        .doc(eventId)
        .collection('participants')
        .doc(userId)
        .get();
    return doc.exists;
  }
}


