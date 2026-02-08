import 'package:afriqueen/features/activity/bloc/user_profile_event.dart';
import 'package:afriqueen/features/activity/bloc/user_profile_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../model/user_profile_model.dart';
import '../repository/user_profile_repository.dart';
import '../model/story_model.dart';

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

  Future<void> _onLoadAllUsers(
      LoadAllUsers event, Emitter<UserProfileState> emit) async {
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

  Future<void> _onLoadViewedUsers(
      LoadViewedUsers event, Emitter<UserProfileState> emit) async {
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

  Future<void> _onLoadUsersIViewed(
      LoadUsersIViewed event, Emitter<UserProfileState> emit) async {
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

  Future<void> _onMarkUserAsViewed(
      MarkUserAsViewed event, Emitter<UserProfileState> emit) async {
    try {
      await _repository.markUserAsViewed(event.userId);
    } catch (e) {
      emit(UserProfileError(e.toString()));
    }
  }

  Future<void> _onLoadLikedUsers(
      LoadLikedUsers event, Emitter<UserProfileState> emit) async {
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

  Future<void> _onLoadUsersILiked(
      LoadUsersILiked event, Emitter<UserProfileState> emit) async {
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

  Future<void> _onLoadStoryLikedUsers(
      LoadStoryLikedUsers event, Emitter<UserProfileState> emit) async {
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

  Future<void> _onLoadUsersILikedStory(
      LoadUsersILikedStory event, Emitter<UserProfileState> emit) async {
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

  Future<void> _onLoadMyStories(
      LoadMyStories event, Emitter<UserProfileState> emit) async {
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

  Future<void> _onRemoveUserFromViewed(
      RemoveUserFromViewed event, Emitter<UserProfileState> emit) async {
    try {
      await _repository.removeUserFromViewed(event.userId);
    } catch (e) {
      emit(UserProfileError(e.toString()));
    }
  }
}
