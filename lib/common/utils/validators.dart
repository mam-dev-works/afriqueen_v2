import 'package:afriqueen/common/localization/enums/enums.dart';

import 'package:get/get_utils/get_utils.dart';

abstract class AppValidator {
  //--------------- email validation function--------------------
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return EnumLocale.emailRequiredText.name.tr;
    }
    // Regular expression for email validation
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return EnumLocale.invalidEmailText.name.tr;
    }
    return null;
  }

  //--------------- Password validation function--------------------
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return EnumLocale.passwordRequiredText.name.tr;
    }
    if (value.length < 5) {
      return EnumLocale.passwordLengthText.name.tr;
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return EnumLocale.passwordUppercaseRequiredText.name.tr;
    }
    if (!value.contains(RegExp(r'[a-z]'))) {
      return EnumLocale.passwordLowercaseRequiredText.name.tr;
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return EnumLocale.passwordDigitRequiredText.name.tr;
    }
    if (!value.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'))) {
      return EnumLocale.passwordSpecialCharacterRequiredText.name.tr;
    }
    return null;
  }

  //-----------------Password validator for login--------------------------
  static String? validateLoginPassword(String? value) {
    if (value == null || value.isEmpty) {
      return EnumLocale.passwordRequiredText.name.tr;
    }

    return null;
  }

  //----------------------- Validation for  pseudo--------------------
  static String? validatePseudo(String? value) {
    if (value == null || value.isEmpty) {
      return EnumLocale.pseudoRequired.name.tr;
    }

    //---------------- Length check----------------
    if (value.length < 3 || value.length > 8) {
      return EnumLocale.pseudoLengthError.name.tr;
    }

    // ---------------------Only allow letters, numbers, and underscores--------------------------
    final pseudoRegex = RegExp(r'^[a-zA-Z0-9_]+$');
    if (!pseudoRegex.hasMatch(value)) {
      return EnumLocale.pseudoOnlyContains.name.tr;
    }

    return null;
  }

  //-----------------Description validator--------------------------
  static String? validateDescription(String? value) {
    if (value == null || value.isEmpty) {
      return EnumLocale.passwordRequiredText.name.tr;
    }

    return null;
  }
}
