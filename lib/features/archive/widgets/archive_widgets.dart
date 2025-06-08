import 'package:afriqueen/common/localization/enums/enums.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';

//-----------------------Archive AppBar--------------
class ArchiveScreenAppBar extends StatelessWidget {
  const ArchiveScreenAppBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      scrolledUnderElevation: 0.0,
      leading: IconButton(
        onPressed: () => Get.back(),
        icon: Icon(HugeIcons.strokeRoundedMultiplicationSign),
      ),
      title: Text(
        EnumLocale.archive.name.tr,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      elevation: 0,
      shadowColor: Colors.transparent,
    );
  }
}
