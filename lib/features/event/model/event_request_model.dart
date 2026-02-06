import 'package:cloud_firestore/cloud_firestore.dart';

/// Status of an event participation request
enum EventRequestStatus { PENDING, ACCEPTED, REJECTED }

/// Event participation request model for the `event_requests` Firestore collection
class EventRequestModel {
  EventRequestModel({
    required this.id,
    required this.eventId,
    required this.requesterId,
    required this.eventCreatorId,
    required this.message,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.requesterName,
    this.requesterPhotoUrl,
    this.eventTitle,
  });

  final String id;
  final String eventId;
  final String requesterId;
  final String eventCreatorId;
  final String message;
  final EventRequestStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? requesterName;
  final String? requesterPhotoUrl;
  final String? eventTitle;

  Map<String, dynamic> toJson() {
    return {
      'eventId': eventId,
      'requesterId': requesterId,
      'eventCreatorId': eventCreatorId,
      'message': message,
      'status': status.name, // stores as 'PENDING', 'ACCEPTED', or 'REJECTED'
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : FieldValue.serverTimestamp(),
      'requesterName': requesterName,
      'requesterPhotoUrl': requesterPhotoUrl,
      'eventTitle': eventTitle,
    };
  }

  factory EventRequestModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return EventRequestModel(
      id: doc.id,
      eventId: data['eventId'] ?? '',
      requesterId: data['requesterId'] ?? '',
      eventCreatorId: data['eventCreatorId'] ?? '',
      message: data['message'] ?? '',
      status: EventRequestStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => EventRequestStatus.PENDING,
      ),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null ? (data['updatedAt'] as Timestamp).toDate() : null,
      requesterName: data['requesterName'] as String?,
      requesterPhotoUrl: data['requesterPhotoUrl'] as String?,
      eventTitle: data['eventTitle'] as String?,
    );
  }

  EventRequestModel copyWith({
    String? id,
    String? eventId,
    String? requesterId,
    String? eventCreatorId,
    String? message,
    EventRequestStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? requesterName,
    String? requesterPhotoUrl,
    String? eventTitle,
  }) {
    return EventRequestModel(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      requesterId: requesterId ?? this.requesterId,
      eventCreatorId: eventCreatorId ?? this.eventCreatorId,
      message: message ?? this.message,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      requesterName: requesterName ?? this.requesterName,
      requesterPhotoUrl: requesterPhotoUrl ?? this.requesterPhotoUrl,
      eventTitle: eventTitle ?? this.eventTitle,
    );
  }
}
