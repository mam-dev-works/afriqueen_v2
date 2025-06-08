// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:afriqueen/common/constant/constant_colors.dart';
import 'package:afriqueen/common/localization/enums/enums.dart';
import 'package:afriqueen/common/widgets/common_button.dart';
import 'package:afriqueen/common/widgets/snackbar_message.dart';
import 'package:afriqueen/common/widgets/user_status.dart';
import 'package:afriqueen/features/archive/bloc/archive_bloc.dart';
import 'package:afriqueen/features/archive/bloc/archive_event.dart';
import 'package:afriqueen/features/favorite/bloc/favorite_bloc.dart';
import 'package:afriqueen/features/favorite/bloc/favorite_event.dart';
import 'package:afriqueen/features/home/model/home_model.dart';
import 'package:afriqueen/features/user_details/screen/user_details_screen.dart';
import 'package:afriqueen/routes/app_routes.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:line_icons/line_icons.dart';

//-------------------Image and status------------------------------
class StackWidget extends StatelessWidget {
  const StackWidget({
    super.key,
    required this.hasValidUrl,
    required this.widget,
  });

  final bool hasValidUrl;
  final UserDetailsScreen widget;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.maxFinite,
          height: 280.h,
          decoration: hasValidUrl
              ? BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12.r),
                    topRight: Radius.circular(12.r),
                  ),
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: CachedNetworkImageProvider(widget.data.imgURL),
                  ),
                )
              : null,
        ),
        Positioned(
          top: 8.r,
          right: 8.r,
          child: UserStatus(id: widget.data.id),
        ),
      ],
    );
  }
}

//-----------Seniority------------------------------
class CreatedDate extends StatelessWidget {
  const CreatedDate({super.key, required this.date});

  final String date;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 20.w),
      child: Container(
          padding: EdgeInsets.all(8.r),
          decoration: BoxDecoration(
              color: AppColors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r)),
          child: Text(date, style: Theme.of(context).textTheme.bodyMedium)),
    );
  }
}

//---------------User description-------------------------
class Description extends StatelessWidget {
  const Description({super.key, required this.widget});

  final UserDetailsScreen widget;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 5.h),
      child: Container(
        padding: EdgeInsets.all(8.r),
        decoration: BoxDecoration(
            color: AppColors.blue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12.r)),
        child: Text(
          widget.data.description,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}

//-----------------------Interest grid------------------------
class Interests extends StatelessWidget {
  const Interests({super.key, required this.widget});

  final UserDetailsScreen widget;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.symmetric(horizontal: 5.w),
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: widget.data.interests.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8.h,
        crossAxisSpacing: 8.w,
        childAspectRatio: 3,
      ),
      itemBuilder: (BuildContext context, index) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 2.w),
          height: 20.h,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryColor.withAlpha(10),
                blurRadius: 2.r,
                spreadRadius: 2.r,
                offset: Offset(0.4.w, 0.4.h),
                blurStyle: BlurStyle.solid,
              ),
            ],
            color: AppColors.transparent,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: AppColors.primaryColor, width: 1.w),
          ),
          child: Center(
            child: Text(
              widget.data.interests[index],
              style: Theme.of(
                context,
              ).textTheme.bodyMedium!.copyWith(fontSize: 14.sp),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        );
      },
    );
  }
}

// ---------pesudo, age and City--------------------------
class UserDetails extends StatelessWidget {
  const UserDetails({super.key, required this.widget});

  final UserDetailsScreen widget;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Text(
          widget.data.pseudo,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge!.copyWith(color: AppColors.primaryColor),
        ),
        Text(
          "${widget.data.age}",
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        Text(
          widget.data.city,
          style: Theme.of(context).textTheme.bodyMedium,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

//----------------Like, Chat, Favorites, Achieve----------------
class ButtonList extends StatelessWidget {
  const ButtonList({super.key, required this.model});
  final HomeModel model;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.r),
      decoration: BoxDecoration(
          color: AppColors.blue.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12.r)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.thumb_up_alt_outlined,
                  color: AppColors.black,
                  size: 30,
                ),
              ),
              Text(
                EnumLocale.like.name.tr,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall!
                    .copyWith(color: AppColors.black),
              )
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () {},
                icon: Icon(
                  CupertinoIcons.chat_bubble,
                  color: AppColors.black,
                  size: 30,
                ),
              ),
              Text(
                EnumLocale.message.name.tr,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall!
                    .copyWith(color: AppColors.black),
              )
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () async {
                  context
                      .read<FavoriteBloc>()
                      .add(FavoriteUserAdded(favId: model.id));
                  snackBarMessage(context, EnumLocale.savedToFavorites.name.tr,
                      Theme.of(context));
                  await Future.delayed(Duration(milliseconds: 500));
                  Get.toNamed(AppRoutes.main);
                },
                icon: Icon(Icons.favorite_border_outlined,
                    size: 30, color: AppColors.black),
              ),
              Text(
                EnumLocale.Favorite.name.tr,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall!
                    .copyWith(color: AppColors.black),
              )
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () async {
                  context
                      .read<ArchiveBloc>()
                      .add(ArchiveUserAdded(archiveId: model.id));
                  snackBarMessage(context, EnumLocale.savedToArchives.name.tr,
                      Theme.of(context));
                  await Future.delayed(Duration(milliseconds: 500));
                  Get.toNamed(AppRoutes.main);
                },
                icon: Icon(
                  LineIcons.archive,
                  color: AppColors.black,
                  size: 30,
                ),
              ),
              Text(
                EnumLocale.archive.name.tr,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall!
                    .copyWith(color: AppColors.black),
              )
            ],
          ),
        ],
      ),
    );
  }
}

//---------------- AppBar -----------------------
class UserDetailsAppBar extends StatelessWidget {
  const UserDetailsAppBar({
    Key? key,
    required this.isScrollingUp,
    required this.name,
  }) : super(key: key);
  final bool isScrollingUp;
  final String name;
  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      centerTitle: true,
      title: Text(
        isScrollingUp ? '' : name,
        style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontSize: 25.sp),
        overflow: TextOverflow.ellipsis,
      ),
      leading: IconButton(
        onPressed: () => Get.back(),
        icon: Icon(HugeIcons.strokeRoundedMultiplicationSign),
      ),
      actions: [
        PopupMenuButton(
          tooltip: EnumLocale.more.name.tr,
          color: AppColors.floralWhite.withValues(alpha: 0.9),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
          itemBuilder: (context) => [
            PopupMenuItem(
              child: Text(
                EnumLocale.report.name.tr,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium!.copyWith(color: AppColors.red),
              ),
            ),
            PopupMenuItem(
              onTap: () => showDialog(
                  context: context, builder: (context) => BlockAlertDialog()),
              child: Text(
                EnumLocale.block.name.tr,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

//----------- Dialog Box to ask for block----------------------------------
class BlockAlertDialog extends StatelessWidget {
  const BlockAlertDialog({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.symmetric(horizontal: 15.w),
      titlePadding: EdgeInsets.only(top: 10.h),
      title: Icon(
        Icons.block_outlined,
        color: AppColors.red,
        size: 100.r,
        shadows: [
          Shadow(
              color: AppColors.primaryColor.withValues(alpha: 1),
              blurRadius: 100.r)
        ],
      ),
      backgroundColor: AppColors.floralWhite,
      shape: RoundedRectangleBorder(
          side: BorderSide(color: AppColors.grey, width: 1),
          borderRadius: BorderRadiusGeometry.circular(8.r)),
      content: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 10.h,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 10.h,
          ),
          Text(
            EnumLocale.blockTitle.name.tr,
            style: Theme.of(context)
                .textTheme
                .bodyLarge!
                .copyWith(fontSize: 20.sp),
          ),
          SizedBox(
            height: 10.h,
          ),
          CommonButton(
              onPressed: () {}, buttonText: EnumLocale.yesBlock.name.tr),
          TextButton(
              onPressed: () => Get.back(),
              child: Text(
                EnumLocale.cancel.name.tr,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .copyWith(fontSize: 18.sp),
              ))
        ],
      ),
    );
  }
}
