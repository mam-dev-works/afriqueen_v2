import 'package:equatable/equatable.dart';

class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object> get props => [];
}

final class HomeUsersFetched extends HomeEvent {}
final class HomeUsersProfileList extends HomeEvent {}
  
final class FetchLikedUsers extends HomeEvent {}
final class FetchFavoriteUsers extends HomeEvent {}
final class FetchArchiveUsers extends HomeEvent {}
final class FetchAllUsers extends HomeEvent {}
