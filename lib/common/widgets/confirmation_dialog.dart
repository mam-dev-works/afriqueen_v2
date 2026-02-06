import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:afriqueen/common/localization/enums/enums.dart';

class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String yesText;
  final String noText;
  final VoidCallback onYes;
  final VoidCallback? onNo;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.yesText,
    required this.noText,
    required this.onYes,
    this.onNo,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Container(
        width: 280.w,
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            Text(
              title,
              style: TextStyle(
                color: Colors.grey[800],
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            // Horizontal line
            Container(
              height: 1.h,
              color: Colors.grey[300],
            ),
            SizedBox(height: 16.h),
            // Buttons
            Row(
              children: [
                // No button
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Get.back();
                      onNo?.call();
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      child: Text(
                        noText,
                        style: TextStyle(
                          color: Colors.grey[800],
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                // Vertical line
                Container(
                  width: 1.w,
                  height: 40.h,
                  color: Colors.grey[300],
                ),
                // Yes button
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Get.back();
                      onYes();
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      child: Text(
                        yesText,
                        style: TextStyle(
                          color: Colors.grey[800],
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Convenience methods for common dialogs
class ConfirmationDialogs {
  static void showSuspendAccountConfirmation({
    required VoidCallback onConfirm,
  }) {
    Get.dialog(
      ConfirmationDialog(
        title: EnumLocale.suspendAccountConfirmationTitle.name.tr,
        yesText: EnumLocale.suspendAccountConfirmationYes.name.tr,
        noText: EnumLocale.suspendAccountConfirmationNo.name.tr,
        onYes: onConfirm,
      ),
      barrierDismissible: true,
    );
  }

  static void showDeleteAccountConfirmation({
    required VoidCallback onConfirm,
  }) {
    Get.dialog(
      ConfirmationDialog(
        title: EnumLocale.deleteAccountConfirmationTitle.name.tr,
        yesText: EnumLocale.deleteAccountConfirmationYes.name.tr,
        noText: EnumLocale.deleteAccountConfirmationNo.name.tr,
        onYes: onConfirm,
      ),
      barrierDismissible: true,
    );
  }
}
