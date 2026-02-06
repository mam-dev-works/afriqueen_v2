import 'package:afriqueen/features/home/model/home_model.dart';
import 'package:equatable/equatable.dart';

class MatchState extends Equatable {
  final List<HomeModel?> data;
  final Map<String, bool> likedUsers;

  const MatchState({
    this.data = const [],
    this.likedUsers = const {},
  });

  MatchState copyWith({
    List<HomeModel?>? data,
    Map<String, bool>? likedUsers,
  }) {
    return MatchState(
      data: data ?? this.data,
      likedUsers: likedUsers ?? this.likedUsers,
    );
  }

  @override
  List<Object?> get props => [data, likedUsers];
}

final class MatchInitial extends MatchState {}

final class Loading extends MatchState {
  Loading.fromState(MatchState state) : super(data: state.data);
}

final class Error extends MatchState {
  final String error;

  Error.fromState(MatchState state, {required this.error}) : super(data: state.data);

  @override
  List<Object?> get props => [error];
}

final class MatchDataEmpty extends MatchState {
  MatchDataEmpty() : super(data: []);
  
  MatchDataEmpty.fromState(MatchState state) : super(data: [], likedUsers: state.likedUsers);
} 