import 'package:afriqueen/features/profile/model/profile_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

//----------------Fetching current  user profile data
class ProfileRepository {
  final FirebaseFirestore firebaseFirestore;
  ProfileRepository({FirebaseFirestore? firestore})
    : firebaseFirestore = firestore ?? FirebaseFirestore.instance;

  Future<ProfileModel?> fetchProfileData() async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;

      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await firebaseFirestore
              .collection('user')
              .where('id', isEqualTo: uid)
              .get();

      if (snapshot.docs.isNotEmpty) {
        return ProfileModel.fromMap(snapshot.docs.first.data());
      }
    } catch (e) {
      rethrow;
    }
    return null;
  }

  Future<ProfileModel?> fetchUserDataById(String userId) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await firebaseFirestore
              .collection('user')
              .where('id', isEqualTo: userId)
              .get();

      if (snapshot.docs.isNotEmpty) {
        return ProfileModel.fromMap(snapshot.docs.first.data());
      }
    } catch (e) {
      rethrow;
    }
    return null;
  }
}
