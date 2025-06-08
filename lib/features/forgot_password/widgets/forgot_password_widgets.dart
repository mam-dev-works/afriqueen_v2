import 'package:afriqueen/common/constant/constant_colors.dart';
import 'package:afriqueen/common/constant/constant_strings.dart';
import 'package:afriqueen/common/localization/enums/enums.dart';
import 'package:afriqueen/common/utils/validators.dart';
import 'package:afriqueen/common/widgets/common_button.dart';
import 'package:afriqueen/common/widgets/common_textfield.dart';
import 'package:afriqueen/features/forgot_password/bloc/forgot_password_bloc.dart';
import 'package:afriqueen/features/forgot_password/bloc/forgot_password_event.dart';
import 'package:afriqueen/routes/app_routes.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

//----------------Text regarding instruction--------------------------
class BodyWidget extends StatelessWidget {
  const BodyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      EnumLocale.passwordResetInstruction.name.tr,
      style: Theme.of(context).textTheme.bodySmall,
    );
  }
}

//----------------Heading titile Forget Password ?--------------------------
class Heading extends StatelessWidget {
  const Heading({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      "${EnumLocale.forgotPassword.name.tr}?",
      style: Theme.of(context).textTheme.bodyLarge,
    );
  }
}

/// ------------------  email  For  send link-------------------
class Email extends StatefulWidget {
  const Email({super.key});

  @override
  State<Email> createState() => _UserEmailState();
}

class _UserEmailState extends State<Email> {
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

      onChanged: (value) => context.read<ForgotPasswordBloc>().add(
        UserEmail(userEmail: value.trim()),
      ),
      keyboardType: TextInputType.emailAddress,
    );
  }
}

//------------------Remember Password------------------

class RememberPassword extends StatelessWidget {
  const RememberPassword({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: RichText(
        text: TextSpan(
          text: EnumLocale.rememberPassword.name.tr,
          style: Theme.of(context).textTheme.bodySmall!.copyWith(fontSize: 14),
          children: [
            TextSpan(
              text: " ${EnumLocale.loginText.name.tr}",
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                color: AppColors.primaryColor,
                fontSize: 14,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () => Get.offAllNamed(AppRoutes.login),
            ),
          ],
        ),
      ),
    );
  }
}

/// ----------------------- Send button ----------------------
class SendButton extends StatelessWidget {
  const SendButton({super.key, required this.formKey});
  final GlobalKey<FormState> formKey;

  @override
  Widget build(BuildContext context) {
    return CommonButton(
      onPressed: () async {
        if (formKey.currentState!.validate()) {
          context.read<ForgotPasswordBloc>().add(SendButtonClicked());
          await Future.delayed(Duration(milliseconds: 500));
          Get.toNamed(AppRoutes.emailSent);
        }
      },

      buttonText: EnumLocale.sendButtonText.name.tr,
    );
  }
}

//----------------------Center logo of email----------------------
class CenterImage extends StatelessWidget {
  const CenterImage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Lottie.asset(AppStrings.email, height: 200.h, width: 300.w),
    );
  }
}

/// ----------------------- Login page button ----------------------
class SendButtonInSuccessedPage extends StatelessWidget {
  const SendButtonInSuccessedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonButton(
      onPressed: () => Get.offAllNamed(AppRoutes.login),

      buttonText: EnumLocale.loginText.name.tr,
    );
  }
}

//----------------------Center logo of email for successed page----------------------
class CenterImageInSuccessedPage extends StatelessWidget {
  const CenterImageInSuccessedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Lottie.asset(AppStrings.emailVerifed, height: 200.h, width: 300.w),
    );
  }
}

//----------------Text regarding email sent--------------------------
class BodyWidgetInSuccessedPage extends StatelessWidget {
  const BodyWidgetInSuccessedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      EnumLocale.checkEmail.name.tr,
      style: Theme.of(context).textTheme.bodySmall,
    );
  }
}

//----------------Heading titile for successed  page--------------------------
class HeadingInSuccessedPage extends StatelessWidget {
  const HeadingInSuccessedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      EnumLocale.emailSent.name.tr,
      style: Theme.of(context).textTheme.bodyLarge,
    );
  }
}

//------------------Didnot receive email------------------

class DidnotRecieveTheLink extends StatelessWidget {
  const DidnotRecieveTheLink({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: RichText(
        text: TextSpan(
          text: EnumLocale.didNotReceiveTheLink.name.tr,
          style: Theme.of(context).textTheme.bodySmall!.copyWith(fontSize: 14),
          children: [
            TextSpan(
              text: " ${EnumLocale.resend.name.tr}",
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                color: AppColors.primaryColor,
                fontSize: 14,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () =>
                    context.read<ForgotPasswordBloc>().add(SendButtonClicked()),
            ),
          ],
        ),
      ),
    );
  }
}
