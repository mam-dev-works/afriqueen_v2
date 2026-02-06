import 'package:afriqueen/features/event/model/event_request_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EventRequestRepository {
  EventRequestRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;
  static const String _collection = 'event_requests';

  /// Create a new event participation request
  Future<String> createEventRequest(EventRequestModel model) async {
    final ref = await _db.collection(_collection).add(model.toJson());
    return ref.id;
  }

  /// Submit an event participation request
  Future<String> submitParticipationRequest({
    required String eventId,
    required String eventCreatorId,
    required String message,
    required String eventTitle,
    String? requesterName,
    String? requesterPhotoUrl,
  }) async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }

    // Check if user already has a pending request for this event
    final existingRequest = await _db
        .collection(_collection)
        .where('eventId', isEqualTo: eventId)
        .where('requesterId', isEqualTo: currentUserId)
        .where('status', isEqualTo: EventRequestStatus.PENDING.name)
        .get();

    if (existingRequest.docs.isNotEmpty) {
      throw Exception('You already have a pending request for this event');
    }

    final eventRequest = EventRequestModel(
      id: '', // Will be set by Firestore
      eventId: eventId,
      requesterId: currentUserId,
      eventCreatorId: eventCreatorId,
      message: message,
      status: EventRequestStatus.PENDING,
      createdAt: DateTime.now(),
      requesterName: requesterName,
      requesterPhotoUrl: requesterPhotoUrl,
      eventTitle: eventTitle,
    );

    return await createEventRequest(eventRequest);
  }

  /// Stream event requests received by a user (for event creators)
  Stream<List<EventRequestModel>> streamReceivedEventRequests(String userId) {
    return _db
        .collection(_collection)
        .where('eventCreatorId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final requests = snapshot.docs
              .map((doc) => EventRequestModel.fromDoc(doc))
              .toList();
          // Sort by createdAt in descending order on the client side
          requests.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return requests;
        });
  }

  /// Stream event requests sent by a user
  Stream<List<EventRequestModel>> streamSentEventRequests(String userId) {
    return _db
        .collection(_collection)
        .where('requesterId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final requests = snapshot.docs
              .map((doc) => EventRequestModel.fromDoc(doc))
              .toList();
          // Sort by createdAt in descending order on the client side
          requests.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return requests;
        });
  }

  /// Update event request status (accept/reject)
  Future<void> updateEventRequestStatus({
    required String requestId,
    required EventRequestStatus status,
  }) async {
    await _db.collection(_collection).doc(requestId).update({
      'status': status.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Get event requests for a specific event
  Stream<List<EventRequestModel>> streamEventRequests(String eventId) {
    return _db
        .collection(_collection)
        .where('eventId', isEqualTo: eventId)
        .snapshots()
        .map((snapshot) {
          final requests = snapshot.docs
              .map((doc) => EventRequestModel.fromDoc(doc))
              .toList();
          // Sort by createdAt in descending order on the client side
          requests.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return requests;
        });
  }

  /// Delete an event request
  Future<void> deleteEventRequest(String requestId) async {
    await _db.collection(_collection).doc(requestId).delete();
  }
}
