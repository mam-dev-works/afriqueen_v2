import 'package:afriqueen/common/constant/constant_colors.dart';
import 'package:afriqueen/common/constant/constant_strings.dart';
import 'package:afriqueen/common/localization/enums/enums.dart';
import 'package:afriqueen/common/utils/validators.dart';
import 'package:afriqueen/common/widgets/common_textfield.dart';
import 'package:afriqueen/features/login/bloc/login_bloc.dart';
import 'package:afriqueen/features/login/bloc/login_event.dart';
import 'package:afriqueen/features/login/bloc/login_state.dart';
import 'package:afriqueen/routes/app_routes.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

/// ---------------- Signup text ----------------
class LoginText extends StatelessWidget {
  const LoginText({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      EnumLocale.loginText.name.tr,
      style: Theme.of(context).textTheme.bodyLarge,
    );
  }
}

/// ------------------ TextField for email -------------------
class LoginEmailInput extends StatefulWidget {
  const LoginEmailInput({super.key});

  @override
  State<LoginEmailInput> createState() => _LoginEmailInputState();
}

class _LoginEmailInputState extends State<LoginEmailInput> {
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CommonTextField(
      labelText: EnumLocale.emailHint.name.tr,
      controller: _emailController,
      validator: AppValidator.validateEmail,
      obscureText: false,

      onChanged: (value) =>
          context.read<LoginBloc>().add(LoginEmailChanged(email: value.trim())),
      keyboardType: TextInputType.emailAddress,
    );
  }
}

/// ------------------ TextField for password -------------------
class LoginPasswordInput extends StatefulWidget {
  const LoginPasswordInput({super.key});

  @override
  State<LoginPasswordInput> createState() => _LoginPasswordInputState();
}

class _LoginPasswordInputState extends State<LoginPasswordInput> {
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginBloc, LoginState>(
      builder: (context, state) {
        return CommonTextField(
          labelText: EnumLocale.passwordHint.name.tr,
          controller: _passwordController,
          validator: AppValidator.validateLoginPassword,
          obscureText: state.isLoginPasswordVisible,
          onChanged: (value) => context.read<LoginBloc>().add(
            LoginPasswordChanged(password: value.trim()),
          ),
          suffixIcon: IconButton(
            onPressed: () =>
                context.read<LoginBloc>().add(LoginPasswordVisibility()),
            icon: Icon(
              state.isLoginPasswordVisible
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: Colors.grey,
            ),
          ),
        );
      },
    );
  }
}

/// ----------------------- Login button ----------------------
class LoginButton extends StatelessWidget {
  const LoginButton({super.key, required this.formKey});
  final GlobalKey<FormState> formKey;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: 40.h, // Slightly increased height for better touch target
        width: 120.w,
        child: ElevatedButton(
          // Using ElevatedButton for better default styling
          onPressed: () {
            if (formKey.currentState!.validate()) {
              context.read<LoginBloc>().add(LoginSubmit());
            }
          },
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
              padding: EdgeInsets.all(3.r),
              alignment: Alignment.center,
              child: Text(
                EnumLocale.loginText.name.tr,
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

//------------------if user doesnot have account------------------

class DonotHaveAccount extends StatelessWidget {
  const DonotHaveAccount({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: RichText(
        text: TextSpan(
          text: EnumLocale.doNotHaveAccount.name.tr,
          style: Theme.of(context).textTheme.bodySmall!.copyWith(fontSize: 16),
          children: [
            TextSpan(
              text: EnumLocale.signupText.name.tr,
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                color: AppColors.primaryColor,
                fontSize: 16,
              ),

              recognizer: TapGestureRecognizer()
                ..onTap = () => Get.toNamed(AppRoutes.signup),
            ),
          ],
        ),
      ),
    );
  }
}

//----------------------------Button for google login-----------------------------

class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: 40.h, // Slightly increased height for better touch target
        width: 120.w,
        child: ElevatedButton(
          // Using ElevatedButton for better default styling
          onPressed: () =>
              context.read<LoginBloc>().add(GoogleSignInButtonClicked()),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
          child: Ink(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Container(
              padding: EdgeInsets.all(6.r),
              alignment: Alignment.center,
              child: SvgPicture.asset(AppStrings.googleLogo),

              // Show indicator if loading and it's the login button
            ),
          ),
        ),
      ),
    );
  }
}

//-------------------Login Button and Google Signin Button-----------------------------
class LoginAndGoogleSigninButton extends StatelessWidget {
  const LoginAndGoogleSigninButton({super.key, required this.formKey});
  final GlobalKey<FormState> formKey;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 20,

      children: [
        LoginButton(formKey: formKey),
        GoogleSignInButton(),
      ],
    );
  }
}

//------------------Forgot password-----------------------
class ForgotPassword extends StatelessWidget {
  const ForgotPassword({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: InkWell(
        onTap: () => Get.toNamed(AppRoutes.forgotPassword),
        child: Text(
          EnumLocale.forgotPassword.name.tr,

          style: Theme.of(
            context,
          ).textTheme.bodySmall!.copyWith(color: AppColors.primaryColor),
        ),
      ),
    );
  }
}
