import 'package:afriqueen/features/create_profile/bloc/create_profile_event.dart';
import 'package:afriqueen/features/create_profile/bloc/create_profile_state.dart';
import 'package:afriqueen/features/create_profile/model/create_profile_model.dart';
import 'package:afriqueen/features/create_profile/repository/create_profile_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../common/localization/enums/enums.dart';

//------------------ Create Profile Bloc-------------------------------------
class CreateProfileBloc extends Bloc<CreateProfileEvent, CreateProfileState> {
  final CreateProfileRepository _profileRepository;
  final _box = GetStorage();
  Set<String> _interests = {};

  CreateProfileBloc({required CreateProfileRepository repository})
    : _profileRepository = repository,
      super(CreateProfileInitial()) {
    //-------------For Pseudo-----------------------
    on<PseudoChanged>((PseudoChanged event, Emitter<CreateProfileState> emit) {
      _box.write('pseudo', event.pseudo);
    });
    //-------------------------- For Gender-----------------------------
    on<GenderChanged>((GenderChanged event, Emitter<CreateProfileState> emit) {
      emit(state.copyWith(gender: event.gender));
      _box.write('sex', event.gender);
    });

    //-------------------------- For Age-----------------------------
    on<DobChanged>((DobChanged event, Emitter<CreateProfileState> emit) {
      //debugPrint("${DateTime.now().year - value.year}");
      emit(state.copyWith(dob: event.dob));

      _box.write('age', DateTime.now().year - event.dob.year);
    });

    //-------------For Address-----------------------
    on<AddressChanged>((
      AddressChanged event,
      Emitter<CreateProfileState> emit,
    ) {
      _box.write('country', event.country);

      _box.write('city', event.city);
    });

    //-----------User Friendship-----------------------
    on<FriendsShipChanged>((
      FriendsShipChanged event,
      Emitter<CreateProfileState> emit,
    ) {
      emit(state.copyWith(friendship: event.friendship));
      _box.write('friendship', event.friendship);
    });

    //-----------User Passion-----------------------
    on<PassionChanged>((
      PassionChanged event,
      Emitter<CreateProfileState> emit,
    ) {
      emit(state.copyWith(passion: event.passion));
      _box.write('passion', event.passion);
    });
    //-----------User Love-----------------------
    on<LoveChanged>((LoveChanged event, Emitter<CreateProfileState> emit) {
      emit(state.copyWith(love: event.love));
      _box.write('love', event.love);
    });
    //-----------User Sports-----------------------
    on<SportChanged>((SportChanged event, Emitter<CreateProfileState> emit) {
      emit(state.copyWith(sports: event.sports));
      _box.write('sports', event.sports);
    });
    //-----------User Food-----------------------
    on<FoodChanged>((FoodChanged event, Emitter<CreateProfileState> emit) {
      emit(state.copyWith(food: event.food));
      _box.write('food', event.food);
    });

    //-----------User Adventure-----------------------
    on<AdventureChanged>((
      AdventureChanged event,
      Emitter<CreateProfileState> emit,
    ) {
      emit(state.copyWith(adventure: event.adventure));
      _box.write('adventure', event.adventure);
    });
    // ---------------For user Image----------------------
    on<PickImg>((PickImg event, Emitter<CreateProfileState> emit) async {
      final path = await _profileRepository.imagePicker();
      // ------------------user picked image path-------------------
      if (path != null) return emit(state.copyWith(imgURL: path));
    });

    //-----------User Description-----------------------
    on<DescriptionChanged>((
      DescriptionChanged event,
      Emitter<CreateProfileState> emit,
    ) {
      emit(state.copyWith(description: event.description));
      _box.write('description', event.description);
    });
    //------------------------user submit data -------------------------------------
    on<SubmitButtonClicked>((
      SubmitButtonClicked event,
      Emitter<CreateProfileState> emit,
    ) async {
      try {
        emit(Loading.fromState(state));
        final secureUrl = await _profileRepository.uploadToCloudinary(
          state.imgURL,
        );
        _interests.addAll(List<String>.from(_box.read('friendship') ?? []));
        _interests.addAll(List<String>.from(_box.read('passion') ?? []));
        _interests.addAll(List<String>.from(_box.read('love') ?? []));
        _interests.addAll(List<String>.from(_box.read('sports') ?? []));
        _interests.addAll(List<String>.from(_box.read('food') ?? []));
        _interests.addAll(List<String>.from(_box.read('adventure') ?? []));

        if (secureUrl != null && _interests.isNotEmpty) {
          final CreateProfileModel createProfileModel = CreateProfileModel(
            description: _box.read('description') ?? '',
            pseudo: _box.read('pseudo') ?? '',
            sex: _box.read('sex') ?? '',
            age: _box.read('age') ?? 0,
            country: _box.read('country') ?? '',
            city: _box.read('city') ?? '',
            interests: _interests.toList(),
            imgURL: secureUrl,
            createdDate: DateTime.now(),
          );
          await _profileRepository.uploadToFirebase(createProfileModel);
          emit(Success.fromState(state));
          add(ResetCreateProfileEvent());
        }
      } catch (e) {
        emit(Error.fromState(state, errorMessage: e.toString()));
      }
    });

    //----------------Reset state-------------------
    on<ResetCreateProfileEvent>((
      ResetCreateProfileEvent event,
      Emitter<CreateProfileState> emit,
    ) {
      emit(CreateProfileInitial());
    });
  }
}
