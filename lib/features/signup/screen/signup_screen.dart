import 'package:afriqueen/common/localization/enums/enums.dart';
import 'package:afriqueen/common/widgets/app_logo.dart';
import 'package:afriqueen/common/widgets/loading.dart';
import 'package:afriqueen/common/widgets/snackbar_message.dart';

import 'package:afriqueen/features/signup/bloc/signup_bloc.dart';
import 'package:afriqueen/features/signup/bloc/signup_state.dart';
import 'package:afriqueen/features/signup/repository/signup_repository.dart';
import 'package:afriqueen/features/signup/widgets/signup_widget.dart';
import 'package:afriqueen/routes/app_routes.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class SignupScreen extends StatelessWidget {
  SignupScreen({super.key});

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RepositoryProvider(
          lazy: true,
          create: (context) => SignupRepository(),
          child: BlocProvider(
            create:
                (context) => SignupBloc(
                  signupRepository: context.read<SignupRepository>(),
                ),
            child: BlocListener<SignupBloc, SignupState>(
              listener: _listener,
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                  ).copyWith(top: 20.h),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 15.h,
                      children: [
                        // app logo image
                        SizedBox(height: 50.h),
                        //----- afriqueen logo------------
                        const AppLogo(),
                        SizedBox(height: 10.h),
                        //----------------text---------------
                        const SignUpText(),

                        //--------------TextField For Email---------------
                        const EmailInput(),
                        //--------------TextField For Password---------------
                        const PasswordInput(),
                        //----------------Checked and  Register discription------------------------
                        const RegisterDiscription(),
                        //--------------------------Signup button---------------------
                        SizedBox(height: 20.h),
                        SignupButton(formKey: _formKey),
                        //------------------if user has already have account------------------
                        const AlreadyHaveAccount(),
                      ],
                    ),
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
    if (state is Loading) {
      customLoading(context);
      debugPrint("Loading>>>>>>>>>>>>");
    }

    if (state is Success) {
      debugPrint("Successs");
      Get.back();
      snackBarMessage(
        context,
        EnumLocale.signupSuccessful.name.tr,
        Theme.of(context),
      );
      Get.offAllNamed(AppRoutes.emailVerification);
    }

    if (state is SignUpfail) {
      snackBarMessage(context, state.error.tr, Theme.of(context));
      Get.back();
    }
  }
}
