import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:afriqueen/common/localization/enums/enums.dart';

class SuccessScreen extends StatelessWidget {
  final String message;
  final VoidCallback? onComplete;

  const SuccessScreen({
    super.key,
    required this.message,
    this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 40.w),
          child: Text(
            message,
            style: TextStyle(
              color: Colors.black,
              fontSize: 18.sp,
              fontWeight: FontWeight.w400,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  // Convenience methods for common success screens
  static void showAccountSuspendedSuccess() {
    Get.dialog(
      SuccessScreen(
        message: EnumLocale.accountSuspendedSuccess.name.tr,
      ),
      barrierDismissible: false,
    );
  }

  static void showAccountDeletedSuccess() {
    Get.dialog(
      SuccessScreen(
        message: EnumLocale.accountDeletedSuccess.name.tr,
      ),
      barrierDismissible: false,
    );
  }
}
