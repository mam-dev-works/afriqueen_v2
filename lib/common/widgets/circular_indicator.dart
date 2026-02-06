import 'package:afriqueen/common/constant/constant_colors.dart';
import 'package:flutter/material.dart';


//--------------circular indicator for app------------------------------------------
class CustomCircularIndicator extends StatelessWidget {
  const CustomCircularIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(color: AppColors.primaryColor),
      ),
    );
  }
}
