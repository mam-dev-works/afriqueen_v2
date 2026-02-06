import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType {
  text,
  image,
  voice,
}

class MessageModel {
  final String id;
  final String senderId;
  final String receiverId;
  final String content;
  final DateTime timestamp;
  final MessageType type;
  final String? imageUrl;
  final String? audioUrl;
  final int? audioDuration;
  final String? duration;
  final bool isRead;
  final bool isUploaded;
  final String? tempId;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.timestamp,
    required this.type,
    this.imageUrl,
    this.audioUrl,
    this.audioDuration,
    this.duration,
    this.isRead = false,
    this.isUploaded = true,
    this.tempId,
  });

  MessageModel copyWith({
    String? id,
    String? senderId,
    String? receiverId,
    String? content,
    DateTime? timestamp,
    MessageType? type,
    String? imageUrl,
    String? audioUrl,
    int? audioDuration,
    String? duration,
    bool? isRead,
    bool? isUploaded,
    String? tempId,
  }) {
    return MessageModel(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      imageUrl: imageUrl ?? this.imageUrl,
      audioUrl: audioUrl ?? this.audioUrl,
      audioDuration: audioDuration ?? this.audioDuration,
      duration: duration ?? this.duration,
      isRead: isRead ?? this.isRead,
      isUploaded: isUploaded ?? this.isUploaded,
      tempId: tempId ?? this.tempId,
    );
  }

  factory MessageModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return MessageModel(
      id: doc.id,
      senderId: data['senderId'] ?? '',
      receiverId: data['receiverId'] ?? '',
      content: data['content'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      type: MessageType.values.firstWhere(
        (e) => e.toString() == 'MessageType.${data['type']}',
        orElse: () => MessageType.text,
      ),
      imageUrl: data['imageUrl'] as String?,
      audioUrl: data['audioUrl'] as String?,
      audioDuration: data['audioDuration'] as int?,
      duration: data['duration'] as String?,
      isRead: data['isRead'] ?? false,
      isUploaded: data['isUploaded'] ?? true,
      tempId: data['tempId'] as String?,
    );
  }

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    DateTime timestamp;
    if (map['timestamp'] is Timestamp) {
      timestamp = (map['timestamp'] as Timestamp).toDate();
    } else if (map['timestamp'] is int) {
      timestamp = DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int);
    } else {
      timestamp = DateTime.now();
    }

    return MessageModel(
      id: map['id'] ?? '',
      senderId: map['senderId'] ?? '',
      receiverId: map['receiverId'] ?? '',
      content: map['content'] ?? '',
      timestamp: timestamp,
      type: MessageType.values.firstWhere(
        (e) => e.toString() == map['type'],
        orElse: () => MessageType.text,
      ),
      imageUrl: map['imageUrl'],
      audioUrl: map['audioUrl'],
      audioDuration: map['audioDuration'],
      duration: map['duration'] as String?,
      isRead: map['isRead'] ?? false,
      isUploaded: map['isUploaded'] ?? true,
      tempId: map['tempId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
      'timestamp': Timestamp.fromDate(timestamp),
      'type': type.toString(),
      'imageUrl': imageUrl,
      'audioUrl': audioUrl,
      'audioDuration': audioDuration,
      'duration': duration,
      'isRead': isRead,
      'isUploaded': isUploaded,
      'tempId': tempId,
    };
  }

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as String,
      senderId: json['senderId'] as String,
      receiverId: json['receiverId'] as String,
      content: json['content'] as String,
      timestamp: (json['timestamp'] as Timestamp).toDate(),
      type: MessageType.values.firstWhere(
        (e) => e.toString() == 'MessageType.${json['type']}',
        orElse: () => MessageType.text,
      ),
      imageUrl: json['imageUrl'] as String?,
      audioUrl: json['audioUrl'] as String?,
      audioDuration: json['audioDuration'] as int?,
      duration: json['duration'] as String?,
      isRead: json['isRead'] as bool? ?? false,
      isUploaded: json['isUploaded'] as bool? ?? true,
      tempId: json['tempId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
      'timestamp': Timestamp.fromDate(timestamp),
      'type': type.toString().split('.').last,
      'imageUrl': imageUrl,
      'audioUrl': audioUrl,
      'audioDuration': audioDuration,
      'duration': duration,
      'isRead': isRead,
      'isUploaded': isUploaded,
      'tempId': tempId,
    };
  }
} 