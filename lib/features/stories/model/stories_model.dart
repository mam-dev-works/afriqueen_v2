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

  @override
  List<Object> get props => [uid, containUrl, createdDate, userName, userImg];

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

  const StoriesFetchModel({
    required this.id,
    required this.containUrl,
    required this.createdDate,
    required this.userName,
    required this.userImg,
  });

  StoriesFetchModel copyWith({
    String? id,
    List<String>? containUrl,
    List<DateTime>? createdDate,
    String? userName,
    String? userImg,
  }) {
    return StoriesFetchModel(
      id: id ?? this.id,
      containUrl: containUrl ?? this.containUrl,
      createdDate: createdDate ?? this.createdDate,
      userName: userName ?? this.userName,
      userImg: userImg ?? this.userImg,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'containUrl': containUrl,
      'createdDate': createdDate.map((d) => d.millisecondsSinceEpoch).toList(),
      'userName': userName,
      'userImg': userImg,
    };
  }

  factory StoriesFetchModel.fromMap(Map<String, dynamic> map) {
    return StoriesFetchModel(
      id: map['id'] as String,
      containUrl: List<String>.from(map['containUrl'] ?? []),
      createdDate: (map['createdDate'] as List<dynamic>?)?.map((e) {
            if (e is Timestamp) {
              return e.toDate();
            } else if (e is int) {
              return DateTime.fromMillisecondsSinceEpoch(e);
            }
            return DateTime.now(); // fallback
          }).toList() ??
          [],
      userName: map['userName'] as String,
      userImg: map['userImg'] as String,
    );
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
    ];
  }
}
