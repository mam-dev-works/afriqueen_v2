import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:afriqueen/services/storage/get_storage.dart';
import 'package:afriqueen/routes/app_routes.dart';
import 'package:afriqueen/common/widgets/logout_dialog.dart';
import 'package:flutter/material.dart';

class LogoutService {
  final FirebaseAuth _auth;
  final AppGetStorage _storage;

  LogoutService({
    FirebaseAuth? auth,
    AppGetStorage? storage,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _storage = storage ?? AppGetStorage();

  /// Logout the current user
  Future<bool> logout() async {
    try {
      // Sign out from Firebase Auth
      await _auth.signOut();
      
      // Clear local storage
      await _storage.clearAll();
      
      debugPrint('User logged out successfully');
      return true;
    } catch (e) {
      debugPrint('Error during logout: $e');
      return false;
    }
  }

  /// Show logout confirmation dialog and handle logout
  static void showLogoutConfirmation() {
    final logoutService = LogoutService();
    
    LogoutDialog.showLogoutDialog(
      onConfirm: () async {
        try {
          final success = await logoutService.logout();
          
          if (success) {
            // Navigate to login screen
            Get.offAllNamed(AppRoutes.login);
          } else {
            Get.snackbar(
              'Error',
              'Failed to logout. Please try again.',
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
          }
        } catch (e) {
          Get.snackbar(
            'Error',
            'An error occurred during logout',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      },
    );
  }
}
