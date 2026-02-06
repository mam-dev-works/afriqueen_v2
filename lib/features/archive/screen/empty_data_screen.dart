import 'package:afriqueen/common/localization/enums/enums.dart';
import 'package:afriqueen/features/archive/widgets/archive_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_utils/get_utils.dart';

//------------------Empty Data widget---------------------

class NoData extends StatelessWidget {
  const NoData({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(55.h),
        child: ArchiveScreenAppBar(),
      ),
      body: Center(
        child: Text(
          EnumLocale.noDataAvailable.name.tr,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}
