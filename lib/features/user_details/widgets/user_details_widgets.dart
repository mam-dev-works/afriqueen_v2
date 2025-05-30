// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:afriqueen/common/widgets/user_status.dart';
import 'package:afriqueen/features/home/model/home_model.dart';
import 'package:afriqueen/features/user_details/screen/user_details_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:line_icons/line_icons.dart';
import 'package:afriqueen/common/constant/constant_colors.dart';
import 'package:afriqueen/common/localization/enums/enums.dart';

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
          height: 200.h,
          decoration:
              hasValidUrl
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
        Positioned(top: 8.r, right: 8.r, child: UserStatus(id: widget.data.id)),
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
      padding: EdgeInsets.only(left: 12.w),
      child: Text(date, style: Theme.of(context).textTheme.bodyMedium),
    );
  }
}

//---------------User discription-------------------------
class Discription extends StatelessWidget {
  const Discription({super.key, required this.widget});

  final UserDetailsScreen widget;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5.w),
      child: Text(
        widget.data.discription,
        style: Theme.of(context).textTheme.bodyMedium,
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
  const ButtonList({super.key, required this.mode});
  final HomeModel mode;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        IconButton(
          onPressed: () {},
          icon: Icon(Icons.thumb_up_alt_outlined, color: AppColors.grey),
        ),
        IconButton(
          onPressed: () {},
          icon: Icon(CupertinoIcons.chat_bubble, color: AppColors.grey),
        ),
        IconButton(
          onPressed: () {},
          icon: Icon(Icons.favorite_border_outlined, color: AppColors.grey),
        ),
        IconButton(
          onPressed: () {},
          icon: Icon(LineIcons.archive, color: AppColors.grey),
        ),
      ],
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
          itemBuilder:
              (context) => [
                PopupMenuItem(
                  child: Text(
                    EnumLocale.report.name.tr,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium!.copyWith(color: AppColors.red),
                  ),
                ),
                PopupMenuItem(
                  child: Text(
                    EnumLocale.block.name.tr,
                    style: Theme.of(context).textTheme.bodyMedium!,
                  ),
                ),
              ],
        ),
      ],
    );
  }
}
