import 'package:equatable/equatable.dart';

sealed class CreateProfileEvent extends Equatable {
  const CreateProfileEvent();

  @override
  List<Object> get props => [];
}

final class PseudoChanged extends CreateProfileEvent {
  final String pseudo;

  const PseudoChanged({required this.pseudo});
  @override
  List<Object> get props => [pseudo];
}

final class GenderChanged extends CreateProfileEvent {
  final String gender;

  const GenderChanged({required this.gender});
  @override
  List<Object> get props => [gender];
}

final class OrientationChanged extends CreateProfileEvent {
  final String orientation;

  const OrientationChanged({required this.orientation});
  @override
  List<Object> get props => [orientation];
}

final class RelationshipStatusChanged extends CreateProfileEvent {
  final String status;

  const RelationshipStatusChanged({required this.status});
  @override
  List<Object> get props => [status];
}

final class DobChanged extends CreateProfileEvent {
  final DateTime dob;

  const DobChanged({required this.dob});
  @override
  List<Object> get props => [dob];
}

final class AddressChanged extends CreateProfileEvent {
  final String country;
  final String city;

  const AddressChanged({required this.country, required this.city});
  @override
  List<Object> get props => [country, city];
}

final class FriendsShipChanged extends CreateProfileEvent {
  final List<String> friendship;

  const FriendsShipChanged({required this.friendship});
  @override
  List<Object> get props => [friendship];
}

final class PassionChanged extends CreateProfileEvent {
  final List<String> passion;

  const PassionChanged({required this.passion});
  @override
  List<Object> get props => [passion];
}

final class LoveChanged extends CreateProfileEvent {
  final List<String> love;

  const LoveChanged({required this.love});
  @override
  List<Object> get props => [love];
}

final class SportChanged extends CreateProfileEvent {
  final List<String> sports;

  const SportChanged({required this.sports});
  @override
  List<Object> get props => [sports];
}

final class FoodChanged extends CreateProfileEvent {
  final List<String> food;

  const FoodChanged({required this.food});
  @override
  List<Object> get props => [food];
}

final class AdventureChanged extends CreateProfileEvent {
  final List<String> adventure;

  const AdventureChanged({required this.adventure});
  @override
  List<Object> get props => [adventure];
}

final class PickImg extends CreateProfileEvent {}

final class SubmitButtonClicked extends CreateProfileEvent {}

final class DescriptionChanged extends CreateProfileEvent {
  final String description;

  const DescriptionChanged({required this.description});
  @override
  List<Object> get props => [description];
}

final class ResetCreateProfileEvent extends CreateProfileEvent {}

final class CreateCompleteProfile extends CreateProfileEvent {
  final String name;
  final String description;
  final DateTime dob;
  final String gender;
  final String orientation;
  final String relationshipStatus;
  final String country;
  final String city;
  final List<String> mainInterests;
  final List<String> secondaryInterests;
  final List<String> passions;
  final List<String> photos;
  final int height;
  final int silhouette;
  final List<String> ethnicOrigins;
  final List<String> religions;
  final List<String> qualities;
  final List<String> flaws;
  final int hasChildren;
  final int wantsChildren;
  final int hasAnimals;
  final List<String> languages;
  final List<String> educationLevels;
  final int alcohol;
  final int smoking;
  final int snoring;
  final List<String> hobbies;
  final String searchDescription;
  final String whatLookingFor;
  final String whatNotWant;

  const CreateCompleteProfile({
    required this.name,
    required this.description,
    required this.dob,
    required this.gender,
    required this.orientation,
    required this.relationshipStatus,
    required this.country,
    required this.city,
    required this.mainInterests,
    required this.secondaryInterests,
    required this.passions,
    required this.photos,
    required this.height,
    required this.silhouette,
    required this.ethnicOrigins,
    required this.religions,
    required this.qualities,
    required this.flaws,
    required this.hasChildren,
    required this.wantsChildren,
    required this.hasAnimals,
    required this.languages,
    required this.educationLevels,
    required this.alcohol,
    required this.smoking,
    required this.snoring,
    required this.hobbies,
    required this.searchDescription,
    required this.whatLookingFor,
    required this.whatNotWant,
  });

  @override
  List<Object> get props => [
    name,
    description,
    dob,
    gender,
    orientation,
    relationshipStatus,
    country,
    city,
    mainInterests,
    secondaryInterests,
    passions,
    photos,
    height,
    silhouette,
    ethnicOrigins,
    religions,
    qualities,
    flaws,
    hasChildren,
    wantsChildren,
    hasAnimals,
    languages,
    educationLevels,
    alcohol,
    smoking,
    snoring,
    hobbies,
    searchDescription,
    whatLookingFor,
    whatNotWant,
  ];
}
