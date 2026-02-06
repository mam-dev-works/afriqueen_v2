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

    //-------------------------- For Orientation-----------------------------
    on<OrientationChanged>((OrientationChanged event, Emitter<CreateProfileState> emit) {
      emit(state.copyWith(orientation: event.orientation));
      _box.write('orientation', event.orientation);
    });

    //-------------------------- For Relationship Status-----------------------------
    on<RelationshipStatusChanged>((RelationshipStatusChanged event, Emitter<CreateProfileState> emit) {
      emit(state.copyWith(relationshipStatus: event.status));
      _box.write('relationshipStatus', event.status);
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
    on<SubmitButtonClicked>((SubmitButtonClicked event, Emitter<CreateProfileState> emit) async {
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
            // New fields with default values
            name: _box.read('pseudo') ?? '',
            dob: state.dob,
            gender: state.gender,
            orientation: state.orientation ?? '',
            relationshipStatus: state.relationshipStatus ?? '',
            mainInterests: [],
            secondaryInterests: [],
            passions: [],
            photos: [secureUrl],
            height: 170,
            silhouette: 0,
            ethnicOrigins: [],
            religions: [],
            qualities: [],
            flaws: [],
            hasChildren: -1,
            wantsChildren: -1,
            hasAnimals: -1,
            languages: [],
            educationLevels: [],
            alcohol: -1,
            smoking: -1,
            snoring: -1,
            hobbies: [],
            searchDescription: '',
            whatLookingFor: '',
            whatNotWant: '',
          );
          await _profileRepository.uploadToFirebase(createProfileModel);
          emit(Success.fromState(state));
          add(ResetCreateProfileEvent());
        }
      } catch (e) {
        emit(Error.fromState(state, errorMessage: e.toString()));
      }
    });

    //------------------------Create complete user profile -------------------------------------
    on<CreateCompleteProfile>((CreateCompleteProfile event, Emitter<CreateProfileState> emit) async {
      try {
        emit(Loading.fromState(state));
        
        // Upload photos to Cloudinary if they exist
        List<String> uploadedPhotoUrls = [];
        if (event.photos.isNotEmpty) {
          uploadedPhotoUrls = await _profileRepository.uploadMultiplePhotosToCloudinary(event.photos);
        }
        
        final CreateProfileModel createProfileModel = CreateProfileModel(
          description: event.description,
          pseudo: event.name,
          sex: event.gender,
          age: DateTime.now().year - event.dob.year,
          country: event.country,
          city: event.city,
          interests: [...event.mainInterests, ...event.secondaryInterests, ...event.passions],
          imgURL: uploadedPhotoUrls.isNotEmpty ? uploadedPhotoUrls.first : '',
          createdDate: DateTime.now(),
          // New fields
          name: event.name,
          dob: event.dob,
          gender: event.gender,
          orientation: event.orientation,
          relationshipStatus: event.relationshipStatus,
          mainInterests: event.mainInterests,
          secondaryInterests: event.secondaryInterests,
          passions: event.passions,
          photos: uploadedPhotoUrls,
          height: event.height,
          silhouette: event.silhouette,
          ethnicOrigins: event.ethnicOrigins,
          religions: event.religions,
          qualities: event.qualities,
          flaws: event.flaws,
          hasChildren: event.hasChildren,
          wantsChildren: event.wantsChildren,
          hasAnimals: event.hasAnimals,
          languages: event.languages,
          educationLevels: event.educationLevels,
          alcohol: event.alcohol,
          smoking: event.smoking,
          snoring: event.snoring,
          hobbies: event.hobbies,
          searchDescription: event.searchDescription,
          whatLookingFor: event.whatLookingFor,
          whatNotWant: event.whatNotWant,
        );
        
        await _profileRepository.createCompleteUserProfile(createProfileModel);
        emit(Success.fromState(state));
        add(ResetCreateProfileEvent());
      } catch (e) {
        emit(Error.fromState(state, errorMessage: e.toString()));
      }
    });

    //------------------------Reset create profile event -------------------------------------
    on<ResetCreateProfileEvent>((ResetCreateProfileEvent event, Emitter<CreateProfileState> emit) {
      _interests.clear();
      _box.remove('pseudo');
      _box.remove('sex');
      _box.remove('age');
      _box.remove('country');
      _box.remove('city');
      _box.remove('friendship');
      _box.remove('passion');
      _box.remove('love');
      _box.remove('sports');
      _box.remove('food');
      _box.remove('adventure');
      _box.remove('description');
    });
  }
}
