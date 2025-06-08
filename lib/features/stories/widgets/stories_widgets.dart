import 'package:afriqueen/common/constant/constant_colors.dart';
import 'package:afriqueen/common/localization/enums/enums.dart';
import 'package:afriqueen/common/widgets/divider.dart';

import 'package:afriqueen/features/profile/model/profile_model.dart';
import 'package:afriqueen/features/stories/bloc/stories_bloc.dart';
import 'package:afriqueen/features/stories/bloc/stories_event.dart';
import 'package:afriqueen/features/stories/model/stories_model.dart';
import 'package:afriqueen/features/stories/repository/stories_repository.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_avatar/flutter_advanced_avatar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

//---------------------Other user Stories--------------------------------
class OtherUserStories extends StatelessWidget {
  const OtherUserStories({
    super.key,
    required this.hasValidOtherUserImage,
    required this.story,
  });

  final bool hasValidOtherUserImage;
  final StoriesFetchModel story;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        AdvancedAvatar(
          foregroundDecoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.primaryColor,
              width: 2.5,
            ),
          ),
          decoration: const BoxDecoration(
            color: AppColors.floralWhite,
            shape: BoxShape.circle,
          ),
          image: hasValidOtherUserImage
              ? CachedNetworkImageProvider(story.userImg)
              : null,
          size: 75.r,
        ),
        Text(
          story.userName,
          style: Theme.of(context)
              .textTheme
              .bodySmall!
              .copyWith(color: AppColors.black, fontSize: 11.2.sp),
          overflow: TextOverflow.ellipsis,
        )
      ],
    );
  }
}

//---------------------Current user Stories--------------------------------
class OwnStories extends StatelessWidget {
  const OwnStories({
    super.key,
    required this.hasValidUrl,
    required this.profile,
  });

  final bool hasValidUrl;
  final ProfileModel profile;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        AdvancedAvatar(
          foregroundDecoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.primaryColor,
              width: 2.5,
            ),
          ),
          decoration: const BoxDecoration(
            color: AppColors.floralWhite,
            shape: BoxShape.circle,
          ),
          image:
              hasValidUrl ? CachedNetworkImageProvider(profile.imgURL) : null,
          size: 75.r,
          children: [
            Positioned(
              right: -0.4,
              bottom: -0.4,
              child: SizedBox(
                width: 25,
                height: 25,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  iconSize: 25.r,
                  onPressed: () => showModalBottomSheet(
                    constraints: BoxConstraints(
                      minWidth: double.maxFinite,
                    ),
                    backgroundColor: AppColors.floralWhite,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(8.r),
                      ),
                    ),
                    context: context,
                    builder: (bottomSheetContext) => RepositoryProvider(
                      create: (_) => StoriesRepository(),
                      child: BlocProvider<StoriesBloc>(
                        create: (blocContext) => StoriesBloc(
                          repo: blocContext.read<StoriesRepository>(),
                        ),
                        child: Builder(
                          builder: (blocContext) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    vertical: 10.h,
                                  ),
                                  child: Text(
                                    EnumLocale.addStory.name.tr,
                                    style: Theme.of(blocContext)
                                        .textTheme
                                        .bodyLarge!
                                        .copyWith(
                                          color: AppColors.primaryColor,
                                          fontSize: 25.sp,
                                        ),
                                  ),
                                ),
                                const CustomDivider(),
                                SizedBox(height: 25.h),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        blocContext.read<StoriesBloc>().add(
                                              StoriesImage(
                                                name: profile.pseudo,
                                                img: profile.imgURL,
                                              ),
                                            );

                                        Navigator.pop(blocContext);
                                      },
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.add_a_photo_outlined,
                                            size: 50.r,
                                          ),
                                          SizedBox(
                                            height: 10.h,
                                          ),
                                          Text(EnumLocale.addPhoto.name.tr),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 25.h),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  icon: Container(
                    decoration: const BoxDecoration(
                      color: AppColors.primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.add,
                      color: AppColors.floralWhite,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        Text(
          EnumLocale.yourStory.name.tr,
          style: Theme.of(context)
              .textTheme
              .bodySmall!
              .copyWith(color: AppColors.black, fontSize: 11.2.sp),
          overflow: TextOverflow.ellipsis,
        )
      ],
    );
  }
}
