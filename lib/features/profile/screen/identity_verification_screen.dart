import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:afriqueen/common/localization/enums/enums.dart';
import 'package:afriqueen/common/theme/app_colors.dart';
import 'package:afriqueen/routes/app_routes.dart';

class IdentityVerificationScreen extends StatefulWidget {
  const IdentityVerificationScreen({super.key});

  @override
  State<IdentityVerificationScreen> createState() => _IdentityVerificationScreenState();
}

class _IdentityVerificationScreenState extends State<IdentityVerificationScreen> {
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
          EnumLocale.identityVerificationTitle.name.tr,
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
            SizedBox(height: 20.h),
            // Photo upload area
            Container(
              width: double.infinity,
              height: 300.h,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Camera icon
                  Container(
                    width: 80.w,
                    height: 80.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Color(0xFFE57373), // Red color for the circle
                        width: 2.w,
                      ),
                    ),
                    child: Icon(
                      Icons.add,
                      color: Color(0xFFE57373), // Red color for the plus
                      size: 40.sp,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  // Take photo text
                  Text(
                    EnumLocale.identityVerificationTakePhoto.name.tr,
                    style: TextStyle(
                      color: Color(0xFFE57373), // Red color for the text
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 170.h),
            // Bottom buttons
            Row(
              children: [
                // Back button
                Expanded(
                  child: Container(
                    height: 44.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: AppColors.primaryColor),
                    ),
                    child: TextButton(
                      onPressed: () => Get.back(),
                      child: Text(
                        EnumLocale.identityVerificationBack.name.tr,
                        style: TextStyle(
                          color: AppColors.primaryColor,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                // Send button
                Expanded(
                  child: Container(
                    height: 44.h,
                    decoration: BoxDecoration(
                      color: Color(0xFFF7BD8E), // Orange/peach color
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: TextButton(
                      onPressed: () {
                        // TODO: Implement photo upload and verification
                        Get.snackbar(
                          'Success',
                          'Photo uploaded successfully',
                          backgroundColor: Colors.green,
                          colorText: Colors.white,
                        );
                        Get.back();
                      },
                      child: Text(
                        EnumLocale.identityVerificationSend.name.tr,
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
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }
}
