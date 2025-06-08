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
