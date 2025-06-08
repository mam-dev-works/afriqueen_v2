import 'package:afriqueen/features/forgot_password/bloc/forgot_password_bloc.dart';
import 'package:afriqueen/features/forgot_password/bloc/forgot_password_state.dart';
import 'package:afriqueen/features/forgot_password/widgets/forgot_password_widgets.dart';
import 'package:afriqueen/common/localization/enums/enums.dart';
import 'package:afriqueen/common/widgets/snackbar_message.dart';
import 'package:afriqueen/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class EmailSentScreen extends StatelessWidget {
  const EmailSentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: true),
      body: SafeArea(
        child: BlocListener<ForgotPasswordBloc, ForgotPasswordState>(
          listener: (context, state) => _listener(context, state),
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 20.h),
                  HeadingInSuccessedPage(),
                  SizedBox(height: 5.h),
                  BodyWidgetInSuccessedPage(),
                  CenterImageInSuccessedPage(),
                  SizedBox(height: 100.h),
                  SendButtonInSuccessedPage(),
                  SizedBox(height: 10.h),
                  DidnotRecieveTheLink(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _listener(BuildContext context, ForgotPasswordState state) {
    if (state is ForgotPasswordSuccess) {
      Get.back(); // Loading modal varsa kapatır
      debugPrint("Successs");
      snackBarMessage(
        context,
        EnumLocale.passwordChangeSuccess.name.tr,
        Theme.of(context),
      );
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.main,
            (Route<dynamic> route) => false,
      );
    }
  }
}
