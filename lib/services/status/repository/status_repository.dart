import 'package:afriqueen/services/status/model/status_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class StatusRepository {
  final FirebaseAuth firebaseAuth;
  StatusRepository({FirebaseAuth? auth})
    : firebaseAuth = auth ?? FirebaseAuth.instance;
  //-------------User Presence-------------------------
  void setupUserPresence() {
    final user = firebaseAuth.currentUser;
    if (user == null) return;

    final uid = user.uid;
    final userStatusDatabaseRef = FirebaseDatabase.instance.ref("status/$uid");

    final connectedRef = FirebaseDatabase.instance.ref(".info/connected");

    connectedRef.onValue.listen((event) {
      final isConnected = event.snapshot.value as bool? ?? false;

      if (isConnected) {
        userStatusDatabaseRef.onDisconnect().set({
          'state': false,
          'last_changed': ServerValue.timestamp,
        });

        userStatusDatabaseRef.set({
          'state': true,
          'last_changed': ServerValue.timestamp,
        });
      }
    });
  }


  Future<StatusModel?> getUserPreence(String id) async {
    final statusRef = FirebaseDatabase.instance.ref("status/$id");

    final DatabaseEvent event = await statusRef.once();

    final rawData = event.snapshot.value;

    if (rawData != null && rawData is Map) {
      final data = Map<String, dynamic>.from(rawData);
      return StatusModel.fromMap(data);
    }

    return null;
  }
}
