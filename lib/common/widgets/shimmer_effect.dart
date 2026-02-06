import 'package:afriqueen/common/constant/constant_colors.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

//-------------Shimmer effect for all screen----------------------------
class ShimmerScreen extends StatelessWidget {
  const ShimmerScreen({super.key, required this.child, this.enabled = true});
  final Widget child;
  final bool enabled;
  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
        containersColor: AppColors.grey.withValues(alpha: 0.15),
        effect: ShimmerEffect(baseColor: AppColors.floralWhite),
        enableSwitchAnimation: true,
        enabled: enabled,
        child: child);
  }
}
