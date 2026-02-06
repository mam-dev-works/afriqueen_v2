import 'package:equatable/equatable.dart';

//-------------------------Profile model for user profile ---------------------------------------
class CreateProfileModel extends Equatable {
  final String pseudo;
  final String sex;
  final int age;
  final String country;
  final String city;
  final List<String> interests;
  final DateTime createdDate;
  final String imgURL;
  final String description;
  
  // New fields from unified profile setup
  final String name;
  final DateTime dob;
  final String gender;
  final String orientation;
  final String relationshipStatus;
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

  const CreateProfileModel({
    required this.description,
    required this.pseudo,
    required this.sex,
    required this.age,
    required this.country,
    required this.city,
    required this.interests,
    required this.imgURL,
    required this.createdDate,
    // New fields
    required this.name,
    required this.dob,
    required this.gender,
    required this.orientation,
    required this.relationshipStatus,
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

  CreateProfileModel copyWith({
    String? pseudo,
    String? sex,
    int? age,
    String? country,
    String? city,
    List<String>? interests,
    String? imgURL,
    String? description,
    DateTime? createdDate,
    // New fields
    String? name,
    DateTime? dob,
    String? gender,
    String? orientation,
    String? relationshipStatus,
    List<String>? mainInterests,
    List<String>? secondaryInterests,
    List<String>? passions,
    List<String>? photos,
    int? height,
    int? silhouette,
    List<String>? ethnicOrigins,
    List<String>? religions,
    List<String>? qualities,
    List<String>? flaws,
    int? hasChildren,
    int? wantsChildren,
    int? hasAnimals,
    List<String>? languages,
    List<String>? educationLevels,
    int? alcohol,
    int? smoking,
    int? snoring,
    List<String>? hobbies,
    String? searchDescription,
    String? whatLookingFor,
    String? whatNotWant,
  }) {
    return CreateProfileModel(
      pseudo: pseudo ?? this.pseudo,
      sex: sex ?? this.sex,
      age: age ?? this.age,
      country: country ?? this.country,
      city: city ?? this.city,
      interests: interests ?? this.interests,
      imgURL: imgURL ?? this.imgURL,
      createdDate: createdDate ?? this.createdDate,
      description: description ?? this.description,
      // New fields
      name: name ?? this.name,
      dob: dob ?? this.dob,
      gender: gender ?? this.gender,
      orientation: orientation ?? this.orientation,
      relationshipStatus: relationshipStatus ?? this.relationshipStatus,
      mainInterests: mainInterests ?? this.mainInterests,
      secondaryInterests: secondaryInterests ?? this.secondaryInterests,
      passions: passions ?? this.passions,
      photos: photos ?? this.photos,
      height: height ?? this.height,
      silhouette: silhouette ?? this.silhouette,
      ethnicOrigins: ethnicOrigins ?? this.ethnicOrigins,
      religions: religions ?? this.religions,
      qualities: qualities ?? this.qualities,
      flaws: flaws ?? this.flaws,
      hasChildren: hasChildren ?? this.hasChildren,
      wantsChildren: wantsChildren ?? this.wantsChildren,
      hasAnimals: hasAnimals ?? this.hasAnimals,
      languages: languages ?? this.languages,
      educationLevels: educationLevels ?? this.educationLevels,
      alcohol: alcohol ?? this.alcohol,
      smoking: smoking ?? this.smoking,
      snoring: snoring ?? this.snoring,
      hobbies: hobbies ?? this.hobbies,
      searchDescription: searchDescription ?? this.searchDescription,
      whatLookingFor: whatLookingFor ?? this.whatLookingFor,
      whatNotWant: whatNotWant ?? this.whatNotWant,
    );
  }

  @override
  List<Object?> get props => [
    pseudo,
    sex,
    age,
    country,
    city,
    interests,
    imgURL,
    createdDate,
    description,
    // New fields
    name,
    dob,
    gender,
    orientation,
    relationshipStatus,
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
