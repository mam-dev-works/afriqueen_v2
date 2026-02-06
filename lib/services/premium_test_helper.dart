import 'package:flutter/material.dart';
import 'package:afriqueen/services/premium_service.dart';

class PremiumTestHelper {
  static final PremiumService _premiumService = PremiumService();

  /// Test method to verify premium functionality
  static Future<void> testPremiumFunctionality(BuildContext context) async {
    try {
      // Check current status
      await _premiumService.debugUserStatus();
      
      // Set user as premium
      final success = await _premiumService.setPremiumStatus(true);
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Test: User set as premium. Check debug logs for status.'),
            duration: Duration(seconds: 3),
          ),
        );
        
        // Check status again
        await _premiumService.debugUserStatus();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Test: Failed to set premium status'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Test error: $e'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  /// Reset user to non-premium for testing
  static Future<void> resetToNonPremium(BuildContext context) async {
    try {
      final success = await _premiumService.setPremiumStatus(false);
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Test: User reset to non-premium'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Reset error: $e'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}
