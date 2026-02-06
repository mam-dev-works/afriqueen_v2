import 'package:equatable/equatable.dart';

sealed class MatchEvent extends Equatable {
  const MatchEvent();

  @override
  List<Object> get props => [];
}

final class MatchUsersFetched extends MatchEvent {} 

final class LikeUser extends MatchEvent {
  final String userId;
  const LikeUser({required this.userId});

  @override
  List<Object> get props => [userId];
}

final class CheckLikeStatus extends MatchEvent {
  final String userId;
  const CheckLikeStatus({required this.userId});

  @override
  List<Object> get props => [userId];
}

final class UnlikeUser extends MatchEvent {
  final String userId;
  const UnlikeUser({required this.userId});

  @override
  List<Object> get props => [userId];
}

final class RemoveUserFromMatch extends MatchEvent {
  final String userId;
  const RemoveUserFromMatch({required this.userId});

  @override
  List<Object> get props => [userId];
} 