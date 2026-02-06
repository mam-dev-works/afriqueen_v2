import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/edit_profile_model.dart';

class EditProfileRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<EditProfileModel?> getProfile() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      final querySnapshot = await _firestore
          .collection('user')
          .where('id', isEqualTo: user.uid)
          .get();

      if (querySnapshot.docs.isEmpty) return null;

      final data = querySnapshot.docs.first.data();
      
      // Helper function to safely convert to List<String>
      List<String> safeListConversion(dynamic value) {
        if (value == null) return [];
        if (value is String) return [value];
        if (value is List) {
          return value.map((e) => e.toString()).toList();
        }
        return [];
      }

      return EditProfileModel(
        interests: safeListConversion(data['interests']),
        age: data['age'],
        spokenLanguages: safeListConversion(data['spokenLanguages']),
        religion: data['religion']?.toString(),
        hasChildren: data['hasChildren'],
        wantChildren: data['wantChildren'],
        character: safeListConversion(data['character']),
        occupation: data['occupation']?.toString(),
        levelOfStudy: safeListConversion(data['levelOfStudy']),
        professionalLanguages: safeListConversion(data['professionalLanguages']),
        incomeLevel: data['incomeLevel']?.toString(),
        physicalAge: data['physicalAge'],
        size: (data['size'] is int)
            ? (data['size'] as int).toDouble()
            : data['size'],
        weight: (data['weight'] is int)
            ? (data['weight'] as int).toDouble()
            : data['weight'],
        silhouette: data['silhouette']?.toString(),
        ethnicOrigin: safeListConversion(data['ethnicOrigin']),
        description: data['description']?.toString(),
        lookingFor: data['lookingFor']?.toString(),
        dontWant: data['dontWant']?.toString(),
      );
    } catch (e) {
      print('Error getting profile: $e');
      return null;
    }
  }

  Future<void> updateProfile(EditProfileModel model) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final querySnapshot = await _firestore
          .collection('user')
          .where('id', isEqualTo: user.uid)
          .get();

      if (querySnapshot.docs.isEmpty) return;

      final docRef = querySnapshot.docs.first.reference;
      final updatedData = {
        'interests': model.interests,
        'age': model.age,
        'spokenLanguages': model.spokenLanguages,
        'religion': model.religion,
        'hasChildren': model.hasChildren,
        'wantChildren': model.wantChildren,
        'character': model.character,
        'occupation': model.occupation,
        'levelOfStudy': model.levelOfStudy,
        'professionalLanguages': model.professionalLanguages,
        'incomeLevel': model.incomeLevel,
        'physicalAge': model.physicalAge,
        'size': model.size,
        'weight': model.weight,
        'silhouette': model.silhouette,
        'ethnicOrigin': model.ethnicOrigin,
        'description': model.description,
        'lookingFor': model.lookingFor,
        'dontWant': model.dontWant,
      };

      await docRef.update(updatedData);
    } catch (e) {
      print('Error updating profile: $e');
      rethrow;
    }
  }
}
