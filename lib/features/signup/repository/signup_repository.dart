import 'package:afriqueen/common/localization/enums/enums.dart';
import 'package:afriqueen/features/signup/models/signup_model.dart';
import 'package:afriqueen/services/storage/get_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:google_sign_in/google_sign_in.dart';

///------------------ Repository for handling sign-up logic------------------
class SignupRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final AppGetStorage appGetStorage = AppGetStorage();
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  String? errorMessge;
  bool isExistingUser = false;

  SignupRepository({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  ///-------------------- Sign up a user with email and password----------------------------
  Future<UserCredential?> signupWithEmail(SignUpModel signupModel) async {
    try {
      await _firebaseAuth.setLanguageCode(appGetStorage.getLanguageCode());
      final UserCredential credential = await _firebaseAuth
          .createUserWithEmailAndPassword(
            email: signupModel.email,
            password: signupModel.password,
          );
      debugPrint("Current user ID :${credential.user!.uid}");
      return credential;
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase Auth Exception: ${e.code} - ${e.message}');

      if (e.code == 'weak-password') {
        errorMessge = EnumLocale.weakPassword.name.tr;
      } else if (e.code == 'email-already-in-use') {
        errorMessge = EnumLocale.emailAlreadyExists.name.tr;
      } else {
        errorMessge = EnumLocale.defaultError.name.tr;
      }
    } catch (e) {
      errorMessge = EnumLocale.defaultError.name.tr;
    }

    return null;
  }

  ///-------------------- Sign up a user with Google----------------------------
  Future<UserCredential?> signupWithGoogle() async {
    try {
      await _googleSignIn.signOut();
      
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        errorMessge = EnumLocale.googleSignInCancelled.name.tr;
        return null;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);

      try {
        final user = userCredential.user;
        if (user != null) {
          final querySnapshot = await _firestore
              .collection('user')
              .where('id', isEqualTo: user.uid)
              .limit(1)
              .get();

          if (querySnapshot.docs.isNotEmpty) {
            isExistingUser = true;
            debugPrint("User already exists in Firestore with UID: ${user.uid}");
          } else {
            isExistingUser = false;
            debugPrint("New user with UID: ${user.uid}, proceeding to profile setup");
          }
        } else {
          debugPrint("No user found in Firebase Auth");
          isExistingUser = false;
        }
      } catch (e) {
        debugPrint('Error checking user in Firestore: $e');
        isExistingUser = false;
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase Auth Exception: ${e.code} - ${e.message}');
      errorMessge = EnumLocale.defaultError.name.tr;
    } catch (e) {
      debugPrint('Error during Google sign-in: $e');
      errorMessge = EnumLocale.defaultError.name.tr;
    }
    return null;
  }
}
