import 'package:afriqueen/common/constant/constant_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

//-----------------------TextField for user Input-----------------
class CommonTextField extends StatelessWidget {
  const CommonTextField({
    super.key,
    required this.labelText,
    required this.controller,
    required this.validator,
    this.suffixIcon = const SizedBox(height: 0, width: 0),
    required this.obscureText,
    required this.onChanged,
    this.keyboardType = TextInputType.text,
  });
  final String labelText;
  final TextEditingController controller;
  final FormFieldValidator<String>? validator; // added this
  final Widget suffixIcon;
  final bool obscureText;
  final void Function(String)? onChanged;
  final TextInputType? keyboardType;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      keyboardType: keyboardType,
      onChanged: onChanged,
      cursorColor: AppColors.black,
      style: TextStyle(fontSize: 16),
      validator: validator,
      controller: controller,
      obscureText: obscureText,
      obscuringCharacter: '•',
      textAlignVertical: TextAlignVertical.center,
      enableInteractiveSelection: true,
      decoration: InputDecoration(
        suffixIcon: suffixIcon,
        errorMaxLines: 3,
        labelText: labelText,
        labelStyle: Theme.of(context).textTheme.bodySmall,
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(width: 2.w, color: AppColors.red),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(width: 1.w, color: AppColors.black),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(width: 1.w, color: AppColors.blue),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(width: 2.w, color: AppColors.red),
        ),
        border: InputBorder.none,
      ),
    );
  }
}
