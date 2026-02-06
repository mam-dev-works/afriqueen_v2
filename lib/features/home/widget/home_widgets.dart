//----------------AppBar -----------------------
import 'package:afriqueen/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:afriqueen/common/constant/constant_colors.dart';
import 'package:afriqueen/common/localization/enums/enums.dart';
import 'package:afriqueen/features/home/screen/filter_screen.dart';

import 'package:line_icons/line_icons.dart';

//-------------------App Bar-------------------------------
class HomeAppBar extends StatelessWidget {
  final int selectedTabIndex;
  
  const HomeAppBar({super.key, required this.selectedTabIndex});

  String _getTitle() {
    switch (selectedTabIndex) {
      case 0:
        return EnumLocale.homeTitleNew.name.tr;
      case 1:
        return EnumLocale.homeTitleLiked.name.tr;
      case 2:
        return EnumLocale.homeTitleFavorites.name.tr;
      case 3:
        return EnumLocale.homeTitleArchive.name.tr;
      case 4:
        return EnumLocale.homeTitleAll.name.tr;
      default:
        return EnumLocale.homeTitle.name.tr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      centerTitle: true,
      toolbarHeight: 1.h, // Reduced toolbar height for home screen
      actions: [
        SizedBox.shrink(), // Remove filter icon
      ],
      leading: SizedBox.shrink(), // Remove home icon
    );
  }
}

//-------------------Navigation Tabs-------------------------------
class NavigationTabs extends StatelessWidget {
  final Function(int) onTabChanged;
  final int selectedIndex;
  
  const NavigationTabs({
    super.key, 
    required this.onTabChanged,
    required this.selectedIndex,
  });

  List<String> get tabs => [
    EnumLocale.newTab.name.tr,
    EnumLocale.likedTab.name.tr,
    EnumLocale.favoritesTab.name.tr,
    EnumLocale.archiveTab.name.tr,
    EnumLocale.allTab.name.tr,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 20.h, // Minimal height for tabs
      padding: EdgeInsets.symmetric(horizontal: 18.w), // left: 18px
      margin: EdgeInsets.zero, // No margin
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: tabs.asMap().entries.map((entry) {
          final index = entry.key;
          final tab = entry.value;
          final isSelected = selectedIndex == index;
          
          return GestureDetector(
            onTap: () {
              onTabChanged(index);
            },
            child: Container(
              width: (MediaQuery.of(context).size.width - 36.w - 40.w) / 5, // Ekrana tam sığacak şekilde hesapla
              height: 25.h, // Further reduced height to match container
              margin: EdgeInsets.symmetric(horizontal: 4.w), // gap: 8px total
              padding: EdgeInsets.all(4.w), // Further reduced padding
              decoration: BoxDecoration(
                color: isSelected ? Color(0xFFF7BD8E) : Colors.transparent, // background: #F7BD8E
                borderRadius: BorderRadius.circular(13.r), // border-radius: 13px
                border: Border.all(
                  color: isSelected ? Color(0xFFF7BD8E) : Colors.grey.shade300,
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  tab,
                  style: TextStyle(
                    color: AppColors.black, // Tüm metinler siyah
                    fontSize: 9.sp, // Font boyutunu küçülttüm
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    fontFamily: 'Roboto-SemiBold',
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
