import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:afriqueen/common/theme/app_colors.dart';
import 'package:afriqueen/common/localization/enums/enums.dart';

class PremiumPlansScreen extends StatelessWidget {
  const PremiumPlansScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // plans are directly built from localized strings below

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back_ios_new, color: AppColors.black, size: 20.r),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Text(
              EnumLocale.premiumBenefitsTitle.name.tr,
              style: TextStyle(
                color: AppColors.black,
                fontWeight: FontWeight.w700,
                fontSize: 14.sp,
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Bullet(text: EnumLocale.premiumBenefitSpecialGifts.name.tr),
                _Bullet(text: EnumLocale.premiumBenefitUpTo5Stories.name.tr),
                _Bullet(text: EnumLocale.premiumBenefitUpTo5Events.name.tr),
                _Bullet(text: EnumLocale.premiumBenefitAccessBlockFilters.name.tr),
                _Bullet(text: EnumLocale.premiumBenefitPrioritySupport.name.tr),
              ],
            ),
          ),
          SizedBox(height: 24.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Wrap(
              spacing: 16.w,
              runSpacing: 16.h,
              children: [
                _PlanCard(title: EnumLocale.premiumPlan1Month.name.tr, price: EnumLocale.premiumPrice2000.name.tr),
                _PlanCard(title: EnumLocale.premiumPlan3Months.name.tr, price: EnumLocale.premiumPrice4000.name.tr),
                _PlanCard(title: EnumLocale.premiumPlan6Months.name.tr, price: EnumLocale.premiumPrice6000.name.tr),
                _PlanCard(title: EnumLocale.premiumPlan1Year.name.tr, price: EnumLocale.premiumPrice10000.name.tr),
              ],
            ),
          ),
          SizedBox(height: 80.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                height: 44.h,
                padding: EdgeInsets.symmetric(horizontal: 18.w),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(22.r),
                  border: Border.all(color: AppColors.primaryColor),
                ),
                child: TextButton(
                  onPressed: () => Get.back(),
                  child: Text(
                    EnumLocale.premiumBack.name.tr,
                    style: TextStyle(
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 15.sp,
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('•  ', style: TextStyle(fontSize: 14.sp)),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 14.sp, color: AppColors.black),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.title, required this.price});
  final String title;
  final String price;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150.w,
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 10.w),
      decoration: BoxDecoration(
        color: Color(0xFF616BB3),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12.sp),
          ),
          SizedBox(height: 6.h),
          Text(
            price,
            style: TextStyle(color: Colors.white, fontSize: 11.sp),
          ),
          SizedBox(height: 8.h),
          Container(
            height: 30.h,
            width: 90.w,
            decoration: BoxDecoration(
              color: Color(0xFF343C7D),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: TextButton(
              onPressed: () {},
              child: Text(
                EnumLocale.premiumChoose.name.tr,
                style: TextStyle(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
