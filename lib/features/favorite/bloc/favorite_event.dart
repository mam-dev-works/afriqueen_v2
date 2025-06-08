import 'package:equatable/equatable.dart';

sealed class FavoriteEvent extends Equatable {
  const FavoriteEvent();

  @override
  List<Object> get props => [];
}

//-----------------------------Fav Event-----------------------------
final class FavoriteUserAdded extends FavoriteEvent {
  final String favId;
  FavoriteUserAdded({required this.favId});
}

final class FavoriteUserRemoved extends FavoriteEvent {
  final String favId;
  FavoriteUserRemoved({required this.favId});
}

final class FavoriteUsersFetched extends FavoriteEvent {}
