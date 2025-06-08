//------------ main part of data fetched state-----------------
import 'package:afriqueen/common/constant/constant_colors.dart';
import 'package:afriqueen/common/widgets/shimmer_effect.dart';
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
        selector: (state) => state.profileList,
        builder: (context, profileList) {
          // Access favorite state using context.select
          final hasValidImages = profileList.any(
            (item) =>
                item != null &&
                item.imgURL.isNotEmpty &&
                Uri.tryParse(item.imgURL)?.hasAbsolutePath == true,
          );

          return ShimmerScreen(
            enabled: profileList.isEmpty && hasValidImages ? true : false,
            child: GridView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              physics: NeverScrollableScrollPhysics(),
              itemCount: profileList.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.9,
              ),
              itemBuilder: (BuildContext context, index) {
                final item = profileList[index]!;

                final hasValidUrl = item.imgURL.isNotEmpty &&
                    Uri.tryParse(item.imgURL)?.hasAbsolutePath == true;
                return hasValidUrl
                    ? InkWell(
                        onTap: () =>
                            Get.to(() => UserDetailsScreen(data: item)),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadiusGeometry.circular(8.r),
                          ),
                          color: AppColors.floralWhite,
                          child: Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: CachedNetworkImageProvider(
                                      item.imgURL,
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
                                  id: item.id,
                                  width: 15.w,
                                  height: 15.h,
                                ),
                              ),

                              // Bottom center
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8.r,
                                  ),
                                  color: AppColors.grey.withValues(
                                      alpha:
                                          0.15), // Optional background overlay
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "${item.pseudo},",
                                            style: Theme.of(
                                              context,
                                            ).textTheme.bodyLarge!.copyWith(
                                                  color: AppColors.floralWhite,
                                                  fontSize: 20.sp,
                                                ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            "${item.age}",
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
                                        item.city,
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
                      )
                    : null;
              },
            ),
          );
        });
  }
}
