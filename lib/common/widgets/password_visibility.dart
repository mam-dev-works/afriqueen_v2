import 'package:afriqueen/common/constant/constant_colors.dart';
import 'package:flutter/material.dart';

//------------------------------------Password visibility(Toggle)-------------------------
class PasswordVisibility extends StatelessWidget {
  const PasswordVisibility({
    super.key,
    required this.isHidden,
    required this.onPressed,
  });
  final bool isHidden;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(
        isHidden ? Icons.visibility_off_outlined : Icons.visibility_outlined,
        color: AppColors.grey, // Added color for better visibility
      ),
    );
  }
}
