//----------------AppBar Title-----------------------
import 'package:afriqueen/common/constant/constant_colors.dart';
import 'package:afriqueen/common/constant/constant_strings.dart';
import 'package:afriqueen/common/localization/enums/enums.dart';
import 'package:afriqueen/common/widgets/divider.dart';
import 'package:afriqueen/common/widgets/loading.dart';
import 'package:afriqueen/routes/app_routes.dart';
import 'package:afriqueen/services/storage/get_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';


class FavoritesListTile extends StatelessWidget {
  const FavoritesListTile({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: ()=> Get.toNamed(AppRoutes.favorite),
      trailing: SizedBox(
          width: 50.w,
          child: Icon(
            CupertinoIcons.forward,
          )),
      leading: Icon(HugeIcons.strokeRoundedFavouriteSquare),
      title: SizedBox(
        width: 50.w,
        child: Text(
          EnumLocale.favorites.name.tr,
          style: Theme.of(context).textTheme.bodyMedium,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

//-------------------Archive user-----------------------
class ArchiveListTile extends StatelessWidget {
  const ArchiveListTile({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: ()=> Get.toNamed(AppRoutes.archive),
      trailing: SizedBox(width: 50.w, child: Icon(CupertinoIcons.forward)),
      leading: Icon(HugeIcons.strokeRoundedArchive),
      title: Text(
        EnumLocale.archive.name.tr,
        style: Theme.of(context).textTheme.bodyMedium,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

//-------------------Blocked user-----------------------
class BlockedListTile extends StatelessWidget {
  const BlockedListTile({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {},
      trailing: SizedBox(width: 50.w, child: Icon(CupertinoIcons.forward)),
      leading: Icon(HugeIcons.strokeRoundedBlocked),
      title: Text(
        EnumLocale.blocked.name.tr,
        style: Theme.of(context).textTheme.bodyMedium,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
//-----------App Bar--------------------------
class SettingAppBar extends StatelessWidget {
  const SettingAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      leading: IconButton(
        onPressed: () => Get.back(),
        icon: Icon(HugeIcons.strokeRoundedMultiplicationSign),
      ),

      title: SettingTitle(),
      centerTitle: true,
    );
  }
}
//----------------Title Text------------------------
class SettingTitle extends StatelessWidget {
  const SettingTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      EnumLocale.settings.name.tr,
      style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontSize: 18.sp),
      overflow: TextOverflow.ellipsis,
    );
  }
}

//-----------------Change Language--------------------
class LanguageListTile extends StatelessWidget {
  LanguageListTile({super.key});
  final app = AppGetStorage();
  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => showModalBottomSheet(
        context: context,
        backgroundColor: AppColors.floralWhite,
        isScrollControlled: false,
        builder: (context) => Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          spacing: 20.h,
          children: [
            ListTile(
              title: Text(
                EnumLocale.chooseOption.name.tr,
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: AppColors.primaryColor,
                  fontSize: 19.sp,
                ),
              ),
              trailing: SizedBox(
                width: 50.w,
                child: IconButton(
                  onPressed: () => Get.back(),
                  icon: Icon(
                    HugeIcons.strokeRoundedMultiplicationSignCircle,
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
            ),
    
            SizedBox(
              height: 100.h,
              child: ListView.builder(
                itemCount: AppStrings.language.length,
    
                itemBuilder: (context, index) => Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 5.h,
                  children: [
                    SizedBox(height: 15.h),
                    InkWell(
                      onTap: () async {
                        if (index == 0) {
                          await Get.updateLocale(Locale('en'));
                          app.setLanguageCode('en');
                        } else {
                          await Get.updateLocale(Locale('fr'));
                          app.setLanguageCode('fr');
                        }
                        Navigator.pop(context);
                      },
                      child: SizedBox(
                        width: double.maxFinite,
                        child: Center(
                          child: Text(
                            AppStrings.language[index],
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ),
                    ),
                    CustomDivider(),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10.h),
          ],
        ),
      ),
      trailing: SizedBox(width: 50.w, child: Icon(CupertinoIcons.forward)),
      leading: Icon(HugeIcons.strokeRoundedLanguageSquare),
      title: Text(
        EnumLocale.changeLanguage.name.tr,
        style: Theme.of(context).textTheme.bodyMedium,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

//-------------------Help center-----------------------
class HelpListTile extends StatelessWidget {
  const HelpListTile({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {},
      trailing: SizedBox(width: 50.w, child: Icon(CupertinoIcons.forward)),
      leading: Icon(HugeIcons.strokeRoundedHelpSquare),
      title: Text(
        EnumLocale.helpCenter.name.tr,
        style: Theme.of(context).textTheme.bodyMedium,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

//------------------Privacy Settings------------------------------
class PrivacyListTile extends StatelessWidget {
  const PrivacyListTile({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {},
      trailing: SizedBox(width: 50.w, child: Icon(CupertinoIcons.forward)),
      leading: Icon(HugeIcons.strokeRoundedLocked),
      title: Text(
        EnumLocale.privacySettings.name.tr,
        style: Theme.of(context).textTheme.bodyMedium,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

//----------------------Notification ----------------------------
class NotificationListTile extends StatelessWidget {
  const NotificationListTile({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {},
      trailing: SizedBox(width: 50.w, child: Icon(CupertinoIcons.forward)),
      leading: Icon(HugeIcons.strokeRoundedNotification01),
      title: Text(
        EnumLocale.notifications.name.tr,
        style: Theme.of(context).textTheme.bodyMedium,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

//---------------------Logout-------------------------
class LogoutListTile extends StatelessWidget {
  const LogoutListTile({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(HugeIcons.strokeRoundedLogoutSquare02),
      title: Text(
        EnumLocale.logout.name.tr,
        style: Theme.of(context).textTheme.bodyMedium,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: () async {
        final BuildContext currentContext = context;
        await FirebaseAuth.instance.signOut();
    
        if (!currentContext.mounted) return;
        customLoading(context);
        await Future.delayed(Duration(milliseconds: 1500));
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.login,
          (Route<dynamic> route) => false,
        );
      },
      trailing: SizedBox(width: 50.w, child: Icon(CupertinoIcons.forward)),
    );
  }
}
