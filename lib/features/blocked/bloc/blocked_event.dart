import 'package:equatable/equatable.dart';

sealed class BlockedEvent extends Equatable {
  const BlockedEvent();

  @override
  List<Object> get props => [];
}

//-----------------------------Blocked Event-----------------------------
final class BlockedUserAdded extends BlockedEvent {
  final String blockedUserId;
  BlockedUserAdded({required this.blockedUserId});
}

final class BlockedUserRemoved extends BlockedEvent {
  final String blockedUserId;
  BlockedUserRemoved({required this.blockedUserId});
}

final class BlockedUsersFetched extends BlockedEvent {} 