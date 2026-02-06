import 'package:equatable/equatable.dart';

sealed class ArchiveEvent extends Equatable {
  const ArchiveEvent();

  @override
  List<Object> get props => [];
}

//-----------------------------Fav Event-----------------------------
final class ArchiveUserAdded extends ArchiveEvent {
  final String archiveId;
  ArchiveUserAdded({required this.archiveId});
}

final class ArchiveUserRemoved extends ArchiveEvent {
  final String archiveId;
  ArchiveUserRemoved({required this.archiveId});
}

final class ArchiveUsersFetched extends ArchiveEvent {}
