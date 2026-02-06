import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:afriqueen/common/localization/enums/enums.dart';
import 'package:afriqueen/common/theme/app_colors.dart';
import 'package:afriqueen/routes/app_routes.dart';
import 'package:afriqueen/services/account_management_service.dart';
import 'package:afriqueen/common/widgets/confirmation_dialog.dart';
import 'package:afriqueen/common/widgets/success_screen.dart';

class SuspendAccountScreen extends StatefulWidget {
  const SuspendAccountScreen({super.key});

  @override
  State<SuspendAccountScreen> createState() => _SuspendAccountScreenState();
}

class _SuspendAccountScreenState extends State<SuspendAccountScreen> {
  final AccountManagementService _accountService = AccountManagementService();
  bool _isLoading = false;

  Future<void> _suspendAccount() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final success = await _accountService.suspendAccount();
      
      if (success) {
        Get.back(); // Close the suspend screen first
        SuccessScreen.showAccountSuspendedSuccess();
      } else {
        Get.snackbar(
          'Error',
          'Failed to suspend account. Please try again.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred while suspending your account',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 20.sp,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          EnumLocale.suspendAccountTitle.name.tr,
          style: TextStyle(
            color: Colors.black,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          children: [
            SizedBox(height: 40.h),
            // Main title
            Text(
              EnumLocale.suspendAccountMainTitle.name.tr,
              style: TextStyle(
                color: Colors.black,
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20.h),
            // Description
            Text(
              EnumLocale.suspendAccountDescription.name.tr,
              style: TextStyle(
                color: Colors.black,
                fontSize: 16.sp,
                fontWeight: FontWeight.w400,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 60.h),
            // Action buttons
            Row(
              children: [
                // Cancel button
                Expanded(
                  child: Container(
                    height: 44.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: TextButton(
                      onPressed: () => Get.back(),
                      child: Text(
                        EnumLocale.suspendAccountCancel.name.tr,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                // Suspend button
                Expanded(
                  child: Container(
                    height: 44.h,
                    decoration: BoxDecoration(
                      color: Color(0xFFF7BD8E), // Orange/peach color
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: TextButton(
                      onPressed: _isLoading ? null : () {
                        ConfirmationDialogs.showSuspendAccountConfirmation(
                          onConfirm: _suspendAccount,
                        );
                      },
                      child: _isLoading
                          ? SizedBox(
                              width: 20.w,
                              height: 20.w,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.w,
                              ),
                            )
                          : Text(
                              EnumLocale.suspendAccountSuspend.name.tr,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 270.h),
            // Bottom back button
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: (Get.width * 0.5) - 16.w, // Half width minus padding
                height: 44.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: AppColors.primaryColor),
                ),
                child: TextButton(
                  onPressed: () => Get.back(),
                  child: Text(
                    EnumLocale.suspendAccountBack.name.tr,
                    style: TextStyle(
                      color: AppColors.primaryColor,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }
}
