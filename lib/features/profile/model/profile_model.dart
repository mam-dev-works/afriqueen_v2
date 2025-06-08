// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class ProfileModel extends Equatable {
  final String id;
  final String pseudo;
  final String sex;
  final int age;
  final String country;
  final String city;

  final List<String> interests;
  final DateTime createdDate;
  final String imgURL;
  final String description;
  const ProfileModel({
    required this.id,
    required this.pseudo,
    required this.sex,
    required this.age,
    required this.country,
    required this.city,

    required this.interests,
    required this.createdDate,
    required this.imgURL,
    required this.description,
  });

  ProfileModel copyWith({
    String? id,
    String? pseudo,
    String? sex,
    int? age,
    String? country,
    String? city,

    List<String>? interests,
    DateTime? createdDate,
    String? imgURL,
    String? description,
  }) {
    return ProfileModel(
      id: id ?? this.id,
      pseudo: pseudo ?? this.pseudo,
      sex: sex ?? this.sex,
      age: age ?? this.age,
      country: country ?? this.country,
      city: city ?? this.city,

      interests: interests ?? this.interests,
      createdDate: createdDate ?? this.createdDate,
      imgURL: imgURL ?? this.imgURL,
      description: description ?? this.description,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'pseudo': pseudo,
      'sex': sex,
      'age': age,
      'country': country,
      'city': city,

      'interests': interests,
      'createdDate': createdDate.millisecondsSinceEpoch,
      'imgURL': imgURL,
      'description': description,
    };
  }

  factory ProfileModel.fromMap(Map<String, dynamic> map) {
    return ProfileModel(
      id: map['id'] as String,
      pseudo: map['pseudo'] as String,
      sex: map['sex'] as String,
      age: map['age'] as int,
      country: map['country'] as String,
      city: map['city'] as String,

      interests: List<String>.from(map['interests'] ?? []),
      createdDate:
          (map['createdDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      imgURL: map['imgURL'] as String,
      description: map['description'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory ProfileModel.fromJson(String source) =>
      ProfileModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool get stringify => true;

  @override
  List<Object> get props {
    return [
      id,
      pseudo,
      sex,
      age,
      country,
      city,

      interests,
      createdDate,
      imgURL,
      description,
    ];
  }

  // Add this static constant
  static final ProfileModel empty = ProfileModel(
    id: '',
    pseudo: '',
    sex: '',
    age: 0,
    country: '',
    city: '',

    interests: const [],
    createdDate: DateTime(0), // Or a fixed date like DateTime(0) if preferred
    imgURL: '',
    description: '',
  );
}
