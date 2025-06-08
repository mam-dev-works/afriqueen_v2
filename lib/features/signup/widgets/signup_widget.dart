import 'package:afriqueen/common/constant/constant_colors.dart';
import 'package:afriqueen/common/constant/constant_strings.dart';
import 'package:afriqueen/common/localization/enums/enums.dart';
import 'package:afriqueen/common/utils/validators.dart';
import 'package:afriqueen/common/widgets/common_button.dart';
import 'package:afriqueen/common/widgets/common_textfield.dart';
import 'package:afriqueen/common/widgets/snackbar_message.dart';
import 'package:afriqueen/features/signup/bloc/signup_bloc.dart';
import 'package:afriqueen/features/signup/bloc/signup_event.dart';
import 'package:afriqueen/features/signup/bloc/signup_state.dart';
import 'package:afriqueen/routes/app_routes.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

/// ---------------- Signup text ----------------
class SignUpText extends StatelessWidget {
  const SignUpText({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      EnumLocale.signupText.name.tr,
      style: Theme.of(context).textTheme.bodyLarge,
    );
  }
}

/// ------------------ TextField for email -------------------
class EmailInput extends StatefulWidget {
  const EmailInput({super.key});

  @override
  State<EmailInput> createState() => _EmailInputState();
}

class _EmailInputState extends State<EmailInput> {
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
          context.read<SignupBloc>().add(EmailChanged(email: value.trim())),
      keyboardType: TextInputType.emailAddress,
    );
  }
}

/// ------------------ TextField for password -------------------
class PasswordInput extends StatefulWidget {
  const PasswordInput({super.key});

  @override
  State<PasswordInput> createState() => _PasswordInputState();
}

class _PasswordInputState extends State<PasswordInput> {
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignupBloc, SignupState>(
      builder: (context, state) {
        return CommonTextField(
          labelText: EnumLocale.passwordHint.name.tr,
          controller: _passwordController,
          validator: AppValidator.validatePassword,
          obscureText: state.isPasswordHidden,
          onChanged: (value) => context.read<SignupBloc>().add(
                PasswordChanged(password: value.trim()),
              ),
          suffixIcon: IconButton(
            onPressed: () =>
                context.read<SignupBloc>().add(PasswordVisibility()),
            icon: Icon(
              state.isPasswordHidden
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

/// ------------------- Register description and checkbox ------------------
class RegisterDescription extends StatelessWidget {
  const RegisterDescription({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BlocBuilder<SignupBloc, SignupState>(
          builder: (context, state) {
            return IconButton(
              constraints: const BoxConstraints(),
              onPressed: () => context.read<SignupBloc>().add(CheckedBox()),
              icon: Icon(
                state.isChecked
                    ? Icons.check_box_outlined
                    : Icons.check_box_outline_blank_outlined,
                color: AppColors.black.withValues(alpha: 0.6),
              ),
            );
          },
        ),
        Expanded(
          child: Text.rich(
            TextSpan(
              text: EnumLocale.registeringDescriptionText1.name.tr,
              style: Theme.of(context).textTheme.bodySmall,
              children: [
                TextSpan(
                  text: EnumLocale.registeringDescriptionText2.name.tr,
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: AppColors.primaryColor,
                      ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () => Get.toNamed(AppRoutes.conditionOfUse),
                ),
                TextSpan(
                  text: EnumLocale.registeringDescriptionText3.name.tr,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                TextSpan(
                  text: EnumLocale.registeringDescriptionText4.name.tr,
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: AppColors.primaryColor,
                      ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () => Navigator.pushNamed(
                          context,
                          AppRoutes.privacyAndPolicy,
                        ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// ----------------------- Signup button ----------------------
class SignupButton extends StatelessWidget {
  const SignupButton({super.key, required this.formKey});
  final GlobalKey<FormState> formKey;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignupBloc, SignupState>(
      builder: (context, state) {
        return CommonButton(
          onPressed: () {
            if (state.isChecked == false) {
              snackBarMessage(
                context,
                EnumLocale.acceptPolicyAndCondition.name.tr,
                Theme.of(context),
              );
            }

            if (formKey.currentState!.validate() && state.isChecked == true) {
              context.read<SignupBloc>().add(Submit());
            }
          },
          buttonText: EnumLocale.signupText.name.tr,
        );
      },
    );
  }
}

//------------------if user has already have account------------------

class AlreadyHaveAccount extends StatelessWidget {
  const AlreadyHaveAccount({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: RichText(
        text: TextSpan(
          text: EnumLocale.alreadyHaveAccount.name.tr,
          style: Theme.of(context).textTheme.bodySmall!.copyWith(fontSize: 16),
          children: [
            TextSpan(
              text: EnumLocale.loginText.name.tr,
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: AppColors.primaryColor,
                    fontSize: 16,
                  ),
              recognizer: TapGestureRecognizer()
                ..onTap = () => Get.toNamed(AppRoutes.login),
            ),
          ],
        ),
      ),
    );
  }
}

//----------------------------Button for google signup-----------------------------
class GoogleSignUpButton extends StatelessWidget {
  const GoogleSignUpButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: 40.h,
        width: 120.w,
        child: ElevatedButton(
          onPressed: () =>
              context.read<SignupBloc>().add(GoogleSignInButtonClicked()),
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
            ),
          ),
        ),
      ),
    );
  }
}

//-------------------Signup Button and Google Signin Button-----------------------------
class SignupAndGoogleSigninButton extends StatelessWidget {
  const SignupAndGoogleSigninButton({super.key, required this.formKey});
  final GlobalKey<FormState> formKey;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 20,
      children: [
        SignupButton(formKey: formKey),
        GoogleSignUpButton(),
      ],
    );
  }
}
