import 'package:afriqueen/common/constant/constant_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';

class CustomSteps extends StatelessWidget {
  const CustomSteps({super.key, required this.currentStep});
  final int currentStep;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 30.h),
      child: StepProgressIndicator(
        size: 4.0.h,
        padding: 2.0.w,
        totalSteps: 7,
        currentStep: currentStep,
        selectedColor: AppColors.primaryColor,
      ),
    );
  }
}
