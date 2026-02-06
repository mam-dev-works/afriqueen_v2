import 'package:afriqueen/common/constant/constant_strings.dart';
import 'package:afriqueen/features/create_profile/model/create_profile_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

//--------------------Profile repository ---------------------------------------------
class CreateProfileRepository {
  final FirebaseFirestore _firestore;
  final imgPicker = ImagePicker();
  CreateProfileRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;
    
  Future<void> uploadToFirebase(CreateProfileModel profile) async {
    try {
      final Map<String, dynamic> userData = {
        'id': FirebaseAuth.instance.currentUser!.uid,
        'pseudo': profile.pseudo,
        'sex': (profile.sex.trim().isEmpty) ? 'Male' : profile.sex,
        'age': profile.age,
        'country': profile.country,
        'city': profile.city,
        'createdDate': profile.createdDate,
        'interests': profile.interests,
        'imgURL': profile.imgURL,
        'description': profile.description,
        'isElite': false, // Default to classic profile
        'isPremium': false, // Default to classic profile
      };

      await _firestore.collection('user').doc().set(userData);
    } catch (e) {
      debugPrint(
        "Error while uploading profile data to firebase : ${e.toString()}",
      );
      rethrow;
    }
  }

  Future<void> createCompleteUserProfile(CreateProfileModel profile) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('No authenticated user found');
      }

      final Map<String, dynamic> userData = {
        'id': currentUser.uid,
        'email': currentUser.email,
        'name': profile.name,
        'pseudo': profile.pseudo,
        'description': profile.description,
        'dob': profile.dob,
        'age': DateTime.now().year - profile.dob.year,
        'gender': profile.gender,
        'orientation': profile.orientation,
        'relationshipStatus': profile.relationshipStatus,
        'country': profile.country,
        'city': profile.city,
        'mainInterests': profile.mainInterests,
        'secondaryInterests': profile.secondaryInterests,
        'passions': profile.passions,
        'photos': profile.photos,
        'height': profile.height,
        'silhouette': profile.silhouette,
        'ethnicOrigins': profile.ethnicOrigins,
        'religions': profile.religions,
        'qualities': profile.qualities,
        'flaws': profile.flaws,
        'hasChildren': profile.hasChildren,
        'wantsChildren': profile.wantsChildren,
        'hasAnimals': profile.hasAnimals,
        'languages': profile.languages,
        'educationLevels': profile.educationLevels,
        'alcohol': profile.alcohol,
        'smoking': profile.smoking,
        'snoring': profile.snoring,
        'hobbies': profile.hobbies,
        'searchDescription': profile.searchDescription,
        'whatLookingFor': profile.whatLookingFor,
        'whatNotWant': profile.whatNotWant,
        'createdDate': FieldValue.serverTimestamp(),
        'isElite': false, // Default to classic profile
        'isActive': true,
        'isPremium': false, // Default to classic profile
        'lastActive': FieldValue.serverTimestamp(),
      };

      // Create the document with the user's UID as the document ID
      await _firestore.collection('user').doc(currentUser.uid).set(userData);
      debugPrint("User profile created successfully with UID: ${currentUser.uid}");
    } catch (e) {
      debugPrint(
        "Error while creating complete user profile: ${e.toString()}",
      );
      rethrow;
    }
  }

  Future<String?> imagePicker() async {
    try {
      final img = await imgPicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100,
      );

      if (img != null) return img.path;
    } catch (e) {
      debugPrint("Error while picking image : ${e.toString()}");
      rethrow;
    }

    return null;
  }

  Future<String?> uploadToCloudinary(String imagePath) async {
    try {
      final cloudinary = CloudinaryPublic(
        AppStrings.cloudName,
        AppStrings.uploadPreset,
      );
      CloudinaryResponse response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          imagePath,
          resourceType: CloudinaryResourceType.Image,
          folder: "afriqueen/images",
          publicId: "${DateTime.now().millisecond}",
        ),
      );

      return response.secureUrl;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<String>> uploadMultiplePhotosToCloudinary(List<String> imagePaths) async {
    List<String> uploadedUrls = [];
    try {
      final cloudinary = CloudinaryPublic(
        AppStrings.cloudName,
        AppStrings.uploadPreset,
      );
      
      for (String imagePath in imagePaths) {
        if (imagePath.isNotEmpty) {
          CloudinaryResponse response = await cloudinary.uploadFile(
            CloudinaryFile.fromFile(
              imagePath,
              resourceType: CloudinaryResourceType.Image,
              folder: "afriqueen/images",
              publicId: "${DateTime.now().millisecondsSinceEpoch}_${uploadedUrls.length}",
            ),
          );
          uploadedUrls.add(response.secureUrl);
        }
      }
      
      return uploadedUrls;
    } catch (e) {
      debugPrint("Error uploading multiple photos to Cloudinary: ${e.toString()}");
      rethrow;
    }
  }
}
