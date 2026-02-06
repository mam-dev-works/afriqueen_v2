import 'package:equatable/equatable.dart';

import 'package:afriqueen/features/stories/model/stories_model.dart';

class StoriesState extends Equatable {
  final List<StoriesFetchModel> data;
  final Map<String, bool> likedStories;
  final List<StoriesFetchModel> likedStoriesList;
  const StoriesState({
    required this.data, 
    this.likedStories = const {},
    this.likedStoriesList = const [],
  });

  StoriesState copyWith({
    List<StoriesFetchModel>? data,
    Map<String, bool>? likedStories,
    List<StoriesFetchModel>? likedStoriesList,
  }) =>
      StoriesState(
        data: data ?? this.data,
        likedStories: likedStories ?? this.likedStories,
        likedStoriesList: likedStoriesList ?? this.likedStoriesList,
      );

  factory StoriesState.initial() {
    return StoriesState(data: [], likedStories: {}, likedStoriesList: []);
  }
  @override
  List<Object> get props => [data, likedStories, likedStoriesList];
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

final class StoriesCreateSuccess extends StoriesState {
  StoriesCreateSuccess.fromState(
    StoriesState state,
  ) : super(data: state.data);
}
