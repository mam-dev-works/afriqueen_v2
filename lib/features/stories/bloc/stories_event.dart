

import 'package:equatable/equatable.dart';

sealed class StoriesEvent extends Equatable {
  const StoriesEvent();

  @override
  List<Object> get props => [];
}

final class StoriesFetching extends StoriesEvent {}

final class StoriesImage extends StoriesEvent {
final  String name;
final  String img;
StoriesImage({required this.name, required this.img});
}




