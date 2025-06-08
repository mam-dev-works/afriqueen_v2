//-------------------Image and status------------------------------
import 'package:afriqueen/common/constant/constant_colors.dart';
import 'package:afriqueen/common/widgets/seniority.dart';
import 'package:afriqueen/common/widgets/user_status.dart';
import 'package:afriqueen/features/home/model/home_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:line_icons/line_icons.dart';

//-----------Image and Status---------------------------
class ImageAndStatus extends StatelessWidget {
  const ImageAndStatus({
    super.key,
    required this.user,
  });
  final HomeModel user;

  @override
  Widget build(BuildContext context) {
    final validUrl = user.imgURL.isNotEmpty &&
        Uri.tryParse(user.imgURL)!.hasAbsolutePath == true;
    return Stack(
      children: [
        Container(
          width: double.maxFinite,
          height: 260.h,
          decoration: validUrl
              ? BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12.r),
                    topRight: Radius.circular(12.r),
                  ),
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: CachedNetworkImageProvider(user.imgURL),
                  ),
                )
              : null,
        ),
        Positioned(
          top: 8.r,
          right: 8.r,
          child: UserStatus(id: user.id),
        ),
        Positioned(bottom: 1, child: CreatedDate(user: user))
      ],
    );
  }
}

//-----------Seniority------------------------------
class CreatedDate extends StatelessWidget {
  const CreatedDate({super.key, required this.user});
  final HomeModel user;

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(8.r),
        decoration: BoxDecoration(
            color: AppColors.blue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12.r)),
        child: Text(Seniority.formatJoinedTime(user.createdDate),
            style: Theme.of(context).textTheme.bodyMedium));
  }
}

//----------------fav , following, archive----------------
class ListOfButtons extends StatelessWidget {
  const ListOfButtons({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: AppColors.blue.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12.r)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.thumb_up_alt_outlined,
              color: AppColors.black,
              size: 20.r,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(
              CupertinoIcons.chat_bubble,
              color: AppColors.black,
              size: 20.r,
            ),
          ),
          IconButton(
            onPressed: () async {},
            icon: Icon(Icons.favorite_border_outlined,
                size: 20.r, color: AppColors.black),
          ),
          IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.person_add_outlined,
                color: AppColors.black,
                size: 20.r,
              )),
          IconButton(
            onPressed: () {},
            icon: Icon(
              LineIcons.archive,
              color: AppColors.black,
              size: 20.r,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------pesudo, age and City--------------------------
class UserDetails extends StatelessWidget {
  const UserDetails({super.key, required this.user});

  final HomeModel user;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Text(
          user.pseudo,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge!.copyWith(color: AppColors.primaryColor),
        ),
        Text(
          "${user.age}",
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        Text(
          user.city,
          style: Theme.of(context).textTheme.bodyMedium,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

//-----------------------Interest grid------------------------
class Interests extends StatelessWidget {
  const Interests({super.key, required this.user});

  final HomeModel user;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 72.h,
      child: GridView.builder(
        padding: EdgeInsets.symmetric(horizontal: 5.w),
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: user.interests.length,
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
                user.interests[index],
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium!.copyWith(fontSize: 14.sp),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          );
        },
      ),
    );
  }
}

//---------------User description-------------------------
class Description extends StatelessWidget {
  const Description({super.key, required this.user});

  final HomeModel user;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 5.w,
      ),
      child: Container(
        padding: EdgeInsets.all(8.r),
        decoration: BoxDecoration(
            color: AppColors.blue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12.r)),
        child: Text(
          user.description,
          style: Theme.of(context).textTheme.bodyMedium,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ),
    );
  }
}
