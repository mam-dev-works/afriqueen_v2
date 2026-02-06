import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfileModel {
  final String id;
  final String name;
  final String? pseudo;
  final int? age;
  final String? gender;
  final String? orientation;
  final String? country;
  final String? city;
  final String? description;
  final String? searchDescription;
  final String? whatLookingFor;
  final String? whatNotWant;
  final List<String>? mainInterests;
  final List<String>? secondaryInterests;
  final List<String>? passions;
  final List<String>? hobbies;
  final List<String>? languages;
  final List<String>? educationLevels;
  final List<String>? ethnicOrigins;
  final List<String>? religions;
  final List<String>? qualities;
  final List<String>? flaws;
  final List<String>? photos;
  final DateTime? createdDate;
  final DateTime? dob;
  final DateTime? lastActive;
  final String? relationshipStatus;
  final int? height;
  final int? silhouette;
  final int? hasChildren;
  final int? wantsChildren;
  final int? hasAnimals;
  final int? alcohol;
  final int? smoking;
  final int? snoring;
  final String? occupation;
  final String? incomeLevel;
  final bool? isElite;
  final bool? isActive;
  final bool? isSuspended;
  final bool? isDeleted;
  final bool? isPremium;
  final String? email;
  final DateTime? viewedAt;

  UserProfileModel({
    required this.id,
    required this.name,
    this.pseudo,
    this.age,
    this.gender,
    this.orientation,
    this.country,
    this.city,
    this.description,
    this.searchDescription,
    this.whatLookingFor,
    this.whatNotWant,
    this.mainInterests,
    this.secondaryInterests,
    this.passions,
    this.hobbies,
    this.languages,
    this.educationLevels,
    this.ethnicOrigins,
    this.religions,
    this.qualities,
    this.flaws,
    this.photos,
    this.createdDate,
    this.dob,
    this.lastActive,
    this.relationshipStatus,
    this.height,
    this.silhouette,
    this.hasChildren,
    this.wantsChildren,
    this.hasAnimals,
    this.alcohol,
    this.smoking,
    this.snoring,
    this.occupation,
    this.incomeLevel,
    this.isElite,
    this.isActive,
    this.isSuspended,
    this.isDeleted,
    this.isPremium,
    this.email,
    this.viewedAt,
  });

  factory UserProfileModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    // Handle dates
    DateTime createdDate = DateTime.now();
    if (data['createdDate'] != null) {
      if (data['createdDate'] is Timestamp) {
        createdDate = (data['createdDate'] as Timestamp).toDate();
      } else if (data['createdDate'] is int) {
        createdDate = DateTime.fromMillisecondsSinceEpoch(data['createdDate'] as int);
      }
    }
    
    DateTime dob = DateTime.now();
    if (data['dob'] != null) {
      if (data['dob'] is Timestamp) {
        dob = (data['dob'] as Timestamp).toDate();
      } else if (data['dob'] is int) {
        dob = DateTime.fromMillisecondsSinceEpoch(data['dob'] as int);
      }
    }
    
    DateTime lastActive = DateTime.now();
    if (data['lastActive'] != null) {
      if (data['lastActive'] is Timestamp) {
        lastActive = (data['lastActive'] as Timestamp).toDate();
      } else if (data['lastActive'] is int) {
        lastActive = DateTime.fromMillisecondsSinceEpoch(data['lastActive'] as int);
      }
    }
    
    return UserProfileModel(
      id: doc.id,
      name: data['name'] as String? ?? '',
      pseudo: data['pseudo'] as String? ?? '',
      age: data['age'] as int? ?? 0,
      gender: data['gender'] as String? ?? '',
      orientation: data['orientation'] as String? ?? '',
      country: data['country'] as String? ?? '',
      city: data['city'] as String? ?? '',
      description: data['description'] as String? ?? '',
      searchDescription: data['searchDescription'] as String? ?? '',
      whatLookingFor: data['whatLookingFor'] as String? ?? '',
      whatNotWant: data['whatNotWant'] as String? ?? '',
      mainInterests: List<String>.from(data['mainInterests'] ?? []),
      secondaryInterests: List<String>.from(data['secondaryInterests'] ?? []),
      passions: List<String>.from(data['passions'] ?? []),
      hobbies: List<String>.from(data['hobbies'] ?? []),
      languages: List<String>.from(data['languages'] ?? []),
      educationLevels: List<String>.from(data['educationLevels'] ?? []),
      ethnicOrigins: List<String>.from(data['ethnicOrigins'] ?? []),
      religions: List<String>.from(data['religions'] ?? []),
      qualities: List<String>.from(data['qualities'] ?? []),
      flaws: List<String>.from(data['flaws'] ?? []),
      photos: List<String>.from(data['photos'] ?? []),
      createdDate: createdDate,
      dob: dob,
      lastActive: lastActive,
      relationshipStatus: data['relationshipStatus'] as String? ?? '',
      height: data['height'] as int? ?? 0,
      silhouette: data['silhouette'] as int? ?? 0,
      hasChildren: data['hasChildren'] as int? ?? 0,
      wantsChildren: data['wantsChildren'] as int? ?? 0,
      hasAnimals: data['hasAnimals'] as int? ?? 0,
      alcohol: data['alcohol'] as int? ?? 0,
      smoking: data['smoking'] as int? ?? 0,
      snoring: data['snoring'] as int? ?? 0,
      occupation: data['occupation'] as String? ?? '',
      incomeLevel: data['incomeLevel'] as String? ?? '',
      isElite: data['isElite'] as bool? ?? false,
      isActive: data['isActive'] as bool? ?? false,
      isSuspended: data['isSuspended'] as bool? ?? false,
      isDeleted: data['isDeleted'] as bool? ?? false,
      isPremium: data['isPremium'] as bool? ?? false,
      email: data['email'] as String? ?? '',
      viewedAt: (data['viewedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'pseudo': pseudo,
      'age': age,
      'gender': gender,
      'orientation': orientation,
      'country': country,
      'city': city,
      'description': description,
      'searchDescription': searchDescription,
      'whatLookingFor': whatLookingFor,
      'whatNotWant': whatNotWant,
      'mainInterests': mainInterests,
      'secondaryInterests': secondaryInterests,
      'passions': passions,
      'hobbies': hobbies,
      'languages': languages,
      'educationLevels': educationLevels,
      'ethnicOrigins': ethnicOrigins,
      'religions': religions,
      'qualities': qualities,
      'flaws': flaws,
      'photos': photos,
      'createdDate': createdDate != null ? Timestamp.fromDate(createdDate!) : null,
      'dob': dob != null ? Timestamp.fromDate(dob!) : null,
      'lastActive': lastActive != null ? Timestamp.fromDate(lastActive!) : null,
      'relationshipStatus': relationshipStatus,
      'height': height,
      'silhouette': silhouette,
      'hasChildren': hasChildren,
      'wantsChildren': wantsChildren,
      'hasAnimals': hasAnimals,
      'alcohol': alcohol,
      'smoking': smoking,
      'snoring': snoring,
      'occupation': occupation,
      'incomeLevel': incomeLevel,
      'isElite': isElite,
      'isActive': isActive,
      'isSuspended': isSuspended,
      'isDeleted': isDeleted,
      'isPremium': isPremium,
      'email': email,
      'viewedAt': viewedAt != null ? Timestamp.fromDate(viewedAt!) : null,
    };
  }
}
