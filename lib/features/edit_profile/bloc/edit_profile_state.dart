import '../model/edit_profile_model.dart';
import 'package:equatable/equatable.dart';

abstract class EditProfileState extends Equatable {
  const EditProfileState();
  @override
  List<Object?> get props => [];
}

class EditProfileInitial extends EditProfileState {}

class EditProfileLoading extends EditProfileState {}

class EditProfileLoaded extends EditProfileState {
  final EditProfileModel model;
  const EditProfileLoaded(this.model);
  @override
  List<Object?> get props => [model];
}

class EditProfileError extends EditProfileState {
  final String message;
  const EditProfileError(this.message);
  @override
  List<Object?> get props => [message];
}

class EditProfileSuccess extends EditProfileState {} 