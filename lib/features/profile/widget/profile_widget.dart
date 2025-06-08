import 'package:afriqueen/common/constant/constant_colors.dart';
import 'package:afriqueen/common/widgets/seniority.dart';
import 'package:afriqueen/common/widgets/user_status.dart';
import 'package:afriqueen/features/profile/bloc/profile_bloc.dart';
import 'package:afriqueen/features/profile/bloc/profile_state.dart';
import 'package:afriqueen/features/profile/model/profile_model.dart';
import 'package:afriqueen/routes/app_routes.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';

//----------------AppBar -----------------------
class ProfileAppBar extends StatelessWidget {
  const ProfileAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      centerTitle: true,
      actions: [
        IconButton(
          onPressed: () => Get.toNamed(AppRoutes.setting),
          icon: Icon(HugeIcons.strokeRoundedSettings01),
        ),
      ],
      title: AppBarTitle(),
      leading: IconButton(
        onPressed: () => Get.back(),
        icon: Icon(HugeIcons.strokeRoundedMultiplicationSign),
      ),
    );
  }
}

//----------------AppBar Title-----------------------
class AppBarTitle extends StatelessWidget {
  const AppBarTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<ProfileBloc, ProfileState, String>(
      selector: (state) => state.data.pseudo,
      builder: (context, data) {
        return Text(
          data,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge!.copyWith(fontSize: 25.sp),
          overflow: TextOverflow.ellipsis,
        );
      },
    );
  }
}

//----------Description-----------------------
class DescriptionText extends StatelessWidget {
  const DescriptionText({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<ProfileBloc, ProfileState, String>(
      selector: (state) => state.data.description,
      builder: (context, data) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.w),
          child: Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                  color: AppColors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r)),
              child: Text(data, style: Theme.of(context).textTheme.bodyMedium)),
        );
      },
    );
  }
}

//----------------User Interests ----------------------------
class UserInterestsList extends StatelessWidget {
  const UserInterestsList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<ProfileBloc, ProfileState, List>(
      selector: (state) => state.data.interests,
      builder: (context, data) {
        return GridView.builder(
          padding: EdgeInsets.symmetric(horizontal: 5.w),
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: data.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 8.h,
            crossAxisSpacing: 8.w,
            childAspectRatio: 3,
          ),
          itemBuilder: (BuildContext context, index) {
            final items =  data[index];
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
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: AppColors.primaryColor, width: 1.w),
              ),
              child: Center(
                child: Text(
                  items,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium!.copyWith(fontSize: 14.sp),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            );
          },
        );
      },
    );
  }
}

//------------------User account age -----------------------------
class UserSeniority extends StatelessWidget {
  const UserSeniority({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<ProfileBloc, ProfileState, DateTime>(
      selector: (state) => state.data.createdDate,
      builder: (context, data) {
        final date = Seniority.formatJoinedTime(data);
        return Padding(
          padding: EdgeInsets.only(left: 20.w),
          child: Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                  color: AppColors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r)),
              child: Text(date, style: Theme.of(context).textTheme.bodyMedium)),
        );
      },
    );
  }
}

//------------------------------------- user name , age nad city----------------------------
class UserDetails extends StatelessWidget {
  const UserDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<ProfileBloc, ProfileState, ProfileModel>(
      selector: (state) => state.data,
      builder: (context, data) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(
              data.pseudo,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge!.copyWith(color: AppColors.primaryColor),
            ),
            Text("${data.age}", style: Theme.of(context).textTheme.bodyMedium),
            Text(
              data.city,
              style: Theme.of(context).textTheme.bodyMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        );
      },
    );
  }
}

//----------------------------- Profile Image-----------------------------
class ProfileImage extends StatelessWidget {
  ProfileImage({super.key});
  final auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return BlocSelector<ProfileBloc, ProfileState, String>(
      selector: (state) => state.data.imgURL,
      builder: (context, url) {
        final hasValidUrl =
            url.isNotEmpty && Uri.tryParse(url)?.hasAbsolutePath == true;
        return Padding(
          padding: EdgeInsets.only(bottom: 5.h),
          child: Container(
            height: 280.h,
            width: double.maxFinite.w,
            decoration: BoxDecoration(
              image: hasValidUrl
                  ? DecorationImage(
                      fit: BoxFit.cover,
                      image: CachedNetworkImageProvider(url),
                    )
                  : null,
              color: AppColors.floralWhite,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12.r),
                topRight: Radius.circular(12.r),
              ),
              shape: BoxShape.rectangle,
            ),
            child: Padding(
              padding: EdgeInsets.all(8.0.r),
              child: Align(
                alignment: Alignment.topRight,
                child: UserStatus(id: auth.currentUser!.uid),
              ),
            ),
          ),
        );
      },
    );
  }
}
