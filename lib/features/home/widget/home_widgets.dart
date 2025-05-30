//----------------AppBar -----------------------
import 'package:afriqueen/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';

//-------------------App Bar-------------------------------
class HomeAppBar extends StatelessWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      centerTitle: true,
      actions: [
        IconButton(
          onPressed: () {},
          icon: Icon(Icons.tune_outlined, size: 35.r),
        ),
      ],

      leading: IconButton(
        onPressed: () => Get.toNamed(AppRoutes.profile),
        icon: Icon(LineIcons.user, size: 35.r),
      ),
    );
  }
}


