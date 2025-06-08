import 'package:afriqueen/common/widgets/steps.dart';
import 'package:afriqueen/features/create_profile/widget/address_screen_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AddressScreen extends StatelessWidget {
  const AddressScreen({super.key});

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
                const CustomSteps(currentStep: 4),
                //----------------Text Regarding name Title--------------------------
                const AddressTitle(),

                //----------------Text Regarding name description--------------------------
                const AddressDescription(),
                SizedBox(height: 20.h),
                //------------------Location of the user------------------------
                const Location(),
                SizedBox(height: 80.h),
                //----------------- Button to naviagte next page------------
                AddressNextButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
