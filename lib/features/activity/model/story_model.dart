import 'package:cloud_firestore/cloud_firestore.dart';

class StoryModel {
  final String id;
  final DateTime? createdDate;
  final String imageUrl;
  final String text;
  final String uid; // owner id
  final String userImg;
  final String userName;

  StoryModel({
    required this.id,
    required this.createdDate,
    required this.imageUrl,
    required this.text,
    required this.uid,
    required this.userImg,
    required this.userName,
  });

  factory StoryModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return StoryModel(
      id: doc.id,
      createdDate: (data['createdDate'] is Timestamp)
          ? (data['createdDate'] as Timestamp).toDate()
          : null,
      imageUrl: (data['imageUrl'] as String?) ?? '',
      text: (data['text'] as String?) ?? '',
      uid: (data['uid'] as String?) ?? '',
      userImg: (data['userImg'] as String?) ?? '',
      userName: (data['userName'] as String?) ?? '',
    );
  }
}


