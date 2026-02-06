import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VisibilityRepository {
  final FirebaseFirestore _firestore;

  VisibilityRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<Map<String, List<String>>> fetchInvisibilityPreferences() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return {
      'invisibleToProfileTypes': <String>[],
      'invisibleToSexes': <String>[],
      'invisibleToOrientations': <String>[],
    };

    final userQuery = await _firestore
        .collection('user')
        .where('id', isEqualTo: currentUser.uid)
        .limit(1)
        .get();

    if (userQuery.docs.isEmpty) {
      return {
        'invisibleToProfileTypes': <String>[],
        'invisibleToSexes': <String>[],
        'invisibleToOrientations': <String>[],
      };
    }

    final data = userQuery.docs.first.data();
    return {
      'invisibleToProfileTypes': List<String>.from(data['invisibleToProfileTypes'] ?? []),
      'invisibleToSexes': List<String>.from(data['invisibleToSexes'] ?? []),
      'invisibleToOrientations': List<String>.from(data['invisibleToOrientations'] ?? []),
    };
  }

  Future<void> updateInvisibilityPreferences({
    required List<String> invisibleToProfileTypes,
    required List<String> invisibleToSexes,
    List<String>? invisibleToOrientations,
  }) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final userQuery = await _firestore
        .collection('user')
        .where('id', isEqualTo: currentUser.uid)
        .limit(1)
        .get();

    if (userQuery.docs.isEmpty) return;

    await userQuery.docs.first.reference.update({
      'invisibleToProfileTypes': invisibleToProfileTypes,
      'invisibleToSexes': invisibleToSexes,
      if (invisibleToOrientations != null)
        'invisibleToOrientations': invisibleToOrientations,
    });
  }
}


