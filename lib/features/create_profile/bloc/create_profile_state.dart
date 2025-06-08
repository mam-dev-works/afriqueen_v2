import 'package:afriqueen/common/localization/enums/enums.dart';
import 'package:equatable/equatable.dart';
import 'package:get/get.dart';

//----------------Create Profile State----------------------
class CreateProfileState extends Equatable {
  final String gender;
  final DateTime dob;
  final List<String> friendship;
  final List<String> passion;
  final List<String> love;
  final List<String> sports;
  final List<String> food;
  final List<String> adventure;
  final String imgURL;
  final String description;
  const CreateProfileState({
    required this.love,
    required this.sports,
    required this.food,
    required this.adventure,
    required this.imgURL,
    required this.gender,
    required this.dob,
    required this.friendship,
    required this.passion,
    required this.description,
  });

  factory CreateProfileState.initial() {
    return CreateProfileState(
      gender: 'Male',
      dob: DateTime.now(),
      friendship: [],
      passion: [],
      love: [],
      sports: [],
      food: [],
      adventure: [],
      imgURL: '',
      description: '',
    );
  }
  CreateProfileState copyWith({
    String? gender,
    DateTime? dob,
    List<String>? friendship,
    List<String>? passion,
    List<String>? love,
    List<String>? sports,
    List<String>? food,
    List<String>? adventure,
    String? imgURL,
    String? description,
  }) => CreateProfileState(
    gender: gender ?? this.gender,
    dob: dob ?? this.dob,
    friendship: friendship ?? this.friendship,
    passion: passion ?? this.passion,
    love: love ?? this.love,
    sports: sports ?? this.sports,
    food: food ?? this.food,
    adventure: adventure ?? this.adventure,
    imgURL: imgURL ?? this.imgURL,
    description: description ?? this.description,
  );
  @override
  List<Object> get props => [
    gender,
    friendship,
    dob,
    passion,
    love,
    sports,
    food,
    adventure,
    imgURL,
    description,
  ];
}

final class CreateProfileInitial extends CreateProfileState {
  CreateProfileInitial()
    : super(
        gender: EnumLocale.genderMale.name.tr,
        dob: DateTime.now(),
        friendship: [],
        passion: [],
        love: [],
        sports: [],
        food: [],
        imgURL: '',
        adventure: [],
        description: '',
      );
}

final class Loading extends CreateProfileState {
  Loading.fromState(CreateProfileState state)
    : super(
        gender: state.gender,
        dob: state.dob,
        friendship: state.friendship,
        passion: state.passion,
        love: state.love,
        sports: state.sports,
        food: state.food,
        imgURL: state.imgURL,
        adventure: state.adventure,
        description: '',
      );
}

final class Success extends CreateProfileState {
  Success.fromState(CreateProfileState state)
    : super(
        gender: state.gender,
        dob: state.dob,
        friendship: state.friendship,
        passion: state.passion,
        love: state.love,
        sports: state.sports,
        food: state.food,
        imgURL: state.imgURL,
        adventure: state.adventure,
        description: state.description,
      );
}

final class Error extends CreateProfileState {
  final String errorMessage;

  Error.fromState(CreateProfileState state, {required this.errorMessage})
    : super(
        gender: state.gender,
        dob: state.dob,
        friendship: state.friendship,
        passion: state.passion,
        love: state.love,
        sports: state.sports,
        food: state.food,
        imgURL: state.imgURL,
        adventure: state.adventure,
        description: state.description,
      );

  @override
  List<Object> get props => [errorMessage];
}
