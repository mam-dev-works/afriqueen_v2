//------------ main part of data fetched state-----------------

import 'package:afriqueen/common/constant/constant_colors.dart';
import 'package:afriqueen/features/home/widget/data_fetched_screen_widgets.dart';
import 'package:afriqueen/features/home/widget/home_widgets.dart';
import 'package:afriqueen/features/stories/screen/stories_screen.dart';
import 'package:afriqueen/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class HomeDataContent extends StatelessWidget {
  const HomeDataContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: RefreshIndicator(
      color: AppColors.primaryColor,
      backgroundColor: AppColors.floralWhite,
      onRefresh: () async {
        Get.toNamed(AppRoutes.main);
        await Future.delayed(Duration(milliseconds: 1));
      },
      child: CustomScrollView(
        slivers: [
          //-------------------app bar-------------------
          HomeAppBar(),
          //-------------------Stories-------------------
          StoriesScreen(),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 3.w),
              //-----------User profile grid-------------------------
              child: UserImageGrid(),
            ),
          ),
        ],
      ),
    ));
  }
}
