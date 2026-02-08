import 'package:afriqueen/common/localization/enums/enums.dart';
import 'package:afriqueen/common/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class ActivityTabs extends StatelessWidget {
  const ActivityTabs({
    super.key,
    required this.selectedMainTabIndex,
    required this.selectedSubTabIndex,
    required this.onMainTabSelected,
    required this.onSubTabSelected,
    required this.statisticsText,
  });

  final int selectedMainTabIndex;
  final int selectedSubTabIndex;
  final ValueChanged<int> onMainTabSelected;
  final ValueChanged<int> onSubTabSelected;
  final String statisticsText;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Column(
        children: [
          Container(
            height: 32.h,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildMainTab(EnumLocale.activityVus.name.tr, 0,
                    selectedMainTabIndex == 0, 0),
                _buildMainTab(EnumLocale.activityLikes.name.tr, 1,
                    selectedMainTabIndex == 1, 0),
                _buildMainTab(EnumLocale.activityCadeaux.name.tr, 2,
                    selectedMainTabIndex == 2, 0),
                _buildMainTab(EnumLocale.activityStory.name.tr, 3,
                    selectedMainTabIndex == 3, 0),
                _buildMainTab(EnumLocale.activityEvenement.name.tr, 4,
                    selectedMainTabIndex == 4, 0),
              ],
            ),
          ),
          SizedBox(height: 6.h),
          Container(
            height: 32.h,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: _buildSubTabs(),
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: Text(
                  statisticsText,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.grey,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMainTab(String title, int index, bool isSelected, int count) {
    return Container(
      margin: EdgeInsets.only(right: 8.w),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16.r),
          onTap: () => onMainTabSelected(index),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: isSelected ? Color(0xFFF7BD8E) : Colors.transparent,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: isSelected ? Color(0xFFF7BD8E) : Colors.grey.shade300,
                width: 1.w,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : AppColors.black,
                  ),
                ),
                if (count > 0) ...[
                  SizedBox(width: 4.w),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Text(
                      count.toString(),
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubTab(String title, int index, bool isSelected, int count) {
    return Container(
      margin: EdgeInsets.only(right: 8.w),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16.r),
          onTap: () => onSubTabSelected(index),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: isSelected ? Color(0xFFF7BD8E) : Colors.transparent,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: isSelected ? Color(0xFFF7BD8E) : Colors.grey.shade300,
                width: 1.w,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : AppColors.black,
                  ),
                ),
                if (count > 0) ...[
                  SizedBox(width: 4.w),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Text(
                      count.toString(),
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildSubTabs() {
    if (selectedMainTabIndex == 1) {
      return [
        _buildSubTab(
            EnumLocale.activityLikeRecu.name.tr, 0, selectedSubTabIndex == 0, 0),
        _buildSubTab(
            EnumLocale.activityMatch.name.tr, 1, selectedSubTabIndex == 1, 0),
        _buildSubTab(EnumLocale.activityJaiLike.name.tr, 2,
            selectedSubTabIndex == 2, 0),
      ];
    } else if (selectedMainTabIndex == 2) {
      return [
        _buildSubTab(EnumLocale.activityCadeauxRecu.name.tr, 0,
            selectedSubTabIndex == 0, 0),
        _buildSubTab(EnumLocale.activityCadeauxEnvoye.name.tr, 1,
            selectedSubTabIndex == 1, 0),
        _buildSubTab(EnumLocale.activityMesCadeaux.name.tr, 2,
            selectedSubTabIndex == 2, 0),
      ];
    } else if (selectedMainTabIndex == 3) {
      return [
        _buildSubTab(
            EnumLocale.activityVu.name.tr, 0, selectedSubTabIndex == 0, 0),
        _buildSubTab(
            EnumLocale.activityLike.name.tr, 1, selectedSubTabIndex == 1, 0),
        _buildSubTab(EnumLocale.activityMesStory.name.tr, 2,
            selectedSubTabIndex == 2, 0),
      ];
    } else if (selectedMainTabIndex == 4) {
      return [
        _buildSubTab(EnumLocale.activityEventIlsOntParticipe.name.tr, 0,
            selectedSubTabIndex == 0, 0),
        _buildSubTab(EnumLocale.activityEventJaiParticipe.name.tr, 1,
            selectedSubTabIndex == 1, 0),
        _buildSubTab(EnumLocale.activityEventMesEvenements.name.tr, 2,
            selectedSubTabIndex == 2, 0),
      ];
    } else {
      return [
        _buildSubTab(
            EnumLocale.activityOnMaVu.name.tr, 0, selectedSubTabIndex == 0, 0),
        _buildSubTab(
            EnumLocale.activityJaiVu.name.tr, 1, selectedSubTabIndex == 1, 0),
      ];
    }
  }
}
