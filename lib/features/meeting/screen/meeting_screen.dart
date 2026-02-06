import 'package:afriqueen/common/constant/constant_colors.dart';
import 'package:afriqueen/features/home/repository/home_repository.dart';
import 'package:afriqueen/features/home/bloc/home_bloc.dart';
import 'package:afriqueen/features/home/bloc/home_event.dart';
import 'package:afriqueen/features/home/screen/home_screen.dart';
import 'package:afriqueen/features/home/screen/filter_screen.dart';
import 'package:afriqueen/features/match/screen/card_screen.dart';
import 'package:afriqueen/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../common/localization/enums/enums.dart';

class MeetingScreen extends StatefulWidget {
  const MeetingScreen({super.key});

  @override
  State<MeetingScreen> createState() => _MeetingScreenState();
}

class _MeetingScreenState extends State<MeetingScreen> {
  int _selectedTabIndex = 0; // 0 for Match, 1 for Liste

  void _onTabChanged(int index) {
    setState(() {
      _selectedTabIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final availableHeight = MediaQuery.of(context).size.height - 
                           MediaQuery.of(context).padding.top - // Status bar
                           kToolbarHeight - // App bar
                           kBottomNavigationBarHeight; // Bottom nav bar
    
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          // App Bar with home icon, Match/Liste tabs, and filter icon
          Container(
            height: kToolbarHeight + MediaQuery.of(context).padding.top,
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            color: AppColors.white,
            child: Row(
              children: [
                // Home Icon
                IconButton(
                  onPressed: () => Get.toNamed(AppRoutes.profileHome),
                  icon: Icon(
                    Icons.home_outlined,
                    size: 22.r,
                    color: AppColors.black,
                  ),
                ),
                
                // Match/Liste Tabs in center
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Match Tab
                      GestureDetector(
                        onTap: () => _onTabChanged(0),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                          decoration: BoxDecoration(
                            color: _selectedTabIndex == 0 ? Color(0xFFF7BD8E) : Colors.transparent,
                            borderRadius: BorderRadius.circular(18.r),
                            border: Border.all(
                              color: _selectedTabIndex == 0 ? Color(0xFFF7BD8E) : Colors.grey.shade300,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            EnumLocale.match.name.tr,
                            style: TextStyle(
                              color: AppColors.black,
                              fontSize: 13.sp,
                              fontWeight: _selectedTabIndex == 0 ? FontWeight.w600 : FontWeight.w400,
                              fontFamily: 'Roboto-SemiBold',
                            ),
                          ),
                        ),
                      ),
                      
                      SizedBox(width: 12.w),
                      
                      // Liste Tab
                      GestureDetector(
                        onTap: () => _onTabChanged(1),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                          decoration: BoxDecoration(
                            color: _selectedTabIndex == 1 ? Color(0xFFF7BD8E) : Colors.transparent,
                            borderRadius: BorderRadius.circular(18.r),
                            border: Border.all(
                              color: _selectedTabIndex == 1 ? Color(0xFFF7BD8E) : Colors.grey.shade300,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            EnumLocale.homeTitle.name.tr,
                            style: TextStyle(
                              color: AppColors.black,
                              fontSize: 13.sp,
                              fontWeight: _selectedTabIndex == 1 ? FontWeight.w600 : FontWeight.w400,
                              fontFamily: 'Roboto-SemiBold',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Filter Icon
                IconButton(
                  onPressed: () => Get.to(() => const FilterScreen()),
                  icon: Icon(
                    Icons.tune_outlined,
                    size: 22.r,
                    color: AppColors.black,
                  ),
                ),
              ],
            ),
          ),
          
          // Content based on selected tab - NO SCROLL
          Expanded(
            child: Container(
              width: double.infinity,
              child: _selectedTabIndex == 0
                  ? const _NoScrollCardScreen()
                  : BlocProvider(
                      create: (context) => HomeBloc(repo: HomeRepository())..add(HomeUsersProfileList()),
                      child: const _NoScrollHomeScreen(),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// Non-scrollable wrapper for CardScreen
class _NoScrollCardScreen extends StatelessWidget {
  const _NoScrollCardScreen();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: const CardScreen(),
    );
  }
}

// Non-scrollable wrapper for HomeScreen
class _NoScrollHomeScreen extends StatelessWidget {
  const _NoScrollHomeScreen();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: const HomeScreen(),
    );
  }
}
