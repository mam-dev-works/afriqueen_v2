import 'package:afriqueen/common/constant/constant_colors.dart';
import 'package:afriqueen/common/localization/enums/enums.dart';
import 'package:afriqueen/common/widgets/seniority.dart';
import 'package:afriqueen/common/widgets/snackbar_message.dart';
import 'package:afriqueen/common/widgets/user_status.dart';
import 'package:afriqueen/features/favorite/bloc/favorite_bloc.dart';
import 'package:afriqueen/features/favorite/bloc/favorite_event.dart';
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

import '../../archive/bloc/archive_bloc.dart';
import '../../archive/bloc/archive_event.dart';

//-------------------- user Image--------------------
class UserImage extends StatelessWidget {
  const UserImage({super.key, required this.Homedata});

  final HomeModel? Homedata;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.maxFinite,
          height: 280.h,
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

//----------------Like, Chat, Favorites, Achieve----------------
class ButtonsList extends StatelessWidget {
  const ButtonsList({super.key, required this.Homedata});

  final HomeModel? Homedata;

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
                  onPressed: () {
                    context
                        .read<FavoriteBloc>()
                        .add(FavoriteUserRemoved(favId: Homedata!.id));
                    snackBarMessage(
                        context,
                        EnumLocale.removedFromFavorites.name.tr,
                        Theme.of(context));
                  },
                  icon: Icon(
                    Icons.favorite,
                    color: AppColors.red,
                    size: 30,
                  )),
              Text(
                EnumLocale.removed.name.tr,
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
                    LineIcons.archive,
                    color: AppColors.black,
                    size: 30,
                  )),
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
