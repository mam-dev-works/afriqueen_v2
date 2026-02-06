import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'dart:io';
import 'package:get/get.dart';
import 'package:afriqueen/features/activity/model/user_profile_model.dart';
import 'package:afriqueen/common/localization/enums/enums.dart';
import 'package:afriqueen/common/constant/constant_strings.dart';

class ComprehensiveEditProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // Cloudinary is used for image storage

  // Get current user profile
  Future<UserProfileModel?> getCurrentUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      final querySnapshot = await _firestore
          .collection('user')
          .where('id', isEqualTo: user.uid)
          .get();

      if (querySnapshot.docs.isEmpty) return null;

      return UserProfileModel.fromFirestore(querySnapshot.docs.first);
    } catch (e) {
      print('Error getting current user profile: $e');
      return null;
    }
  }

  // Upload photo to Cloudinary and return the secure URL
  Future<String?> uploadPhoto(File file, {required int index}) async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      final cloudinary = CloudinaryPublic(
        AppStrings.cloudName,
        AppStrings.uploadPreset,
      );
      final CloudinaryResponse response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          file.path,
          resourceType: CloudinaryResourceType.Image,
          folder: 'afriqueen/images',
          publicId: '${DateTime.now().millisecondsSinceEpoch}_$index',
        ),
      );
      return response.secureUrl;
    } catch (e) {
      print('Error uploading photo to Cloudinary: $e');
      return null;
    }
  }

  // Save or replace photo URL at a given index (0-4) in user's photos array
  Future<bool> savePhotoUrlAtIndex(String url, {required int index}) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      final querySnapshot = await _firestore
          .collection('user')
          .where('id', isEqualTo: user.uid)
          .get();

      if (querySnapshot.docs.isEmpty) return false;

      final docRef = querySnapshot.docs.first.reference;
      final current = querySnapshot.docs.first.data();
      final List<dynamic> existing = (current['photos'] as List<dynamic>?) ?? [];

      // Ensure list has at least 5 slots
      final List<String> photos = List<String>.from(existing.map((e) => e.toString()));
      while (photos.length < 5) {
        photos.add('');
      }

      photos[index] = url;

      await docRef.update({
        'photos': photos,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error saving photo url: $e');
      return false;
    }
  }

  // Update user profile with comprehensive data
  Future<bool> updateUserProfile({
    String? name,
    String? orientation,
    String? relationshipStatus,
    List<String>? secondaryInterests,
    List<String>? passions,
    int? height,
    int? silhouette,
    List<String>? religions,
    List<String>? qualities,
    List<String>? flaws,
    int? hasChildren,
    int? hasAnimals,
    List<String>? languages,
    List<String>? educationLevels,
    String? occupation,
    String? incomeLevel,
    int? alcohol,
    int? smoking,
    int? snoring,
    List<String>? hobbies,
    String? description,
    String? whatLookingFor,
    String? whatNotWant,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      final querySnapshot = await _firestore
          .collection('user')
          .where('id', isEqualTo: user.uid)
          .get();

      if (querySnapshot.docs.isEmpty) return false;

      final docRef = querySnapshot.docs.first.reference;
      
      // Prepare update data - only include non-null values
      Map<String, dynamic> updateData = {};
      
      if (name != null) updateData['name'] = name;
      if (orientation != null) updateData['orientation'] = orientation;
      if (relationshipStatus != null) updateData['relationshipStatus'] = relationshipStatus;
      if (secondaryInterests != null) updateData['secondaryInterests'] = secondaryInterests;
      if (passions != null) updateData['passions'] = passions;
      if (height != null) updateData['height'] = height;
      if (silhouette != null) updateData['silhouette'] = silhouette;
      if (religions != null) updateData['religions'] = religions;
      if (qualities != null) updateData['qualities'] = qualities;
      if (flaws != null) updateData['flaws'] = flaws;
      if (hasChildren != null) updateData['hasChildren'] = hasChildren;
      if (hasAnimals != null) updateData['hasAnimals'] = hasAnimals;
      if (languages != null) updateData['languages'] = languages;
      if (educationLevels != null) updateData['educationLevels'] = educationLevels;
      if (occupation != null) updateData['occupation'] = occupation;
      if (incomeLevel != null) updateData['incomeLevel'] = incomeLevel;
      if (alcohol != null) updateData['alcohol'] = alcohol;
      if (smoking != null) updateData['smoking'] = smoking;
      if (snoring != null) updateData['snoring'] = snoring;
      if (hobbies != null) updateData['hobbies'] = hobbies;
      if (description != null) updateData['description'] = description;
      if (whatLookingFor != null) updateData['whatLookingFor'] = whatLookingFor;
      if (whatNotWant != null) updateData['whatNotWant'] = whatNotWant;

      // Add timestamp
      updateData['lastUpdated'] = FieldValue.serverTimestamp();

      await docRef.update(updateData);
      return true;
    } catch (e) {
      print('Error updating user profile: $e');
      return false;
    }
  }

  // Get available options for dropdowns
  static List<String> getOrientationOptions() {
    return [
      EnumLocale.orientationHetero.name.tr,
      EnumLocale.orientationHomo.name.tr,
      EnumLocale.orientationBi.name.tr,
    ];
  }

  static List<String> getRelationshipStatusOptions() {
    return [
      EnumLocale.relationshipSingle.name.tr,
      EnumLocale.relationshipCouple.name.tr,
      EnumLocale.relationshipMarried.name.tr,
      EnumLocale.relationshipDivorced.name.tr,
    ];
  }

  static List<String> getPassionOptions() {
    return [
      EnumLocale.passionMusic.name.tr,
      EnumLocale.passionSport.name.tr,
      EnumLocale.passionReading.name.tr,
      EnumLocale.passionCinema.name.tr,
      EnumLocale.passionTravel.name.tr,
      EnumLocale.passionCooking.name.tr,
      EnumLocale.passionPhotography.name.tr,
      EnumLocale.passionVideoGames.name.tr,
      EnumLocale.passionActivities.name.tr,
      EnumLocale.passionOutings.name.tr,
      EnumLocale.passionPainting.name.tr,
    ];
  }

  static List<String> getQualityOptions() {
    return [
      EnumLocale.qualityAutonomous.name.tr,
      EnumLocale.qualitySociable.name.tr,
      EnumLocale.qualityFunny.name.tr,
      EnumLocale.qualityCreative.name.tr,
      EnumLocale.qualityListener.name.tr,
      // Use existing character trait translations as qualities
      EnumLocale.patient.name.tr,
      EnumLocale.optimistic.name.tr,
      EnumLocale.ambitious.name.tr,
      EnumLocale.honest.name.tr,
      EnumLocale.reliable.name.tr,
    ];
  }

  static List<String> getFlawOptions() {
    return [
      EnumLocale.flawImpulsive.name.tr,
      EnumLocale.flawPerfectionist.name.tr,
      EnumLocale.flawDemanding.name.tr,
      EnumLocale.flawProcrastination.name.tr,
      EnumLocale.flawSensitive.name.tr,
      EnumLocale.flawOther.name.tr,
    ];
  }

  static List<String> getChildrenOptions() {
    return [
      EnumLocale.profileChildrenYes.name.tr,
      EnumLocale.profileChildrenNo.name.tr,
      EnumLocale.profileChildrenNoAnswer.name.tr,
    ];
  }

  static List<String> getLanguageOptions() {
    return [
      EnumLocale.languageFrench.name.tr,
      EnumLocale.languageEnglish.name.tr,
      EnumLocale.languageSpanish.name.tr,
      EnumLocale.languageGerman.name.tr,
      EnumLocale.languageItalian.name.tr,
      EnumLocale.languagePortuguese.name.tr,
      EnumLocale.languageArabic.name.tr,
      EnumLocale.languageChinese.name.tr,
      EnumLocale.languageJapanese.name.tr,
      EnumLocale.languageRussian.name.tr
    ];
  }

  static List<String> getEducationLevelOptions() {
    return [
      EnumLocale.educationNone.name.tr,
      EnumLocale.educationCollege.name.tr,
      EnumLocale.educationHighSchool.name.tr,
      EnumLocale.educationBac.name.tr,
      EnumLocale.educationBac2.name.tr,
      EnumLocale.educationLicence.name.tr,
    ];
  }

  static List<String> getIncomeLevelOptions() {
    return [
      EnumLocale.lessThan20000.name.tr,
      EnumLocale.between20000And40000.name.tr,
      EnumLocale.between40000And60000.name.tr,
      EnumLocale.between60000And80000.name.tr,
      EnumLocale.between80000And100000.name.tr,
      EnumLocale.between100000And150000.name.tr,
      EnumLocale.between150000And200000.name.tr,
      EnumLocale.moreThan200000.name.tr,
      EnumLocale.preferNotToSay.name.tr,
    ];
  }

  static List<String> getYesNoOptions() {
    return [
      EnumLocale.yes.name.tr,
      EnumLocale.no.name.tr,
      EnumLocale.dontKnow.name.tr,
    ];
  }

  static List<String> getSilhouetteOptions() {
    return [
      EnumLocale.athletic.name.tr,
      EnumLocale.average.name.tr,
      EnumLocale.curvy.name.tr,
      EnumLocale.slim.name.tr,
      EnumLocale.muscular.name.tr,
      EnumLocale.plusSize.name.tr,
      EnumLocale.petite.name.tr,
      EnumLocale.tall.name.tr,
      EnumLocale.otherSilhouette.name.tr,
    ];
  }

  static List<String> getReligionOptions() {
    return [
      EnumLocale.christianity.name.tr,
      EnumLocale.islam.name.tr,
      EnumLocale.hinduism.name.tr,
      EnumLocale.buddhism.name.tr,
      EnumLocale.judaism.name.tr,
      EnumLocale.sikhism.name.tr,
      EnumLocale.taoism.name.tr,
      EnumLocale.confucianism.name.tr,
      EnumLocale.shinto.name.tr,
      EnumLocale.otherReligion.name.tr,
    ];
  }

  // Convert string values to appropriate types
  static int? stringToInt(String? value) {
    if (value == null || value.isEmpty) return null;
    return int.tryParse(value);
  }

  static double? stringToDouble(String? value) {
    if (value == null || value.isEmpty) return null;
    return double.tryParse(value);
  }

  static int? yesNoToInt(String? value) {
    if (value == null) return null;
    switch (value.toLowerCase()) {
      case 'non':
      case 'no':
        return 0;
      case 'oui':
      case 'yes':
        return 1;
      case 'parfois':
      case 'sometimes':
        return 2;
      case 'je ne sais pas':
      case 'i don\'t know':
        return 3;
      default:
        return 0;
    }
  }

  static String? intToYesNo(int? value) {
    if (value == null) return null;
    switch (value) {
      case 0:
        return 'Non';
      case 1:
        return 'Oui';
      case 2:
        return 'Parfois';
      case 3:
        return 'Je ne sais pas';
      default:
        return 'Non';
    }
  }
}
