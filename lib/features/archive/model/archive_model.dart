import 'dart:convert';

import 'package:equatable/equatable.dart';

class ArchiveModel extends Equatable {
  final String id;
  final List<String> archiveId;

  ArchiveModel({
    required this.id,
    required this.archiveId,
  });

  @override
  List<Object> get props => [id, archiveId];

  ArchiveModel copyWith({
    String? id,
    List<String>? archiveId,
  }) {
    return ArchiveModel(
      id: id ?? this.id,
      archiveId: archiveId ?? this.archiveId,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'archiveId': archiveId,
    };
  }

  factory ArchiveModel.fromMap(Map<String, dynamic> map) {
    return ArchiveModel(
      id: map['id'] as String,
      archiveId: List<String>.from(map['archiveId'] ?? []),
    );
  }

  String toJson() => json.encode(toMap());

  factory ArchiveModel.fromJson(String source) =>
      ArchiveModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool get stringify => true;

  static ArchiveModel empty = ArchiveModel(id: '', archiveId: []);
}
