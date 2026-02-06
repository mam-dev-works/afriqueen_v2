import 'package:cloud_firestore/cloud_firestore.dart';

enum GiftType {
  heart,
  rose,
  chocolate,
  diamond,
  flower,
  star,
}

class GiftModel {
  final String id;
  final String senderId;
  final String receiverId;
  final String senderName;
  final String? senderPhotoUrl;
  final int senderAge;
  final String? senderLocation;
  final String? senderRelationshipStatus;
  final DateTime? senderLastActive;
  final GiftType giftType;
  final DateTime timestamp;
  final bool isRead;
  final String? message;

  GiftModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.senderName,
    this.senderPhotoUrl,
    required this.senderAge,
    this.senderLocation,
    this.senderRelationshipStatus,
    this.senderLastActive,
    required this.giftType,
    required this.timestamp,
    this.isRead = false,
    this.message,
  });

  factory GiftModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return GiftModel(
      id: doc.id,
      senderId: data['senderId'] ?? '',
      receiverId: data['receiverId'] ?? '',
      senderName: data['senderName'] ?? '',
      senderPhotoUrl: data['senderPhotoUrl'] as String?,
      senderAge: data['senderAge'] ?? 0,
      senderLocation: data['senderLocation'] as String?,
      senderRelationshipStatus: data['senderRelationshipStatus'] as String?,
      senderLastActive: data['senderLastActive'] != null 
          ? (data['senderLastActive'] as Timestamp).toDate() 
          : null,
      giftType: GiftType.values.firstWhere(
        (e) => e.toString() == 'GiftType.${data['giftType']}',
        orElse: () => GiftType.heart,
      ),
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      isRead: data['isRead'] ?? false,
      message: data['message'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'senderName': senderName,
      'senderPhotoUrl': senderPhotoUrl,
      'senderAge': senderAge,
      'senderLocation': senderLocation,
      'senderRelationshipStatus': senderRelationshipStatus,
      'senderLastActive': senderLastActive != null 
          ? Timestamp.fromDate(senderLastActive!) 
          : null,
      'giftType': giftType.toString().split('.').last,
      'timestamp': Timestamp.fromDate(timestamp),
      'isRead': isRead,
      'message': message,
    };
  }

  GiftModel copyWith({
    String? id,
    String? senderId,
    String? receiverId,
    String? senderName,
    String? senderPhotoUrl,
    int? senderAge,
    String? senderLocation,
    String? senderRelationshipStatus,
    DateTime? senderLastActive,
    GiftType? giftType,
    DateTime? timestamp,
    bool? isRead,
    String? message,
  }) {
    return GiftModel(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      senderName: senderName ?? this.senderName,
      senderPhotoUrl: senderPhotoUrl ?? this.senderPhotoUrl,
      senderAge: senderAge ?? this.senderAge,
      senderLocation: senderLocation ?? this.senderLocation,
      senderRelationshipStatus: senderRelationshipStatus ?? this.senderRelationshipStatus,
      senderLastActive: senderLastActive ?? this.senderLastActive,
      giftType: giftType ?? this.giftType,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      message: message ?? this.message,
    );
  }
}
