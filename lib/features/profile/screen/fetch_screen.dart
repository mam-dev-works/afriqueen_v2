//------------ main part of data fetched state-----------------
import 'package:afriqueen/features/profile/screen/main_container_screen.dart';
import 'package:afriqueen/features/profile/widget/profile_widget.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileDataContent extends StatelessWidget {
  const ProfileDataContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          //-------------------app bar-------------------
          ProfileAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 12.w,
              ).copyWith(top: 5.h, bottom: 80.h),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  //----------Main Container--------------
                  MainContainer(),
                  SizedBox(height: 30.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
