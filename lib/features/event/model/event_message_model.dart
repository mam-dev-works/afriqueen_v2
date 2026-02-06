import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class EventMessageModel extends Equatable {
  final String id;
  final String eventId;
  final String senderId;
  final String senderName;
  final String senderPhotoUrl;
  final String content;
  final DateTime timestamp;
  final String eventTitle;
  final String eventImageUrl;
  final bool isEventFinished;
  final String eventStatus; // "GROUP" or "DUO"

  const EventMessageModel({
    required this.id,
    required this.eventId,
    required this.senderId,
    required this.senderName,
    required this.senderPhotoUrl,
    required this.content,
    required this.timestamp,
    required this.eventTitle,
    required this.eventImageUrl,
    required this.isEventFinished,
    required this.eventStatus,
  });

  Map<String, dynamic> toJson() {
    return {
      'eventId': eventId,
      'senderId': senderId,
      'senderName': senderName,
      'senderPhotoUrl': senderPhotoUrl,
      'content': content,
      'timestamp': Timestamp.fromDate(timestamp),
      'eventTitle': eventTitle,
      'eventImageUrl': eventImageUrl,
      'isEventFinished': isEventFinished,
      'eventStatus': eventStatus,
    };
  }

  factory EventMessageModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    final timestamp = (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();
    
    return EventMessageModel(
      id: doc.id,
      eventId: data['eventId'] ?? '',
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? '',
      senderPhotoUrl: data['senderPhotoUrl'] ?? '',
      content: data['content'] ?? '',
      timestamp: timestamp,
      eventTitle: data['eventTitle'] ?? '',
      eventImageUrl: data['eventImageUrl'] ?? '',
      isEventFinished: data['isEventFinished'] ?? false,
      eventStatus: data['eventStatus'] ?? 'GROUP',
    );
  }

  @override
  List<Object?> get props => [
        id,
        eventId,
        senderId,
        senderName,
        senderPhotoUrl,
        content,
        timestamp,
        eventTitle,
        eventImageUrl,
        isEventFinished,
        eventStatus,
      ];
}
