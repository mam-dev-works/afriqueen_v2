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
    );
  }

  @override
  List<Object?> get props => [
    pseudo,
    sex,
    age,
    country,
    city,

    imgURL,
    createdDate,
  ];
}
