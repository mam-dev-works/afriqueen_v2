//------------ main part of data fetched state-----------------
import 'package:afriqueen/common/constant/constant_colors.dart';
import 'package:afriqueen/common/widgets/user_status.dart';
import 'package:afriqueen/features/home/bloc/home_bloc.dart';
import 'package:afriqueen/features/home/bloc/home_state.dart';
import 'package:afriqueen/features/home/model/home_model.dart';
import 'package:afriqueen/features/user_details/screen/user_details_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

//-----------------------Prifle picture grid----------------------------
class UserImageGrid extends StatelessWidget {
  const UserImageGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<HomeBloc, HomeState, List<HomeModel?>>(
      selector: (state) => state.data,
      builder: (context, data) {
        return GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: data.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12.h,
            crossAxisSpacing: 3.w,
            childAspectRatio: 0.9,
          ),
          itemBuilder: (BuildContext context, index) {
            final hasValidUrl =
                data[index]!.imgURL.isNotEmpty &&
                Uri.tryParse(data[index]!.imgURL)?.hasAbsolutePath == true;
            return InkWell(
              onTap: () => Get.to(UserDetailsScreen(data: data[index]!)),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadiusGeometry.circular(8.r),
                ),
                color: AppColors.floralWhite,
                child: Container(
                  decoration: BoxDecoration(
                    image:
                        hasValidUrl
                            ? DecorationImage(
                              fit: BoxFit.cover,
                              image: CachedNetworkImageProvider(
                                data[index]!.imgURL,
                              ),
                            )
                            : null,
                    color: AppColors.transparent,
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(8.r),
                    border: BoxBorder.all(
                      width: 0.5.w,
                      color: AppColors.grey.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Stack(
                    children: [
                      if (hasValidUrl)
                        Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              fit: BoxFit.cover,
                              image: CachedNetworkImageProvider(
                                data[index]!.imgURL,
                              ),
                            ),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
              
                      // Top right UserStatus
                      Positioned(
                        top: 8.r,
                        right: 8.r,
                        child: UserStatus(
                          id: data[index]!.id,
                          width: 15.w,
                          height: 15.h,
                        ),
                      ),
              
                      // Bottom center ListTile
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.r,
                            vertical: 6.r,
                          ),
                          color: AppColors.black.withValues(
                            alpha: 0.15,
                          ), // Optional background overlay
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "${data[index]!.pseudo},",
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyLarge!.copyWith(
                                      color: AppColors.floralWhite,
                                      fontSize: 20.sp,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    "${data[index]!.age}",
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyLarge!.copyWith(
                                      color: AppColors.floralWhite,
                                      fontSize: 20.sp,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                              Text(
                                data[index]!.city,
                                style: Theme.of(
                                  context,
                                ).textTheme.bodySmall!.copyWith(
                                  color: AppColors.floralWhite,
                                  fontSize: 14.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
