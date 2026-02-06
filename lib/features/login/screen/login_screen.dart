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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: BlocListener<LoginBloc, LoginState>(
          listener: _listener,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white,
                  Colors.grey[50]!,
                ],
              ),
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Top spacing
                    SizedBox(height: 80.h),
                    
                    // App Logo with better spacing
                    const AppLogo(),
                    SizedBox(height: 40.h),
                    
                    // Welcome text with improved styling
                    Text(
                      EnumLocale.loginText.name.tr,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8.h),
                    
                    // Subtitle
                    Text(
                      EnumLocale.passwordlessLoginSubtitle.name.tr,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                        fontSize: 16.sp,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 60.h),
                    
                    // Passwordless Login Button
                    const PasswordlessLoginButton(),
                    
                    // Bottom spacing
                    SizedBox(height: 40.h),
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
