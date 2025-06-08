// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:convert';

import 'package:equatable/equatable.dart';

class FavoriteModel extends Equatable {
  final String id;
  final List<String> favId;

  FavoriteModel({
    required this.id,
    required this.favId,
  });

  @override
  List<Object> get props => [id, favId];

  FavoriteModel copyWith({
    String? id,
    List<String>? favId,
  }) {
    return FavoriteModel(
      id: id ?? this.id,
      favId: favId ?? this.favId,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'favId': favId,
    };
  }

  factory FavoriteModel.fromMap(Map<String, dynamic> map) {
    return FavoriteModel(
      id: map['id'] as String,
      favId: List<String>.from(map['favId'] ?? []),
    );
  }

  String toJson() => json.encode(toMap());

  factory FavoriteModel.fromJson(String source) =>
      FavoriteModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool get stringify => true;

  static FavoriteModel empty = FavoriteModel(id: '', favId: []);
}
