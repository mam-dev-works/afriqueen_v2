import 'package:afriqueen/common/constant/constant_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
//------------------------ AlertDialog box with loading for login and signup-----------------------
void customLoading (BuildContext context){
  showDialog(
  context: context,
  barrierColor: Colors.transparent.withValues(alpha:0.1),
  builder: (BuildContext context) { // Specify the type of context
    return AlertDialog(
backgroundColor: AppColors.floralWhite ,
      content: SizedBox(
        width:double.minPositive.w,
        height: 70.h,
        child: Center(
          child:const CircularProgressIndicator(
            color: AppColors.primaryColor,
          ),
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4.r)
      ),
    );
  },
);
}