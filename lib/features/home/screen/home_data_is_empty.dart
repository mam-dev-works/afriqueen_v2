import 'package:afriqueen/common/localization/enums/enums.dart';
import 'package:afriqueen/features/favorite/widgets/favorite_widgets.dart';
import 'package:afriqueen/features/home/widget/home_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_utils/get_utils.dart';

//------------------Empty Data widget---------------------

class NoData extends StatefulWidget {
  const NoData({
    super.key,
  });

  @override
  State<NoData> createState() => _NoDataState();
}

class _NoDataState extends State<NoData> {
  int selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(55.h),
        child: HomeAppBar(selectedTabIndex: selectedTabIndex),
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
