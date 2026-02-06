import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:afriqueen/common/theme/app_colors.dart';
import 'package:afriqueen/common/localization/enums/enums.dart';

class ReferralScreen extends StatelessWidget {
  const ReferralScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String referralCode = 'GGF6634'; // TODO: replace with actual code from user profile

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back_ios_new, color: AppColors.black, size: 20.r),
        ),
        centerTitle: true,
        title: Text(
          EnumLocale.referralTitle.name.tr,
          style: TextStyle(color: AppColors.black, fontWeight: FontWeight.w600, fontSize: 16.sp),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
            child: Text(
              EnumLocale.referralYourCode.name.tr,
              style: TextStyle(color: AppColors.black, fontSize: 13.sp),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Container(
              height: 44.h,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      referralCode,
                      style: TextStyle(color: AppColors.black, fontWeight: FontWeight.w600, fontSize: 14.sp),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: 6.w),
                    child: Container(
                      height: 32.h,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7BD8E),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: TextButton(
                        onPressed: () async {
                          await Clipboard.setData(ClipboardData(text: referralCode));
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(EnumLocale.referralCopy.name.tr)),
                            );
                          }
                        },
                        child: Text(
                          EnumLocale.referralCopy.name.tr,
                          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.w600, fontSize: 13.sp),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 350.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 44.h,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: AppColors.primaryColor),
                    ),
                    child: TextButton(
                      onPressed: () => Get.back(),
                      child: Text(
                        EnumLocale.referralBack.name.tr,
                        style: TextStyle(color: AppColors.primaryColor, fontWeight: FontWeight.w600, fontSize: 15.sp),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Container(
                    height: 44.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7BD8E),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: TextButton(
                      onPressed: () {},
                      child: Text(
                        EnumLocale.referralInviteFriends.name.tr,
                        style: TextStyle(color: AppColors.white, fontWeight: FontWeight.w600, fontSize: 15.sp),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 46.h),
        ],
      ),
    );
  }
}
