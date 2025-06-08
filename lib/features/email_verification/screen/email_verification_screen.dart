import 'package:afriqueen/common/localization/enums/enums.dart';
import 'package:afriqueen/common/widgets/snackbar_message.dart';
import 'package:afriqueen/features/email_verification/bloc/email_verification_bloc.dart';
import 'package:afriqueen/features/email_verification/bloc/email_verification_state.dart';
import 'package:afriqueen/features/email_verification/repository/email_verification_repository.dart';
import 'package:afriqueen/features/email_verification/widget/email_verification_widget.dart';
import 'package:afriqueen/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class EmailVerificationScreen extends StatelessWidget {
  const EmailVerificationScreen({super.key});

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false),
      body: SafeArea(
        child: RepositoryProvider(
          create: (context) => EmailVerificationRepository(),
          child: BlocProvider(
            create: (context) => EmailVerificationBloc(
              repository: context.read<EmailVerificationRepository>(),
            ),
            child: BlocListener<EmailVerificationBloc, EmailVerificationState>(
              listener: _listener,
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    spacing: 5.h,
                    children: [
                      //--------------- Title part----------------------
                      const EmailVerificationTitle(),
                      //-------------------Body text part------------------------
                      const EmailVerificationBody(),
                      //-----------------------Logo part---------------------------------------
                      const EmailVerificationImage(),
                      SizedBox(height: 50.h),
                      //-----------------------Email verification Button--------------------------------
                      EmailVerificationButton(),

                      //----------------------------- To  navigate to another page-------------------
                      SizedBox(height: 10.h),
                      //------------------------------- Delete Text ---------------------------------------
                      const EmailVerificationDeleteAccount(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _listener(context, state) {
    if (state is EmailVerifiedError) {
      Get.back();
      snackBarMessage(context, state.error, Theme.of(context));
    }

    if (state is AccountDelete) {
      Get.back();
      snackBarMessage(
        context,
        EnumLocale.deleteSuccessful.name.tr,
        Theme.of(context),
      );

      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.signup,
        (Route<dynamic> route) => false,
      );
    }
  }
}
