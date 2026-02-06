import 'package:afriqueen/features/event/repository/event_message_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EventMessageService {
  final EventMessageRepository _repository;

  EventMessageService(this._repository);

  /// Create sample event messages for testing
  Future<void> createSampleEventMessages() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    // First, get existing events from Firebase
    final eventsSnapshot = await _repository.db.collection('events').limit(3).get();
    
    if (eventsSnapshot.docs.isEmpty) {
      print('No events found to create sample messages');
      return;
    }

    // Sample messages data
    final sampleMessages = [
      'J\'ai vraiment aimé participé à votre évènement',
      'C\'était pas trop mal cette séance de partage d\'expérience',
      'C\'était une chouette soirée au bord de la piscine',
    ];

    // Create sample messages for existing events
    for (int i = 0; i < eventsSnapshot.docs.length && i < sampleMessages.length; i++) {
      final eventDoc = eventsSnapshot.docs[i];
      final eventData = eventDoc.data();
      final eventId = eventDoc.id;

      try {
        await _repository.sendEventMessage(
          eventId: eventId,
          content: sampleMessages[i],
          eventTitle: eventData['title'] ?? 'Event Title',
          eventImageUrl: eventData['imageUrl'] ?? '',
          isEventFinished: false, // You can determine this based on event date
          eventStatus: eventData['status'] ?? 'GROUP',
        );
        print('Created sample message for event: $eventId');
      } catch (e) {
        print('Error creating sample message for event $eventId: $e');
      }
    }
  }

  /// Clear all event messages (for testing)
  Future<void> clearAllEventMessages() async {
    // This would require implementing a clear method in the repository
    // For now, we'll just log that this would clear messages
    print('Clearing all event messages...');
  }
}
