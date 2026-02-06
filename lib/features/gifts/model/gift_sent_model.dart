import 'package:cloud_firestore/cloud_firestore.dart';

class GiftSentModel {
  final String id;
  final String senderId;
  final String recipientId;
  final String giftType;
  final String giftName;
  final DateTime sentAt;
  final String? message;
  
  // User information
  final String? senderName;
  final int? senderAge;
  final String? senderPhotoUrl;
  final String? recipientName;
  final int? recipientAge;
  final String? recipientPhotoUrl;

  GiftSentModel({
    required this.id,
    required this.senderId,
    required this.recipientId,
    required this.giftType,
    required this.giftName,
    required this.sentAt,
    this.message,
    this.senderName,
    this.senderAge,
    this.senderPhotoUrl,
    this.recipientName,
    this.recipientAge,
    this.recipientPhotoUrl,
  });

  factory GiftSentModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    print('GiftSentModel: Reading document ${doc.id} with data: $data');
    
    final gift = GiftSentModel(
      id: doc.id,
      senderId: data['senderId'] ?? '',
      recipientId: data['recipientId'] ?? '',
      giftType: data['giftType'] ?? '',
      giftName: data['giftName'] ?? '',
      sentAt: (data['sentAt'] as Timestamp).toDate(),
      message: data['message'],
      senderName: data['senderName'],
      senderAge: data['senderAge'],
      senderPhotoUrl: data['senderPhotoUrl'],
      recipientName: data['recipientName'],
      recipientAge: data['recipientAge'],
      recipientPhotoUrl: data['recipientPhotoUrl'],
    );
    
    print('GiftSentModel: Created model with senderName=${gift.senderName}, senderAge=${gift.senderAge}, recipientName=${gift.recipientName}, recipientAge=${gift.recipientAge}');
    return gift;
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'recipientId': recipientId,
      'giftType': giftType,
      'giftName': giftName,
      'sentAt': Timestamp.fromDate(sentAt),
      'message': message,
      'senderName': senderName,
      'senderAge': senderAge,
      'senderPhotoUrl': senderPhotoUrl,
      'recipientName': recipientName,
      'recipientAge': recipientAge,
      'recipientPhotoUrl': recipientPhotoUrl,
    };
  }

  GiftSentModel copyWith({
    String? id,
    String? senderId,
    String? recipientId,
    String? giftType,
    String? giftName,
    DateTime? sentAt,
    String? message,
    String? senderName,
    int? senderAge,
    String? senderPhotoUrl,
    String? recipientName,
    int? recipientAge,
    String? recipientPhotoUrl,
  }) {
    return GiftSentModel(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      recipientId: recipientId ?? this.recipientId,
      giftType: giftType ?? this.giftType,
      giftName: giftName ?? this.giftName,
      sentAt: sentAt ?? this.sentAt,
      message: message ?? this.message,
      senderName: senderName ?? this.senderName,
      senderAge: senderAge ?? this.senderAge,
      senderPhotoUrl: senderPhotoUrl ?? this.senderPhotoUrl,
      recipientName: recipientName ?? this.recipientName,
      recipientAge: recipientAge ?? this.recipientAge,
      recipientPhotoUrl: recipientPhotoUrl ?? this.recipientPhotoUrl,
    );
  }
}
