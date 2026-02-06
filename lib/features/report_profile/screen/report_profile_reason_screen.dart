import 'package:afriqueen/common/constant/constant_colors.dart';
import 'package:afriqueen/common/localization/enums/enums.dart';
import 'package:afriqueen/features/home/model/home_model.dart';
import 'package:afriqueen/features/report_profile/screen/report_profile_submit_screen.dart';
import 'package:afriqueen/features/report_profile/widgets/report_profile_user_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class ReportProfileReasonScreen extends StatelessWidget {
  ReportProfileReasonScreen({super.key, required this.user});

  final HomeModel user;

  final List<EnumLocale> _reasons = [
    EnumLocale.reportCategoryFakeProfile,
    EnumLocale.reportCategoryScam,
    EnumLocale.reportCategoryHarassment,
    EnumLocale.reportCategoryHateSpeech,
    EnumLocale.reportCategoryInappropriate,
    EnumLocale.reportCategorySexualContent,
    EnumLocale.reportCategorySpam,
    EnumLocale.reportCategoryOther,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(EnumLocale.reportProfileTitle.name.tr),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: Get.back,
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ReportProfileUserHeader(user: user),
            SizedBox(height: 16.h),
            Text(
              EnumLocale.reportProfileSecurityInfo.name.tr,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: 16.h),
            Text(
              EnumLocale.reportProfileChooseReason.name.tr,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            SizedBox(height: 12.h),
            Expanded(
              child: ListView.separated(
                itemCount: _reasons.length,
                separatorBuilder: (_, __) => SizedBox(height: 8.h),
                itemBuilder: (context, index) {
                  final reason = _reasons[index];
                  return _ReasonTile(
                    title: reason.name.tr,
                    onTap: () {
                      Get.to(
                        () => ReportProfileSubmitScreen(
                          user: user,
                          selectedReason: reason,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              EnumLocale.reportProfileWarning.name.tr,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            SizedBox(height: 12.h),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton(
                onPressed: Get.back,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.primaryColor),
                  foregroundColor: AppColors.primaryColor,
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                ),
                child: Text(EnumLocale.retour.name.tr),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReasonTile extends StatelessWidget {
  const _ReasonTile({
    required this.title,
    required this.onTap,
  });

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12.r),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey.shade300),
          color: Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      fontSize: 14.sp,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade600),
          ],
        ),
      ),
    );
  }
}

