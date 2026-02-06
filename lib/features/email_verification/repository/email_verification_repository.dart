import 'package:afriqueen/services/storage/get_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EmailVerificationRepository {
  final FirebaseAuth _firebaseAuth;
  final AppGetStorage appGetStorage = AppGetStorage();
  //------------------To control delete , emailverification----------------------------
  EmailVerificationRepository({FirebaseAuth? auth})
    : _firebaseAuth = auth ?? FirebaseAuth.instance;
  //----------------------Sending link for email verification--------------------------
  Future<void> sendEmailVerificationLink() async {
    await _firebaseAuth.setLanguageCode(appGetStorage.getLanguageCode());
    final currentUser = _firebaseAuth.currentUser;
    try {
      if (!currentUser!.emailVerified) {
        await currentUser.sendEmailVerification();
      }
    } catch (e) {
      debugPrint("Error: in email verifcation ${e.toString()}");

      rethrow;
    }
  }

  //--------------checking whether user verified or not email-----------------------
  Future<bool> isEmailVerified() async {
    await _firebaseAuth.currentUser!.reload();
    return _firebaseAuth.currentUser!.emailVerified;
  }

  Future deleteAccount() async {
    await _firebaseAuth.currentUser!.delete();
  }
}
