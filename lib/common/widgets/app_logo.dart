import 'package:afriqueen/common/constant/constant_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

//----------------------- Afriqueen logo-------------------
class AppLogo extends StatefulWidget {
  const AppLogo({super.key});

  @override
  State<AppLogo> createState() => _AppLogoState();
}

class _AppLogoState extends State<AppLogo> {
  final logoImage = AssetImage(AppStrings.logoImage);
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      precacheImage(logoImage, context);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Image(
      width: double.maxFinite.h,
      fit: BoxFit.fitWidth,
      image: logoImage,
    );
  }
}
