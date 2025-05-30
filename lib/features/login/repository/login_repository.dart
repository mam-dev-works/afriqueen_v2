import 'package:afriqueen/common/localization/enums/enums.dart';
import 'package:afriqueen/features/login/models/login_model.dart';
import 'package:afriqueen/services/storage/get_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:google_sign_in/google_sign_in.dart';

// -------------------------Login logic-----------------------------
class LoginRepository {
  final FirebaseAuth _auth;
  final AppGetStorage appGetStorage = AppGetStorage();
  String? error;
  bool? isNewUser;
  LoginRepository({FirebaseAuth? firebaseauth})
    : _auth = firebaseauth ?? FirebaseAuth.instance;
  //------------------------------login with Email ------------------------------------------
  Future<UserCredential?> loginWithEmail(LoginModel loginModel) async {
    try {
      await _auth.setLanguageCode(appGetStorage.getLanguageCode());
      final UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: loginModel.email,
        password: loginModel.password,
      );
      debugPrint("Current user ID :${credential.user!.uid}");
      return credential;
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase Auth Exception: ${e.code} - ${e.message}');
      null; // Important: clear the credential if login fails!

      if (e.code == 'user-not-found') {
        error = EnumLocale.userNotFoundError.name.tr;
      } else if (e.code == 'wrong-password') {
        error = EnumLocale.wrongPasswordError.name.tr;
      } else {
        error = e.message ?? EnumLocale.defaultError.name.tr;
      }
    }
    return null;
  }

  //----------------------login with google----------------------------
  Future<UserCredential?> loginWithGoogle() async {
    try {
      GoogleSignInAccount? googleSignInAccount = await GoogleSignIn().signIn();
      GoogleSignInAuthentication? googleAuth =
          await googleSignInAccount!.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );
      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );

      return userCredential;
    } catch (e) {
      error = e.toString();
      debugPrint(e.toString());

      //
    }
    return null;
  }

  //-------------------- checking if user available or not---------------------
  Future<bool> checkUserAvaibility() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      QuerySnapshot<Map<String, dynamic>> checkUserData =
          await FirebaseFirestore.instance
              .collection('profile')
              .where('id', isEqualTo: user!.uid)
              .get();

      if (checkUserData.docs.isNotEmpty) {
        isNewUser = true;
      } else {
        isNewUser = false;
      }
    } catch (e) {
      debugPrint(e.toString());
    }

    return isNewUser!;
  }
}
