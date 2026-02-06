import 'package:afriqueen/common/constant/constant_colors.dart';
import 'package:afriqueen/common/constant/constant_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// --------------------light Theme Of App------------------------
ThemeData lightTheme = ThemeData(
  scaffoldBackgroundColor: AppColors.floralWhite,

  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.floralWhite,
    elevation: 0.0,
    scrolledUnderElevation: 0.0,
  ),
  textTheme: TextTheme(
    // for  heading
    bodyLarge: TextStyle(
      color: AppColors.black,
      fontSize: 26.sp,
      fontFamily: AppStrings.robotosSemiBold,
    ),
    // for body text
    bodyMedium: TextStyle(
      color: AppColors.black,
      fontSize: 16.sp,
      fontFamily: AppStrings.robotoLight,
    ),

    // for description text
    bodySmall: TextStyle(
      color: AppColors.grey,
      fontSize: 15.sp,
      fontFamily: AppStrings.robotThin,
    ),
  ),
);
