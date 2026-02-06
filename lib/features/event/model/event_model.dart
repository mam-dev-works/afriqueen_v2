import 'package:cloud_firestore/cloud_firestore.dart';

/// Status of an event used for filtering on the Event list screen.
enum EventStatus { DUO, GROUP }

/// Core Event entity persisted in the `events` Firestore collection.
class EventModel {
  EventModel({
    required this.id,
    required this.title,
    required this.date,
    required this.location,
    required this.description,
    required this.status,
    required this.creatorId,
    this.imageUrl,
    this.costCovered = false,
    this.maxParticipants,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String title;
  final DateTime date;
  final String location;
  final String description;
  final EventStatus status;
  final String creatorId;
  final String? imageUrl;
  final bool costCovered;
  final int? maxParticipants;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'date': Timestamp.fromDate(date),
      'location': location,
      'description': description,
      'status': status.name, // stores as 'DUO' or 'GROUP'
      'creatorId': creatorId,
      'imageUrl': imageUrl,
      'costCovered': costCovered,
      'maxParticipants': maxParticipants,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : FieldValue.serverTimestamp(),
    };
  }

  factory EventModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    final Timestamp? dateTs = data['date'] as Timestamp?;
    final String rawStatus = (data['status'] as String?) ?? 'DUO';
    final String normalized = rawStatus.replaceAll('EventStatus.', '').toUpperCase();
    return EventModel(
      id: doc.id,
      title: (data['title'] as String?) ?? '',
      date: (dateTs?.toDate()) ?? DateTime.now(),
      location: (data['location'] as String?) ?? '',
      description: (data['description'] as String?) ?? '',
      status: normalized == 'GROUP' ? EventStatus.GROUP : EventStatus.DUO,
      creatorId: (data['creatorId'] as String?) ?? '',
      imageUrl: data['imageUrl'] as String?,
      costCovered: (data['costCovered'] as bool?) ?? false,
      maxParticipants: (data['maxParticipants'] as num?)?.toInt(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }
}


