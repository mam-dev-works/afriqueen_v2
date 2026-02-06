class EditProfileModel {
  // Interest
  List<String> interests;

  // Staff
  int? age;
  List<String> spokenLanguages;
  String? religion;
  int? hasChildren;
  bool? wantChildren;
  List<String> character;

  // Professional
  String? occupation;
  List<String> levelOfStudy;
  List<String> professionalLanguages;
  String? incomeLevel;

  // Physical
  int? physicalAge;
  double? size;
  double? weight;
  String? silhouette;
  List<String> ethnicOrigin;

  // Free text
  String? description;
  String? lookingFor;
  String? dontWant;

  EditProfileModel({
    this.interests = const [],
    this.age,
    this.spokenLanguages = const [],
    this.religion,
    this.hasChildren,
    this.wantChildren,
    this.character = const [],
    this.occupation,
    this.levelOfStudy = const [],
    this.professionalLanguages = const [],
    this.incomeLevel,
    this.physicalAge,
    this.size,
    this.weight,
    this.silhouette,
    this.ethnicOrigin = const [],
    this.description,
    this.lookingFor,
    this.dontWant,
  });

  EditProfileModel copyWith({
    List<String>? interestedIn,
    List<String>? passion,
    List<String>? leisure,
    int? age,
    List<String>? spokenLanguages,
    String? religion,
    int? hasChildren,
    bool? wantChildren,
    List<String>? character,
    String? occupation,
    List<String>? levelOfStudy,
    List<String>? professionalLanguages,
    String? incomeLevel,
    int? physicalAge,
    double? size,
    double? weight,
    String? silhouette,
    List<String>? ethnicOrigin,
    String? description,
    String? lookingFor,
    String? dontWant,
  }) {
    return EditProfileModel(
      interests: interestedIn ?? this.interests,
      age: age ?? this.age,
      spokenLanguages: spokenLanguages ?? this.spokenLanguages,
      religion: religion ?? this.religion,
      hasChildren: hasChildren ?? this.hasChildren,
      wantChildren: wantChildren ?? this.wantChildren,
      character: character ?? this.character,
      occupation: occupation ?? this.occupation,
      levelOfStudy: levelOfStudy ?? this.levelOfStudy,
      professionalLanguages: professionalLanguages ?? this.professionalLanguages,
      incomeLevel: incomeLevel ?? this.incomeLevel,
      physicalAge: physicalAge ?? this.physicalAge,
      size: size ?? this.size,
      weight: weight ?? this.weight,
      silhouette: silhouette ?? this.silhouette,
      ethnicOrigin: ethnicOrigin ?? this.ethnicOrigin,
      description: description ?? this.description,
      lookingFor: lookingFor ?? this.lookingFor,
      dontWant: dontWant ?? this.dontWant,
    );
  }

  // Add fromJson, toJson, copyWith as needed


} 