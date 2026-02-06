import 'package:afriqueen/common/constant/constant_colors.dart';
import 'package:afriqueen/common/localization/enums/enums.dart';
import 'package:afriqueen/features/blocked/widgets/blocked_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';

import '../bloc/blocked_bloc.dart';
import '../bloc/blocked_event.dart';

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(55.h),
        child: BlockedScreenAppBar(),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80.sp,
              color: Colors.red,
            ),
            SizedBox(height: 20.h),
            Text(
              EnumLocale.defaultError.name.tr,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.red,
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              EnumLocale.defaultError.name.tr,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20.h),
            ElevatedButton(
              onPressed: () {
                context.read<BlockedBloc>().add(BlockedUsersFetched());
              },
              child: Text(EnumLocale.retry.name.tr),
            ),
          ],
        ),
      ),
    );
  }
} 