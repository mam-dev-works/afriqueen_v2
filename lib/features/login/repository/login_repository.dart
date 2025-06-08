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
  final FirebaseFirestore _firestore;
  final AppGetStorage appGetStorage = AppGetStorage();
  String? error;
  bool isExistingUser = false;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
    ],
  );


  LoginRepository({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  //------------------------------login with Email ------------------------------------------
  Future<UserCredential?> loginWithEmail(LoginModel loginModel) async {
    try {
      await _auth.setLanguageCode(appGetStorage.getLanguageCode());
      final UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: loginModel.email,
        password: loginModel.password,
      );
      debugPrint("Current user ID :${credential.user!.uid}");

      try {
        final user = credential.user;
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

      return credential;
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase Auth Exception: ${e.code} - ${e.message}');
      null; // Important: clear the credential if login fails!

      if (e.code == 'user-not-found') {
        error = EnumLocale.userNotFoundError.name.tr;
      } else if (e.code == 'wrong-password') {
        error = EnumLocale.wrongPasswordError.name.tr;
      } else {
        error = EnumLocale.defaultError.name.tr;
      }
    } catch (e) {
      error = EnumLocale.defaultError.name.tr;
    };
    return null;
  }

  //----------------------login with google----------------------------
  Future<UserCredential?> loginWithGoogle() async {
    try {
      // First, sign out from any existing Google Sign In session
      await _googleSignIn.signOut();
      await _auth.signOut();
      
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        debugPrint("Google Sign In was cancelled by user");
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final userCredential = await _auth.signInWithCredential(credential);

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
      };

      debugPrint("Google Sign In successful: ${userCredential.user?.email}");
      return userCredential;
      
    } on FirebaseAuthException catch (e) {
      debugPrint("Firebase Auth Error: ${e.code} - ${e.message}");
      error = e.message ?? EnumLocale.defaultError.name.tr;
    } catch (e) {
      debugPrint("Google Sign In Error: $e");
      error = EnumLocale.defaultError.name.tr;
    }
    return null;
  }
}
