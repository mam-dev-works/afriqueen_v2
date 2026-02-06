import 'package:cloud_firestore/cloud_firestore.dart';

class MessageRequestModel {
  final String id;
  final String senderId;
  final String receiverId;
  final String content;
  final DateTime timestamp;
  final String senderName;
  final String? senderPhotoUrl;
  final bool isRead;
  final bool isAccepted;
  final bool isRejected;

  MessageRequestModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.timestamp,
    required this.senderName,
    this.senderPhotoUrl,
    this.isRead = false,
    this.isAccepted = false,
    this.isRejected = false,
  });

  factory MessageRequestModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return MessageRequestModel(
      id: doc.id,
      senderId: data['senderId'] ?? '',
      receiverId: data['receiverId'] ?? '',
      content: data['content'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      senderName: data['senderName'] ?? '',
      senderPhotoUrl: data['senderPhotoUrl'] as String?,
      isRead: data['isRead'] ?? false,
      isAccepted: data['isAccepted'] ?? false,
      isRejected: data['isRejected'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
      'timestamp': Timestamp.fromDate(timestamp),
      'senderName': senderName,
      'senderPhotoUrl': senderPhotoUrl,
      'isRead': isRead,
      'isAccepted': isAccepted,
      'isRejected': isRejected,
    };
  }

  MessageRequestModel copyWith({
    String? id,
    String? senderId,
    String? receiverId,
    String? content,
    DateTime? timestamp,
    String? senderName,
    String? senderPhotoUrl,
    bool? isRead,
    bool? isAccepted,
    bool? isRejected,
  }) {
    return MessageRequestModel(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      senderName: senderName ?? this.senderName,
      senderPhotoUrl: senderPhotoUrl ?? this.senderPhotoUrl,
      isRead: isRead ?? this.isRead,
      isAccepted: isAccepted ?? this.isAccepted,
      isRejected: isRejected ?? this.isRejected,
    );
  }
} 