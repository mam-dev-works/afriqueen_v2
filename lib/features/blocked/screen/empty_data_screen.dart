import 'package:afriqueen/common/constant/constant_colors.dart';
import 'package:afriqueen/common/localization/enums/enums.dart';
import 'package:afriqueen/features/blocked/widgets/blocked_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';

class NoData extends StatelessWidget {
  const NoData({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(55.h),
        child: BlockedScreenAppBar(),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              HugeIcons.strokeRoundedBlocked,
              size: 80.sp,
              color: AppColors.grey,
            ),
            SizedBox(height: 20.h),
            Text(
              EnumLocale.noBlockedUsers.name.tr,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.grey,
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              EnumLocale.emptyBlockedUsers.name.tr,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 