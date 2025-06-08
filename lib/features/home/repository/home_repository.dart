import 'package:afriqueen/features/home/model/home_model.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

//----------------Fetching current   profile data of all user
class HomeRepository {
  final FirebaseFirestore firebaseFirestore;
  HomeRepository({FirebaseFirestore? firestore})
    : firebaseFirestore = firestore ?? FirebaseFirestore.instance;

  Future<List<HomeModel>> fetchAllExceptCurrentUser() async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;

      // Fetch all profiles where 'id' is not equal to current user's uid
      final snapshot =
          await firebaseFirestore
              .collection('user')
              .where('id', isNotEqualTo: uid)
              .get();

      return snapshot.docs.map((doc) => HomeModel.fromMap(doc.data())).toList();
    } catch (e) {
      rethrow;
    }
  }
}
