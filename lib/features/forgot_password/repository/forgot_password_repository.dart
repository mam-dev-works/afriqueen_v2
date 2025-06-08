import 'package:afriqueen/features/forgot_password/models/forgot_password_models.dart';
import 'package:afriqueen/services/storage/get_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

//--------------------------- Repository for FP screen------------------------------
class ForgotPasswordRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AppGetStorage appGetStorage = AppGetStorage();
  String? error;

  Future<void> sendEmailToRestPassword(ForgotPasswordModel model) async {
    try {
      await _auth.setLanguageCode(appGetStorage.getLanguageCode());
      await _auth.sendPasswordResetEmail(email: model.email);
    } on FirebaseAuthException catch (e) {
      error = e.message;
      rethrow;
    } catch (e) {
      error = e.toString();
      rethrow;
    }
  }
}
