import 'package:afriqueen/services/storage/get_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:afriqueen/features/create_profile/screen/dob_location_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:afriqueen/features/create_profile/bloc/create_profile_bloc.dart';
import 'package:afriqueen/features/create_profile/repository/create_profile_repository.dart';

class PasswordlessLoginServices {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isExistingUser = false;

  Future<void> signInWithEmailandLink(String userEmail) async {
    AppGetStorage()
        .setLastEmail(userEmail); // Store email for global dynamic link handler
    debugPrint('Email stored for magic link: $userEmail');
    return await _auth
        .sendSignInLinkToEmail(
      email: userEmail,
      actionCodeSettings: ActionCodeSettings(
        url: 'https://afriqeen.page.link/XktS',
        // Use dynamic link domain
        handleCodeInApp: true,
        androidPackageName: 'com.company.afriqueen',
        androidMinimumVersion: "1",
        iOSBundleId: 'com.company.afriqueen',
      ),
    )
        .then((value) {
      print("email sent");
    });
  }

  Future<void> handleLink(
      Uri link, String userEmail, BuildContext context) async {
    debugPrint("link: $link");
    debugPrint("userEmail: $userEmail");
    debugPrint("link.queryParameters: ${link.queryParameters}");

    try {
      final UserCredential user = await _auth.signInWithEmailLink(
        email: userEmail,
        emailLink: link.toString(),
      );
      debugPrint("user: $user");
      if (user != null && user.user != null) {
        print('Authenticated email:  [32m${user.user!.email} [0m');
        final querySnapshot = await _firestore
            .collection('user')
            .where('id', isEqualTo: user.user?.uid)
            .limit(1)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          isExistingUser = true;
          debugPrint(
              "User already exists in Firestore with UID: ${user.user?.uid}");
        } else {
          isExistingUser = false;
          debugPrint(
              "New user with UID: ${user.user?.uid}, proceeding to profile setup");
        }
        if (isExistingUser) {
          Get.offAllNamed('/main');
        }
        else {
          Get.offAll(() => BlocProvider(
            create: (_) => CreateProfileBloc(repository: CreateProfileRepository()),
            child: DobLocationScreen(),
          ));
        }
      }
    } catch (e) {
      debugPrint("Firebase Auth Error: $e");
      print("Failed to sign in with email link: $e");
    }
  }
}
