import 'package:afriqueen/common/widgets/steps.dart';
import 'package:afriqueen/features/create_profile/widget/create_profile_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class InterestsScreen extends StatelessWidget {
  const InterestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w).copyWith(top: 20.h),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 10.h,
              children: [
                //---------------Stepper to show in which step they are in profile creation------------------------
                CustomSteps(currentStep: 5),
                //-------------Title text-----------------------------------
                const InterestTitle(),
                //----------------------friendship text------------------------
                const FriendshipText(),
                //----------------Inchoice--------------------------
                const FriendshipInchoice(),
                //---------------------Love text----------------------------
                const LoveText(),
                //---------------- love inchoice--------------------------
                const LoveInchoice(),

                //---------------------Sports text----------------------------
                const SportsText(),
                //---------------- Sports inchoice--------------------------
                const SportsInchoice(),

                SizedBox(height: 15.h),
                InterestsNextButton(),
                SizedBox(height: 15.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
