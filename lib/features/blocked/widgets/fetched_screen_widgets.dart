import 'package:afriqueen/common/constant/constant_colors.dart';
import 'package:afriqueen/common/localization/enums/enums.dart';
import 'package:afriqueen/common/widgets/seniority.dart';
import 'package:afriqueen/common/widgets/snackbar_message.dart';
import 'package:afriqueen/common/widgets/user_status.dart';
import 'package:afriqueen/features/blocked/bloc/blocked_bloc.dart';
import 'package:afriqueen/features/blocked/bloc/blocked_event.dart';
import 'package:afriqueen/features/blocked/repository/blocked_repository.dart';
import 'package:afriqueen/features/home/model/home_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:afriqueen/features/chat/bloc/chat_bloc.dart';
import 'package:afriqueen/features/chat/repository/chat_repository.dart';
import 'package:afriqueen/features/chat/screen/chat_screen.dart';

import '../../favorite/bloc/favorite_bloc.dart';

//-------------------- user Image--------------------
class UserImage extends StatelessWidget {
  const UserImage({super.key, required this.Homedata, this.height});

  final HomeModel? Homedata;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.maxFinite,
          height: (height ?? 280.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12.r),
              topRight: Radius.circular(12.r),
            ),
            image: DecorationImage(
              fit: BoxFit.cover,
              image: CachedNetworkImageProvider(Homedata!.photos.first),
            ),
            // Elite styling
            border: Homedata!.isElite
                ? Border.all(
                    color: Colors.amber,
                    width: 3.w,
                  )
                : null,
          ),
        ),
        Positioned(
          top: 8.r,
          right: 8.r,
          child: UserStatus(id: Homedata!.id),
        ),
        // Elite badge
        if (Homedata!.isElite)
          Positioned(
            top: 8.r,
            left: 8.r,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.star,
                    color: Colors.white,
                    size: 16.r,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    'ELITE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        // Blocked badge
        Positioned(
          top: 8.r,
          left: Homedata!.isElite ? 80.w : 8.r,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.block,
                  color: Colors.white,
                  size: 16.r,
                ),
                SizedBox(width: 4.w),
                Text(
                  EnumLocale.blockedTitle.name.tr,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

//-----------Seniority------------------------------
class CreatedDate extends StatelessWidget {
  const CreatedDate({super.key, required this.Homedata});

  final HomeModel? Homedata;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 20.w),
      child: Container(
          padding: EdgeInsets.all(8.r),
          decoration: BoxDecoration(
              color: AppColors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r)),
          child: Text(Seniority.formatJoinedTime(Homedata!.createdDate),
              style: Theme.of(context).textTheme.bodyMedium)),
    );
  }
}

//---------button list----------------------

//----------------Like, Chat, Favorites, Unblock----------------
class ButtonsList extends StatelessWidget {
  const ButtonsList({
    super.key,
    required this.Homedata,
    this.onUnblock,
  });

  final HomeModel? Homedata;
  final VoidCallback? onUnblock;

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
                onPressed: () async {
                  final chatRepository = ChatRepository();
                  try {
                    debugPrint('Creating chat for user: ${Homedata!.id}');
                    final chatId = await chatRepository.createOrGetChat(
                      Homedata!.id,
                      {
                        'id': Homedata!.id,
                        'name': Homedata!.pseudo,
                        'photoUrl': Homedata!.photos.first,
                      },
                    );
                    debugPrint('Chat created with ID: $chatId');

                    if (!context.mounted) return;

                    final args = {
                      'chatId': chatId,
                      'otherUser': {
                        'id': Homedata!.id,
                        'name': Homedata!.pseudo,
                        'photoUrl': Homedata!.photos.first,
                      },
                    };
                    debugPrint('Navigating to chat with args: $args');

                    Get.to(
                      () => RepositoryProvider(
                        create: (context) => ChatRepository(),
                        child: BlocProvider(
                          create: (context) => ChatBloc(ChatRepository()),
                          child: ChatScreen(
                            chatId: chatId,
                            receiverId: Homedata!.id,
                            receiverName: Homedata!.pseudo,
                            receiverPhotoUrl: Homedata!.photos.first,
                          ),
                        ),
                      ),
                      arguments: args,
                    );
                  } catch (e) {
                    debugPrint('Error creating chat: $e');
                    if (!context.mounted) return;
                    snackBarMessage(
                      context,
                      EnumLocale.defaultError.name.tr,
                      Theme.of(context),
                    );
                  }
                },
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
                  onPressed: () {},
                  icon: Icon(
                    Icons.favorite_border_outlined,
                    color: AppColors.black,
                    size: 30,
                  )),
              Text(
                EnumLocale.favorites.name.tr,
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
                    // Show confirmation dialog
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text(EnumLocale.unblockUser.name.tr),
                          content: Text(EnumLocale.questionToBlockUser.name.tr + ' ${Homedata!.pseudo}?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text(EnumLocale.cancel.name.tr),
                            ),
                            TextButton(
                              onPressed: () async {
                                Navigator.of(context).pop();

                                try {
                                  final repository = BlockedRepository();
                                  await repository.unblockUser(Homedata!.id);

                                  // Call the callback to refresh the UI
                                  if (onUnblock != null) {
                                    onUnblock!();
                                  }

                                  if (context.mounted) {
                                    snackBarMessage(
                                        context,
                                        EnumLocale.userUnblockedSuccessfully.name.tr,
                                        Theme.of(context));
                                  }
                                } catch (e) {
                                  debugPrint('Error unblocking user: $e');
                                  if (context.mounted) {
                                    snackBarMessage(
                                        context,
                                        EnumLocale.defaultError.name.tr,
                                        Theme.of(context));
                                  }
                                }
                              },
                              child: Text(EnumLocale.unblock.name.tr),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  icon: Icon(
                    Icons.block,
                    color: AppColors.red,
                    size: 30,
                  )),
              Text(
                EnumLocale.unblock.name.tr,
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

// ---------pesudo, age and City--------------------------
class UserDetails extends StatelessWidget {
  const UserDetails({super.key, required this.homeModel});

  final HomeModel homeModel;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Text(
          homeModel.pseudo,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge!.copyWith(color: AppColors.primaryColor),
        ),
        Text(
          "${homeModel.age}",
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        Text(
          homeModel.city,
          style: Theme.of(context).textTheme.bodyMedium,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

//---------------User description-------------------------
class Description extends StatelessWidget {
  const Description({super.key, required this.homeModel});

  final HomeModel homeModel;

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
          homeModel.description,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}

// Grid card for blocked user (compact like screenshot)
class BlockedGridCard extends StatelessWidget {
  const BlockedGridCard({super.key, required this.homeModel, this.onUnblock});

  final HomeModel homeModel;
  final VoidCallback? onUnblock;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.blue.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.grey.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Photo with overlays
          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12.r),
              topRight: Radius.circular(12.r),
            ),
            child: Stack(
              children: [
                UserImage(Homedata: homeModel, height: 140.h),
                Positioned(
                  right: 8.w,
                  top: 8.h,
                  child: UserStatus(id: homeModel.id),
                ),
                Positioned(
                  bottom: 8.h,
                  right: 8.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      EnumLocale.unblock.name.tr,
                      style: TextStyle(color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.w600),
                    ),
                  ),
                )
              ],
            ),
          ),

          // Basic info - scrollable to prevent overflow
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${homeModel.pseudo}, ${homeModel.age}',
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    Seniority.formatJoinedTime(homeModel.createdDate),
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  // Short tags (orientation, status, interests example)
                  _Tag(label: 'Homo'),
                  SizedBox(height: 3.h),
                  _Tag(label: 'Célibataire'),
                  SizedBox(height: 4.h),
                  Wrap(
                    spacing: 4.w,
                    runSpacing: 4.h,
                    children: [
                      _Chip(label: 'Amour'),
                      _Chip(label: 'Yoga'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.redAccent),
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }
}

//--------------- interests Grid--------------
//-----------------------Interest grid------------------------
class Interests extends StatelessWidget {
  const Interests({super.key, required this.homeModel});

  final HomeModel homeModel;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.symmetric(horizontal: 5.w),
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: homeModel.mainInterests.length,
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
              homeModel.mainInterests[index],
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