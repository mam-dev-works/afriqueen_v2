import 'package:afriqueen/features/forgot_password/widgets/forgot_password_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

//--------------------------------------- main screen of Forgot password---------------------------------------
class ForgotPasswordScreen extends StatelessWidget {
  ForgotPasswordScreen({super.key});

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: true),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,

                children: [
                  SizedBox(height: 20.h),
                  //-------------Forgot password text----------------------
                  const Heading(),
                  SizedBox(height: 5.h),
                  //-------------Instruction text----------------------
                  const BodyWidget(),
                  //------------Center image of Email----------------------
                  const CenterImage(),
                  //-------------User input for email----------------------
                  const Email(),
                  SizedBox(height: 25.h),
                  //-------------Remember password ----------------------
                  const RememberPassword(),
                  SizedBox(height: 10.h),
                  // ---------------Email send Button--------------------------------------------
                  SendButton(formKey: _formKey),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
