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
