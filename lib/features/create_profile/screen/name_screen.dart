import 'package:afriqueen/common/widgets/steps.dart';
import 'package:afriqueen/features/create_profile/widget/name_screen_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NameScreen extends StatelessWidget {
  NameScreen({super.key});

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 10.h,
                children: [
                  //---------------Stepper to show in which step they are in profile creation------------------------
                  const CustomSteps(currentStep: 1),
                  //----------------Text Regarding name Title--------------------------
                  const NameTitle(),

                  //----------------Text Regarding name description--------------------------
                  const NameDescription(),
                  SizedBox(height: 10.h),
                  //----------------- User input for pseudo---------
                  PseudoTextField(),
                  SizedBox(height: 100.h),
                  //----------------- Button to naviagte next page------------
                  NameNextButton(formKey: _formKey),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
