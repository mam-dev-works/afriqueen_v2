import 'dart:convert';
import 'package:equatable/equatable.dart';

class BlockedModel extends Equatable {
  final String id;
  final List<String> blockedUserId;

  BlockedModel({
    required this.id,
    required this.blockedUserId,
  });

  @override
  List<Object> get props => [id, blockedUserId];

  BlockedModel copyWith({
    String? id,
    List<String>? blockedUserId,
  }) {
    return BlockedModel(
      id: id ?? this.id,
      blockedUserId: blockedUserId ?? this.blockedUserId,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'blockedUserId': blockedUserId,
    };
  }

  factory BlockedModel.fromMap(Map<String, dynamic> map) {
    return BlockedModel(
      id: map['id'] as String,
      blockedUserId: List<String>.from(map['blockedUserId'] ?? []),
    );
  }

  String toJson() => json.encode(toMap());

  factory BlockedModel.fromJson(String source) =>
      BlockedModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool get stringify => true;

  static BlockedModel empty = BlockedModel(id: '', blockedUserId: []);
} 