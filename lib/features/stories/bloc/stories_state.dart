import 'package:equatable/equatable.dart';

import 'package:afriqueen/features/stories/model/stories_model.dart';

class StoriesState extends Equatable {
  final List<StoriesFetchModel> data;
  const StoriesState({required this.data});

  StoriesState copyWith({List<StoriesFetchModel>? data}) =>
      StoriesState(data: data ?? this.data);

  factory StoriesState.initial() {
    return StoriesState(data: []);
  }
  @override
  List<Object> get props => [data];
}

final class StoriesInitial extends StoriesState {
  StoriesInitial() : super(data: []);
}

final class StoriesError extends StoriesState {
  final String errorMessage;
  StoriesError.fromState(StoriesState state, {required this.errorMessage})
      : super(data: state.data);
}

final class StoriesFetchSuccss extends StoriesState {
  StoriesFetchSuccss.fromState(
    StoriesState state,
  ) : super(data: state.data);
}
