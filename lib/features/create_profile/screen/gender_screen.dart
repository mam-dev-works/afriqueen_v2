import 'package:afriqueen/common/widgets/steps.dart';
import 'package:afriqueen/features/create_profile/widget/gender_screen_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GenderScreen extends StatelessWidget {
  const GenderScreen({super.key});

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
              children: [
                // Stepper at the top
                const CustomSteps(currentStep: 2),
                SizedBox(height: 20.h),
                // New GenderScreen widget (contains all gender/orientation/relationship UI)
                GenderScreenWidget(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
