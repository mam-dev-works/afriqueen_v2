import 'package:afriqueen/common/constant/constant_colors.dart';
import 'package:afriqueen/common/localization/enums/enums.dart';
import 'package:afriqueen/common/widgets/divider.dart';

import 'package:afriqueen/features/profile/model/profile_model.dart';
import 'package:afriqueen/features/stories/bloc/stories_bloc.dart';
import 'package:afriqueen/features/stories/bloc/stories_event.dart';
import 'package:afriqueen/features/stories/bloc/stories_state.dart';
import 'package:afriqueen/features/stories/model/stories_model.dart';
import 'package:afriqueen/features/stories/repository/stories_repository.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_avatar/flutter_advanced_avatar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

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
    return SizedBox(
      width: 90,
      height: 110,
      child: Stack(
      children: [
          // Avatar positioned at top
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Center(
              child: AdvancedAvatar(
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
                size: 70,
              ),
            ),
        ),
          // Text positioned at bottom with better alignment
          Positioned(
            bottom: 8,
            left: 0,
            right: 0,
            child: Text(
          story.userName,
          style: Theme.of(context)
              .textTheme
              .bodySmall!
                  .copyWith(color: AppColors.black, fontSize: 12.sp),
          overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              maxLines: 1,
            ),
          ),
      ],
      ),
    );
  }
}

//---------------------Current user Stories--------------------------------
class OwnStories extends StatelessWidget {
  final bool hasValidUrl;
  final ProfileModel profile;
  final VoidCallback? onTap;

  const OwnStories({
    super.key,
    required this.hasValidUrl,
    required this.profile,
    this.onTap,
  });

  Future<void> _pickImageAndAddStory(BuildContext blocContext) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (image != null) {
        final File imageFile = File(image.path);
        blocContext.read<StoriesBloc>().add(
          StoriesImage(
            name: (profile.pseudo.isNotEmpty ? profile.pseudo : EnumLocale.unknownUser.name.tr),
            img: profile.imgURL,
            imageFile: imageFile,
          ),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de sélectionner l\'image',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("OwnStories - Profile data: ${profile.toJson()}");
    debugPrint("OwnStories - Has valid URL: $hasValidUrl");
    debugPrint("OwnStories - Profile image URL: ${profile.imgURL}");
    
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 90,
        height: 110,
        child: Stack(
        children: [
            // Avatar positioned at top
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Center(
                child: AdvancedAvatar(
            foregroundDecoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: profile.isElite ? Colors.amber : AppColors.primaryColor,
                width: profile.isElite ? 3.0 : 2.5,
              ),
            ),
            decoration: const BoxDecoration(
              color: AppColors.floralWhite,
              shape: BoxShape.circle,
            ),
            image: hasValidUrl && profile.imgURL != null
                ? CachedNetworkImageProvider(profile.imgURL)
                : null,
                  size: 70,
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
                                    return SafeArea(
                                      child: SingleChildScrollView(
                                        child: Column(
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
                                        onTap: () => _pickImageAndAddStory(blocContext),
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
                                        ),
                                      ),
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
              ),
            ),
            // Text positioned at bottom with better alignment
            Positioned(
              bottom: 8,
              left: 0,
              right: 0,
              child: Text(
            (profile.pseudo.isNotEmpty ? profile.pseudo : EnumLocale.unknownUser.name.tr),
            style: Theme.of(context)
                .textTheme
                .bodySmall!
                    .copyWith(color: AppColors.black, fontSize: 12.sp),
            overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                maxLines: 1,
              ),
            ),
        ],
        ),
      ),
    );
  }
}
