import 'package:afriqueen/common/localization/enums/enums.dart';
import 'package:afriqueen/common/widgets/app_logo.dart';
import 'package:afriqueen/common/widgets/loading.dart';
import 'package:afriqueen/common/widgets/snackbar_message.dart';
import 'package:afriqueen/features/login/bloc/login_bloc.dart';
import 'package:afriqueen/features/login/bloc/login_state.dart';
import 'package:afriqueen/features/login/widgets/login_widgets.dart';
import 'package:afriqueen/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocListener<LoginBloc, LoginState>(
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
                  spacing: 5.h,
                  children: [
                    // app logo image
                    SizedBox(height: 50.h),
                    //----- afriqueen logo------------
                    const AppLogo(),
                    SizedBox(height: 20.h),
                    //----------------text---------------
                    const LoginText(),
                    SizedBox(height: 10.h),
                    //--------------TextField For Email---------------
                    const LoginEmailInput(),
                    SizedBox(height: 10.h),
                    //--------------TextField For Password---------------
                    const LoginPasswordInput(),

                    //----------------Forget Password--------------------
                    const ForgotPassword(),
                    SizedBox(height: 45.h),
                    //--------------------------Signup button and Login with Email Both Inside This ---------------------
                    LoginAndGoogleSigninButton(formKey: _formKey),
                    //------------------if user has already have account------------------
                    SizedBox(height: 3.h),
                    const DonotHaveAccount(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _listener(context, state) {
    if (state is LoginLoading) {
      customLoading(context);
      debugPrint("Loading>>>>>>>>>>>>");
    }

    if (state is LoginSuccess) {
      Get.back();
      debugPrint("Successs");
      snackBarMessage(
        context,
        EnumLocale.loginSuccessful.name.tr,
        Theme.of(context),
      );
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.main,
        (Route<dynamic> route) => false,
      );
    }
    if (state is LoginError) {
      Get.back();
      debugPrint("Error : ${state.error}");
      snackBarMessage(context, state.error, Theme.of(context));
    }

    if (state is GoogleLoginNewUser) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.name,
        (Route<dynamic> route) => false,
      );
      Get.back();
    }

    if (state is GoogleLoginOldUser) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.main,
        (Route<dynamic> route) => false,
      );
      Get.back();
    }

    if (state is GoogleLoginError) {
      Get.back();
      debugPrint("Error : ${state.error}");
      snackBarMessage(context, state.error, Theme.of(context));
    }
  }
}
