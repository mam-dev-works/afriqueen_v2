import 'package:equatable/equatable.dart';

class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object> get props => [];
}

final class HomeUsersFetched extends HomeEvent {}
final class  HomeUsersProfileList  extends HomeEvent {
  
}
