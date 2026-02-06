// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:equatable/equatable.dart';

class StatusModel extends Equatable {
  final bool state;
  final int lastChanged;

  const StatusModel({required this.state, required this.lastChanged});

  StatusModel copyWith({bool? state, int? lastChanged}) {
    return StatusModel(
      state: state ?? this.state,
      lastChanged: lastChanged ?? this.lastChanged,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'state': state, 'last_changed': lastChanged};
  }

  factory StatusModel.fromMap(Map<String, dynamic> map) {
    return StatusModel(
      state: map['state'] as bool,
      lastChanged: map['last_changed'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory StatusModel.fromJson(String source) =>
      StatusModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'StatusModel(state: $state, last_changed: $lastChanged)';

  @override
  bool operator ==(covariant StatusModel other) {
    if (identical(this, other)) return true;

    return other.state == state && other.lastChanged == lastChanged;
  }

  @override
  int get hashCode => state.hashCode ^ lastChanged.hashCode;

  @override
  List<Object?> get props => [state, lastChanged];

  static StatusModel empty = StatusModel(state: false, lastChanged: 0);
}
