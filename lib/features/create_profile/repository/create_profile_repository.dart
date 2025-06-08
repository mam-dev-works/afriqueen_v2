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
      };

      await _firestore.collection('user').doc().set(userData);
    } catch (e) {
      debugPrint(
        "Error while uploading profile data to firebase : ${e.toString()}",
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
      debugPrint("Error while picking imaage : : ${e.toString()}");
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
}
