import '../model/edit_profile_model.dart';
import 'package:equatable/equatable.dart';

abstract class EditProfileEvent extends Equatable {
  const EditProfileEvent();
  @override
  List<Object?> get props => [];
}

class LoadProfile extends EditProfileEvent {}

class UpdateProfile extends EditProfileEvent {
  final EditProfileModel model;
  const UpdateProfile(this.model);
  @override
  List<Object?> get props => [model];
} 