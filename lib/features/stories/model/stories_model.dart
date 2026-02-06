// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class StoriesModel extends Equatable {
  final String uid;
  final List<String> containUrl;
  final List<DateTime> createdDate;
  final String userName;
  final String userImg;

  const StoriesModel({
    required this.uid,
    required this.containUrl,
    required this.createdDate,
    required this.userName,
    required this.userImg,
  });

  StoriesModel copyWith({
    String? uid,
    List<String>? containUrl,
    List<DateTime>? createdDate,
    String? userName,
    String? userImg,
  }) {
    return StoriesModel(
      uid: uid ?? this.uid,
      containUrl: containUrl ?? this.containUrl,
      createdDate: createdDate ?? this.createdDate,
      userName: userName ?? this.userName,
      userImg: userImg ?? this.userImg,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'uid': uid,
      'containUrl': containUrl,
      'createdDate': createdDate.map((d) => d.millisecondsSinceEpoch).toList(),
      'userName': userName,
      'userImg': userImg,
    };
  }

  factory StoriesModel.fromMap(Map<String, dynamic> map) {
    print('StoriesModel.fromMap: Parsing map: $map');
    
    final String uid = map['uid'] as String? ?? '';
    final String userName = map['userName'] as String? ?? '';
    final String userImg = map['userImg'] as String? ?? '';
    
    // Get containUrl array
    List<String> containUrl = [];
    if (map['containUrl'] != null && map['containUrl'] is List) {
      containUrl = (map['containUrl'] as List).cast<String>();
    }
    
    // Get createdDate array
    List<DateTime> createdDate = [];
    if (map['createdDate'] != null && map['createdDate'] is List) {
      final dateList = map['createdDate'] as List;
      for (var date in dateList) {
        if (date is Timestamp) {
          createdDate.add(date.toDate());
        } else if (date is int) {
          createdDate.add(DateTime.fromMillisecondsSinceEpoch(date));
        } else {
          createdDate.add(DateTime.now()); // fallback
        }
      }
    }
    
    final result = StoriesModel(
      uid: uid,
      containUrl: containUrl,
      createdDate: createdDate,
      userName: userName,
      userImg: userImg,
    );
    
    print('StoriesModel.fromMap: Created model - UID: ${result.uid}, UserName: ${result.userName}, ContainUrl: ${result.containUrl}');
    return result;
  }

  String toJson() => json.encode(toMap());

  factory StoriesModel.fromJson(String source) =>
      StoriesModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  List<Object> get props => [uid, containUrl, createdDate, userName, userImg];

  @override
  bool get stringify => true;

  static StoriesModel empty = StoriesModel(
    uid: '',
    containUrl: [],
    createdDate: [],
    userName: '',
    userImg: '',
  );
}

class StoriesFetchModel extends Equatable {
  final String id;
  final List<String> containUrl;
  final List<DateTime> createdDate;
  final String userName;
  final String userImg;
  final String? imageUrl;
  final String? text;
  final String? documentId;

  const StoriesFetchModel({
    required this.id,
    required this.containUrl,
    required this.createdDate,
    required this.userName,
    required this.userImg,
    this.imageUrl,
    this.text,
    this.documentId,
  });

  StoriesFetchModel copyWith({
    String? id,
    List<String>? containUrl,
    List<DateTime>? createdDate,
    String? userName,
    String? userImg,
    String? imageUrl,
    String? text,
    String? documentId,
  }) {
    return StoriesFetchModel(
      id: id ?? this.id,
      containUrl: containUrl ?? this.containUrl,
      createdDate: createdDate ?? this.createdDate,
      userName: userName ?? this.userName,
      userImg: userImg ?? this.userImg,
      imageUrl: imageUrl ?? this.imageUrl,
      text: text ?? this.text,
      documentId: documentId ?? this.documentId,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'containUrl': containUrl,
      'createdDate': createdDate.map((d) => d.millisecondsSinceEpoch).toList(),
      'userName': userName,
      'userImg': userImg,
      'imageUrl': imageUrl,
      'text': text,
      'documentId': documentId,
    };
  }

  factory StoriesFetchModel.fromMap(Map<String, dynamic> map) {
    print('StoriesFetchModel.fromMap: Parsing map: $map');
    
    // Handle both 'id' and 'uid' fields for backward compatibility
    final String id = map['id'] as String? ?? map['uid'] as String? ?? '';
    final String userName = map['userName'] as String? ?? '';
    final String userImg = map['userImg'] as String? ?? '';
    final String? imageUrl = map['imageUrl'] as String?;
    final String? text = map['text'] as String?;
    final String? documentId = map['documentId'] as String?;
    
    // Get containUrl array
    List<String> containUrl = [];
    if (map['containUrl'] != null && map['containUrl'] is List) {
      containUrl = (map['containUrl'] as List).cast<String>();
    }
    
    // Get createdDate array
    List<DateTime> createdDate = [];
    if (map['createdDate'] != null && map['createdDate'] is List) {
      final dateList = map['createdDate'] as List;
      for (var date in dateList) {
        if (date is Timestamp) {
          createdDate.add(date.toDate());
        } else if (date is int) {
          createdDate.add(DateTime.fromMillisecondsSinceEpoch(date));
        } else {
          createdDate.add(DateTime.now()); // fallback
        }
      }
    }
    
    final result = StoriesFetchModel(
      id: id,
      containUrl: containUrl,
      createdDate: createdDate,
      userName: userName,
      userImg: userImg,
      imageUrl: imageUrl,
      text: text,
      documentId: documentId,
    );
    
    print('StoriesFetchModel.fromMap: Created model - ID: ${result.id}, UserName: ${result.userName}, ContainUrl: ${result.containUrl}, ImageUrl: ${result.imageUrl}, Text: ${result.text}');
    return result;
  }

  String toJson() => json.encode(toMap());

  factory StoriesFetchModel.fromJson(String source) =>
      StoriesFetchModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool get stringify => true;

  @override
  List<Object> get props {
    return [
      id,
      containUrl,
      createdDate,
      userName,
      userImg,
      imageUrl ?? '',
      text ?? '',
      documentId ?? '',
    ];
  }

  // Add this static constant
  static final StoriesFetchModel empty = StoriesFetchModel(
    id: '',
    containUrl: [],
    createdDate: [],
    userName: '',
    userImg: '',
    imageUrl: null,
    text: null,
    documentId: null,
  );
}
