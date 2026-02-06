// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class HomeModel extends Equatable {
  final String id;
  final String pseudo;
  final String name;
  final String gender;
  final String orientation;
  final int age;
  final String country;
  final String city;
  final String description;
  final String searchDescription;
  final String whatLookingFor;
  final String whatNotWant;
  
  final List<String> mainInterests;
  final List<String> secondaryInterests;
  final List<String> passions;
  final List<String> hobbies;
  final List<String> languages;
  final List<String> educationLevels;
  final List<String> ethnicOrigins;
  final List<String> religions;
  final List<String> qualities;
  final List<String> flaws;
  final List<String> photos;
  
  final DateTime createdDate;
  final DateTime dob;
  final DateTime lastActive;
  final String relationshipStatus;
  final int height;
  final int silhouette;
  final int hasChildren;
  final int wantsChildren;
  final int hasAnimals;
  final int alcohol;
  final int smoking;
  final int snoring;
  final bool isElite;
  final bool isActive;
  final bool isPremium;
  final String email;
  // Invisibility preferences (who this user hides from)
  final List<String> invisibleToProfileTypes;
  final List<String> invisibleToSexes;
  final List<String> invisibleToOrientations;
  const HomeModel({
    required this.id,
    required this.pseudo,
    required this.name,
    required this.gender,
    required this.orientation,
    required this.age,
    required this.country,
    required this.city,
    required this.description,
    required this.searchDescription,
    required this.whatLookingFor,
    required this.whatNotWant,
    required this.mainInterests,
    required this.secondaryInterests,
    required this.passions,
    required this.hobbies,
    required this.languages,
    required this.educationLevels,
    required this.ethnicOrigins,
    required this.religions,
    required this.qualities,
    required this.flaws,
    required this.photos,
    required this.createdDate,
    required this.dob,
    required this.lastActive,
    required this.relationshipStatus,
    required this.height,
    required this.silhouette,
    required this.hasChildren,
    required this.wantsChildren,
    required this.hasAnimals,
    required this.alcohol,
    required this.smoking,
    required this.snoring,
    required this.isElite,
    required this.isActive,
    required this.isPremium,
    required this.email,
    this.invisibleToProfileTypes = const [],
    this.invisibleToSexes = const [],
    this.invisibleToOrientations = const [],
  });

  HomeModel copyWith({
    String? id,
    String? pseudo,
    String? name,
    String? gender,
    String? orientation,
    int? age,
    String? country,
    String? city,
    String? description,
    String? searchDescription,
    String? whatLookingFor,
    String? whatNotWant,
    List<String>? mainInterests,
    List<String>? secondaryInterests,
    List<String>? passions,
    List<String>? hobbies,
    List<String>? languages,
    List<String>? educationLevels,
    List<String>? ethnicOrigins,
    List<String>? religions,
    List<String>? qualities,
    List<String>? flaws,
    List<String>? photos,
    DateTime? createdDate,
    DateTime? dob,
    DateTime? lastActive,
    String? relationshipStatus,
    int? height,
    int? silhouette,
    int? hasChildren,
    int? wantsChildren,
    int? hasAnimals,
    int? alcohol,
    int? smoking,
    int? snoring,
    bool? isElite,
    bool? isActive,
    bool? isPremium,
    String? email,
    List<String>? invisibleToProfileTypes,
    List<String>? invisibleToSexes,
    List<String>? invisibleToOrientations,
  }) {
    return HomeModel(
      id: id ?? this.id,
      pseudo: pseudo ?? this.pseudo,
      name: name ?? this.name,
      gender: gender ?? this.gender,
      orientation: orientation ?? this.orientation,
      age: age ?? this.age,
      country: country ?? this.country,
      city: city ?? this.city,
      description: description ?? this.description,
      searchDescription: searchDescription ?? this.searchDescription,
      whatLookingFor: whatLookingFor ?? this.whatLookingFor,
      whatNotWant: whatNotWant ?? this.whatNotWant,
      mainInterests: mainInterests ?? this.mainInterests,
      secondaryInterests: secondaryInterests ?? this.secondaryInterests,
      passions: passions ?? this.passions,
      hobbies: hobbies ?? this.hobbies,
      languages: languages ?? this.languages,
      educationLevels: educationLevels ?? this.educationLevels,
      ethnicOrigins: ethnicOrigins ?? this.ethnicOrigins,
      religions: religions ?? this.religions,
      qualities: qualities ?? this.qualities,
      flaws: flaws ?? this.flaws,
      photos: photos ?? this.photos,
      createdDate: createdDate ?? this.createdDate,
      dob: dob ?? this.dob,
      lastActive: lastActive ?? this.lastActive,
      relationshipStatus: relationshipStatus ?? this.relationshipStatus,
      height: height ?? this.height,
      silhouette: silhouette ?? this.silhouette,
      hasChildren: hasChildren ?? this.hasChildren,
      wantsChildren: wantsChildren ?? this.wantsChildren,
      hasAnimals: hasAnimals ?? this.hasAnimals,
      alcohol: alcohol ?? this.alcohol,
      smoking: smoking ?? this.smoking,
      snoring: snoring ?? this.snoring,
      isElite: isElite ?? this.isElite,
      isActive: isActive ?? this.isActive,
      isPremium: isPremium ?? this.isPremium,
      email: email ?? this.email,
      invisibleToProfileTypes: invisibleToProfileTypes ?? this.invisibleToProfileTypes,
      invisibleToSexes: invisibleToSexes ?? this.invisibleToSexes,
      invisibleToOrientations: invisibleToOrientations ?? this.invisibleToOrientations,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'pseudo': pseudo,
      'name': name,
      'gender': gender,
      'orientation': orientation,
      'age': age,
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
      'createdDate': createdDate.millisecondsSinceEpoch,
      'dob': dob.millisecondsSinceEpoch,
      'lastActive': lastActive.millisecondsSinceEpoch,
      'relationshipStatus': relationshipStatus,
      'height': height,
      'silhouette': silhouette,
      'hasChildren': hasChildren,
      'wantsChildren': wantsChildren,
      'hasAnimals': hasAnimals,
      'alcohol': alcohol,
      'smoking': smoking,
      'snoring': snoring,
      'isElite': isElite,
      'isActive': isActive,
      'isPremium': isPremium,
      'email': email,
      'invisibleToProfileTypes': invisibleToProfileTypes,
      'invisibleToSexes': invisibleToSexes,
      'invisibleToOrientations': invisibleToOrientations,
    };
  }

  factory HomeModel.fromMap(Map<String, dynamic> map) {
    print('HomeModel.fromMap: Parsing map: $map');
    
    // Handle different field names from Firestore
    final String id = map['id'] as String? ?? '';
    
    // Debug: Check what fields are available
    print('HomeModel.fromMap: Available fields: ${map.keys.toList()}');
    print('HomeModel.fromMap: Has photos: ${map.containsKey('photos')}');
    if (map.containsKey('photos')) {
      print('HomeModel.fromMap: Photos field type: ${map['photos'].runtimeType}');
      print('HomeModel.fromMap: Photos field value: ${map['photos']}');
    }
    print('HomeModel.fromMap: Has name: ${map.containsKey('name')}');
    print('HomeModel.fromMap: Has gender: ${map.containsKey('gender')}');
    
    // Get basic fields
    final String pseudo = map['pseudo'] as String? ?? '';
    final String name = map['name'] as String? ?? '';
    final String gender = map['gender'] as String? ?? '';
    final String orientation = map['orientation'] as String? ?? '';
    final String description = map['description'] as String? ?? '';
    final String searchDescription = map['searchDescription'] as String? ?? '';
    final String whatLookingFor = map['whatLookingFor'] as String? ?? '';
    final String whatNotWant = map['whatNotWant'] as String? ?? '';
    final String relationshipStatus = map['relationshipStatus'] as String? ?? '';
    final String email = map['email'] as String? ?? '';
    
    // Get array fields
    List<String> mainInterests = [];
    if (map['mainInterests'] != null && map['mainInterests'] is List) {
      mainInterests = (map['mainInterests'] as List).cast<String>();
    }
    
    List<String> secondaryInterests = [];
    if (map['secondaryInterests'] != null && map['secondaryInterests'] is List) {
      secondaryInterests = (map['secondaryInterests'] as List).cast<String>();
    }
    
    List<String> passions = [];
    if (map['passions'] != null && map['passions'] is List) {
      passions = (map['passions'] as List).cast<String>();
    }
    
    List<String> hobbies = [];
    if (map['hobbies'] != null && map['hobbies'] is List) {
      hobbies = (map['hobbies'] as List).cast<String>();
    }
    
    List<String> languages = [];
    if (map['languages'] != null && map['languages'] is List) {
      languages = (map['languages'] as List).cast<String>();
    }
    
    List<String> educationLevels = [];
    if (map['educationLevels'] != null && map['educationLevels'] is List) {
      educationLevels = (map['educationLevels'] as List).cast<String>();
    }
    
    List<String> ethnicOrigins = [];
    if (map['ethnicOrigins'] != null && map['ethnicOrigins'] is List) {
      ethnicOrigins = (map['ethnicOrigins'] as List).cast<String>();
    }
    
    List<String> religions = [];
    if (map['religions'] != null && map['religions'] is List) {
      religions = (map['religions'] as List).cast<String>();
    }
    
    List<String> qualities = [];
    if (map['qualities'] != null && map['qualities'] is List) {
      qualities = (map['qualities'] as List).cast<String>();
    }
    
    List<String> flaws = [];
    if (map['flaws'] != null && map['flaws'] is List) {
      flaws = (map['flaws'] as List).cast<String>();
    }
    
    // Get photos array
    List<String> photos = [];
    print('HomeModel.fromMap: Checking photos field...');
    print('HomeModel.fromMap: Has photos key: ${map.containsKey('photos')}');
    if (map.containsKey('photos')) {
      print('HomeModel.fromMap: Photos field value: ${map['photos']}');
      print('HomeModel.fromMap: Photos field type: ${map['photos'].runtimeType}');
      
      if (map['photos'] != null && map['photos'] is List) {
        final photosList = map['photos'] as List;
        print('HomeModel.fromMap: Photos list length: ${photosList.length}');
        print('HomeModel.fromMap: Photos list content: $photosList');
        
        for (int i = 0; i < photosList.length; i++) {
          print('HomeModel.fromMap: Photo $i: ${photosList[i]} (type: ${photosList[i].runtimeType})');
        }
        
        photos = photosList.cast<String>();
        print('HomeModel.fromMap: Casted photos: $photos');
      } else {
        print('HomeModel.fromMap: Photos field is not a List or is null');
      }
    } else {
      print('HomeModel.fromMap: No photos field found in map');
    }
    
    // Handle dates
    DateTime createdDate = DateTime.now();
    if (map['createdDate'] != null) {
      if (map['createdDate'] is Timestamp) {
        createdDate = (map['createdDate'] as Timestamp).toDate();
      } else if (map['createdDate'] is int) {
        createdDate = DateTime.fromMillisecondsSinceEpoch(map['createdDate'] as int);
      }
    }
    
    DateTime dob = DateTime.now();
    if (map['dob'] != null) {
      if (map['dob'] is Timestamp) {
        dob = (map['dob'] as Timestamp).toDate();
      } else if (map['dob'] is int) {
        dob = DateTime.fromMillisecondsSinceEpoch(map['dob'] as int);
      }
    }
    
    DateTime lastActive = DateTime.now();
    if (map['lastActive'] != null) {
      if (map['lastActive'] is Timestamp) {
        lastActive = (map['lastActive'] as Timestamp).toDate();
      } else if (map['lastActive'] is int) {
        lastActive = DateTime.fromMillisecondsSinceEpoch(map['lastActive'] as int);
      }
    }
    
    final result = HomeModel(
      id: id,
      pseudo: pseudo,
      name: name,
      gender: gender,
      orientation: orientation,
      age: map['age'] as int? ?? 0,
      country: map['country'] as String? ?? '',
      city: map['city'] as String? ?? '',
      description: description,
      searchDescription: searchDescription,
      whatLookingFor: whatLookingFor,
      whatNotWant: whatNotWant,
      mainInterests: mainInterests,
      secondaryInterests: secondaryInterests,
      passions: passions,
      hobbies: hobbies,
      languages: languages,
      educationLevels: educationLevels,
      ethnicOrigins: ethnicOrigins,
      religions: religions,
      qualities: qualities,
      flaws: flaws,
      photos: photos,
      createdDate: createdDate,
      dob: dob,
      lastActive: lastActive,
      relationshipStatus: relationshipStatus,
      height: map['height'] as int? ?? 0,
      silhouette: map['silhouette'] as int? ?? 0,
      hasChildren: map['hasChildren'] as int? ?? 0,
      wantsChildren: map['wantsChildren'] as int? ?? 0,
      hasAnimals: map['hasAnimals'] as int? ?? 0,
      alcohol: map['alcohol'] as int? ?? 0,
      smoking: map['smoking'] as int? ?? 0,
      snoring: map['snoring'] as int? ?? 0,
      isElite: map['isElite'] as bool? ?? false,
      isActive: map['isActive'] as bool? ?? false,
      isPremium: map['isPremium'] as bool? ?? false,
      email: email,
      invisibleToProfileTypes: List<String>.from(map['invisibleToProfileTypes'] ?? const <String>[]),
      invisibleToSexes: List<String>.from(map['invisibleToSexes'] ?? const <String>[]),
      invisibleToOrientations: List<String>.from(map['invisibleToOrientations'] ?? const <String>[]),
    );
    
    print('HomeModel.fromMap: Created model - ID: ${result.id}, Pseudo: ${result.pseudo}, Photos: ${result.photos}');
    return result;
  }

  String toJson() => json.encode(toMap());

  factory HomeModel.fromJson(String source) =>
      HomeModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool get stringify => true;

  @override
  List<Object> get props {
    return [
      id,
      pseudo,
      name,
      gender,
      orientation,
      age,
      country,
      city,
      description,
      searchDescription,
      whatLookingFor,
      whatNotWant,
      mainInterests,
      secondaryInterests,
      passions,
      hobbies,
      languages,
      educationLevels,
      ethnicOrigins,
      religions,
      qualities,
      flaws,
      photos,
      createdDate,
      dob,
      lastActive,
      relationshipStatus,
      height,
      silhouette,
      hasChildren,
      wantsChildren,
      hasAnimals,
      alcohol,
      smoking,
      snoring,
      isElite,
      isActive,
      isPremium,
      email,
      invisibleToProfileTypes,
      invisibleToSexes,
      invisibleToOrientations,
    ];
  }

  // Add this static constant
  static final HomeModel empty = HomeModel(
    id: '',
    pseudo: '',
    name: '',
    gender: '',
    orientation: '',
    age: 0,
    country: '',
    city: '',
    description: '',
    searchDescription: '',
    whatLookingFor: '',
    whatNotWant: '',
    mainInterests: [],
    secondaryInterests: [],
    passions: [],
    hobbies: [],
    languages: [],
    educationLevels: [],
    ethnicOrigins: [],
    religions: [],
    qualities: [],
    flaws: [],
    photos: [],
    createdDate: DateTime(0),
    dob: DateTime(0),
    lastActive: DateTime(0),
    relationshipStatus: '',
    height: 0,
    silhouette: 0,
    hasChildren: 0,
    wantsChildren: 0,
    hasAnimals: 0,
    alcohol: 0,
    smoking: 0,
    snoring: 0,
    isElite: false,
    isActive: false,
    isPremium: false,
    email: '',
    invisibleToProfileTypes: const [],
    invisibleToSexes: const [],
    invisibleToOrientations: const [],
  );
}
