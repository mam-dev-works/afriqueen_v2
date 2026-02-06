import 'package:flutter_bloc/flutter_bloc.dart';
import '../model/user_profile_model.dart';
import '../repository/user_profile_repository.dart';
import '../model/story_model.dart';

// Events
abstract class UserProfileEvent {}

class LoadAllUsers extends UserProfileEvent {}
class LoadViewedUsers extends UserProfileEvent {}
class LoadUsersIViewed extends UserProfileEvent {}
class LoadLikedUsers extends UserProfileEvent {}
class LoadUsersILiked extends UserProfileEvent {}
class LoadStoryLikedUsers extends UserProfileEvent {}
class LoadUsersILikedStory extends UserProfileEvent {}
class LoadMyStories extends UserProfileEvent {}
class MarkUserAsViewed extends UserProfileEvent {
  final String userId;
  MarkUserAsViewed(this.userId);
}
class RemoveUserFromViewed extends UserProfileEvent {
  final String userId;
  RemoveUserFromViewed(this.userId);
}

// States
abstract class UserProfileState {}

class UserProfileInitial extends UserProfileState {}

class UserProfileLoading extends UserProfileState {}

class UserProfileLoaded extends UserProfileState {
  final List<UserProfileModel> users;
  UserProfileLoaded(this.users);
}

class StoryLoaded extends UserProfileState {
  final List<StoryModel> stories;
  StoryLoaded(this.stories);
}

class UserProfileError extends UserProfileState {
  final String message;
  UserProfileError(this.message);
}

// Bloc
class UserProfileBloc extends Bloc<UserProfileEvent, UserProfileState> {
  final UserProfileRepository _repository;

  UserProfileBloc(this._repository) : super(UserProfileInitial()) {
    on<LoadAllUsers>(_onLoadAllUsers);
    on<LoadViewedUsers>(_onLoadViewedUsers);
    on<LoadUsersIViewed>(_onLoadUsersIViewed);
    on<LoadLikedUsers>(_onLoadLikedUsers);
    on<LoadUsersILiked>(_onLoadUsersILiked);
    on<LoadStoryLikedUsers>(_onLoadStoryLikedUsers);
    on<LoadUsersILikedStory>(_onLoadUsersILikedStory);
    on<LoadMyStories>(_onLoadMyStories);
    on<MarkUserAsViewed>(_onMarkUserAsViewed);
    on<RemoveUserFromViewed>(_onRemoveUserFromViewed);
  }

  Future<void> _onLoadAllUsers(LoadAllUsers event, Emitter<UserProfileState> emit) async {
    emit(UserProfileLoading());
    try {
      await emit.forEach<List<UserProfileModel>>(
        _repository.getAllUsersStream(),
        onData: (users) => UserProfileLoaded(users),
        onError: (error, stackTrace) => UserProfileError(error.toString()),
      );
    } catch (e) {
      emit(UserProfileError(e.toString()));
    }
  }

  Future<void> _onLoadViewedUsers(LoadViewedUsers event, Emitter<UserProfileState> emit) async {
    emit(UserProfileLoading());
    try {
      await emit.forEach<List<UserProfileModel>>(
        _repository.getViewedUsersStream(),
        onData: (users) => UserProfileLoaded(users),
        onError: (error, stackTrace) => UserProfileError(error.toString()),
      );
    } catch (e) {
      emit(UserProfileError(e.toString()));
    }
  }

  Future<void> _onLoadUsersIViewed(LoadUsersIViewed event, Emitter<UserProfileState> emit) async {
    emit(UserProfileLoading());
    try {
      await emit.forEach<List<UserProfileModel>>(
        _repository.getUsersIViewedStream(),
        onData: (users) => UserProfileLoaded(users),
        onError: (error, stackTrace) => UserProfileError(error.toString()),
      );
    } catch (e) {
      emit(UserProfileError(e.toString()));
    }
  }

  Future<void> _onMarkUserAsViewed(MarkUserAsViewed event, Emitter<UserProfileState> emit) async {
    try {
      await _repository.markUserAsViewed(event.userId);
    } catch (e) {
      emit(UserProfileError(e.toString()));
    }
  }

  Future<void> _onLoadLikedUsers(LoadLikedUsers event, Emitter<UserProfileState> emit) async {
    emit(UserProfileLoading());
    try {
      await emit.forEach<List<UserProfileModel>>(
        _repository.getLikedUsersStream(),
        onData: (users) => UserProfileLoaded(users),
        onError: (error, stackTrace) => UserProfileError(error.toString()),
      );
    } catch (e) {
      emit(UserProfileError(e.toString()));
    }
  }

  Future<void> _onLoadUsersILiked(LoadUsersILiked event, Emitter<UserProfileState> emit) async {
    emit(UserProfileLoading());
    try {
      await emit.forEach<List<UserProfileModel>>(
        _repository.getUsersILikedStream(),
        onData: (users) => UserProfileLoaded(users),
        onError: (error, stackTrace) => UserProfileError(error.toString()),
      );
    } catch (e) {
      emit(UserProfileError(e.toString()));
    }
  }

  Future<void> _onLoadStoryLikedUsers(LoadStoryLikedUsers event, Emitter<UserProfileState> emit) async {
    emit(UserProfileLoading());
    try {
      await emit.forEach<List<StoryModel>>(
        _repository.getAllStoriesStream(),
        onData: (stories) => StoryLoaded(stories),
        onError: (error, stackTrace) => UserProfileError(error.toString()),
      );
    } catch (e) {
      emit(UserProfileError(e.toString()));
    }
  }

  Future<void> _onLoadUsersILikedStory(LoadUsersILikedStory event, Emitter<UserProfileState> emit) async {
    emit(UserProfileLoading());
    try {
      await emit.forEach<List<StoryModel>>(
        _repository.getStoriesILikedStream(),
        onData: (stories) => StoryLoaded(stories),
        onError: (error, stackTrace) => UserProfileError(error.toString()),
      );
    } catch (e) {
      emit(UserProfileError(e.toString()));
    }
  }

  Future<void> _onLoadMyStories(LoadMyStories event, Emitter<UserProfileState> emit) async {
    emit(UserProfileLoading());
    try {
      await emit.forEach<List<StoryModel>>(
        _repository.getMyStoriesStream(),
        onData: (stories) => StoryLoaded(stories),
        onError: (error, stackTrace) => UserProfileError(error.toString()),
      );
    } catch (e) {
      emit(UserProfileError(e.toString()));
    }
  }

  Future<void> _onRemoveUserFromViewed(RemoveUserFromViewed event, Emitter<UserProfileState> emit) async {
    try {
      await _repository.removeUserFromViewed(event.userId);
    } catch (e) {
      emit(UserProfileError(e.toString()));
    }
  }
}
