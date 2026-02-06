

import 'package:equatable/equatable.dart';
import 'dart:io';

sealed class StoriesEvent extends Equatable {
  const StoriesEvent();

  @override
  List<Object> get props => [];
}

final class StoriesFetching extends StoriesEvent {}

final class StoriesRefresh extends StoriesEvent {}

final class StoriesImage extends StoriesEvent {
  final String name;
  final String img;
  final File imageFile;
  StoriesImage({required this.name, required this.img, required this.imageFile});
}

final class StoriesLikeToggle extends StoriesEvent {
  final String storyId;
  const StoriesLikeToggle({required this.storyId});

  @override
  List<Object> get props => [storyId];
}

final class StoriesCheckLikeStatus extends StoriesEvent {
  final String storyId;
  const StoriesCheckLikeStatus({required this.storyId});

  @override
  List<Object> get props => [storyId];
}

final class StoriesFetchLikedStories extends StoriesEvent {}




