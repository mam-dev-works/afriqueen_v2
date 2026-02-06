import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel {
  final String id;
  final List<Map<String, dynamic>> participants;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final int unreadCount;
  final bool isRequest;
  final bool isDeclined;
  final String? status;
  final String? lastMessageSenderId;

  ChatModel({
    required this.id,
    required this.participants,
    this.lastMessage,
    this.lastMessageTime,
    this.unreadCount = 0,
    this.isRequest = false,
    this.isDeclined = false,
    this.status,
    this.lastMessageSenderId,
  });

  factory ChatModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    final participantInfo = Map<String, dynamic>.from(data['participantInfo'] ?? {});
    final participants = List<String>.from(data['participants'] ?? []);
    
    List<Map<String, dynamic>> participantDetails = [];
    for (var participantId in participants) {
      if (participantInfo.containsKey(participantId)) {
        participantDetails.add(Map<String, dynamic>.from(participantInfo[participantId]));
      }
    }

    return ChatModel(
      id: doc.id,
      participants: participantDetails,
      lastMessage: data['lastMessage'] as String?,
      lastMessageTime: (data['lastMessageTime'] as Timestamp?)?.toDate(),
      unreadCount: data['unreadCount'] as int? ?? 0,
      isRequest: data['isRequest'] as bool? ?? false,
      isDeclined: data['isDeclined'] as bool? ?? false,
      status: data['status'] as String?,
      lastMessageSenderId: data['lastMessageSenderId'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'participants': participants,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime != null ? Timestamp.fromDate(lastMessageTime!) : null,
      'unreadCount': unreadCount,
      'isRequest': isRequest,
      'isDeclined': isDeclined,
      'status': status,
      'lastMessageSenderId': lastMessageSenderId,
    };
  }

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    final participantInfo = Map<String, dynamic>.from(json['participantInfo'] ?? {});
    final participants = List<String>.from(json['participants'] ?? []);
    
    List<Map<String, dynamic>> participantDetails = [];
    for (var participantId in participants) {
      if (participantInfo.containsKey(participantId)) {
        participantDetails.add(Map<String, dynamic>.from(participantInfo[participantId]));
      }
    }

    return ChatModel(
      id: json['id'] as String? ?? '',
      participants: participantDetails,
      lastMessage: json['lastMessage'] as String?,
      lastMessageTime: (json['lastMessageTime'] as Timestamp?)?.toDate(),
      unreadCount: json['unreadCount'] as int? ?? 0,
      isRequest: json['isRequest'] as bool? ?? false,
      isDeclined: json['isDeclined'] as bool? ?? false,
      status: json['status'] as String?,
      lastMessageSenderId: json['lastMessageSenderId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'participants': participants.map((p) => p['id']).toList(),
      'participantInfo': Map.fromEntries(
        participants.map((p) => MapEntry(p['id'], p)),
      ),
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime != null ? Timestamp.fromDate(lastMessageTime!) : null,
      'unreadCount': unreadCount,
      'isRequest': isRequest,
      'isDeclined': isDeclined,
      'status': status,
      'lastMessageSenderId': lastMessageSenderId,
    };
  }
} 