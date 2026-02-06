import 'package:afriqueen/common/localization/enums/enums.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import '../repository/edit_profile_repository.dart';
import 'edit_profile_event.dart';
import 'edit_profile_state.dart';

class EditProfileBloc extends Bloc<EditProfileEvent, EditProfileState> {
  final EditProfileRepository repository;
  EditProfileBloc({required this.repository}) : super(EditProfileInitial()) {
    on<LoadProfile>(_onLoadProfile);
    on<UpdateProfile>(_onUpdateProfile);
  }

  Future<void> _onLoadProfile(
    LoadProfile event,
    Emitter<EditProfileState> emit,
  ) async {
    emit(EditProfileLoading());
    try {
      final model = await repository.getProfile();
      if (model != null) {
        emit(EditProfileLoaded(model));
      } else {
        emit(EditProfileError(EnumLocale.noDataAvailable.name.tr));
      }
    } catch (e) {
      emit(EditProfileError(e.toString()));
    }
  }

  Future<void> _onUpdateProfile(
    UpdateProfile event,
    Emitter<EditProfileState> emit,
  ) async {
    emit(EditProfileLoading());
    try {
      await repository.updateProfile(event.model);
      emit(EditProfileSuccess());
      // Optionally reload profile after update
      add(LoadProfile());
    } catch (e) {
      emit(EditProfileError(e.toString()));
    }
  }
} 