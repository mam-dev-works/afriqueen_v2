import 'package:afriqueen/common/constant/constant_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
//-------------------------------- button for app-------------------------------------------------
class CommonButton extends StatelessWidget {
  const CommonButton({
    super.key,
    required this.onPressed,
    required this.buttonText,
  });

  final void Function()? onPressed;
  final String buttonText;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: 40.h, // Slightly increased height for better touch target
        width: 200.w,
        child: ElevatedButton(
          // Using ElevatedButton for better default styling
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
          child: Ink(
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Container(
              alignment: Alignment.center,
              child: Text(
                buttonText,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium!.copyWith(color: AppColors.white),
              ),

              // Show indicator if loading and it's the login button
            ),
          ),
        ),
      ),
    );
  }
}
