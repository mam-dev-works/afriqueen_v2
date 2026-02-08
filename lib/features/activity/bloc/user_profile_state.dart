// States
import 'package:afriqueen/features/activity/model/story_model.dart';
import 'package:afriqueen/features/activity/model/user_profile_model.dart';

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
