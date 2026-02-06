//-------------------Image and status------------------------------
import 'package:afriqueen/common/constant/constant_colors.dart';
import 'package:afriqueen/common/localization/enums/enums.dart';
import 'package:afriqueen/common/widgets/seniority.dart';
import 'package:afriqueen/common/widgets/snackbar_message.dart';
import 'package:afriqueen/common/widgets/user_status.dart';
import 'package:afriqueen/features/archive/bloc/archive_bloc.dart';
import 'package:afriqueen/features/archive/bloc/archive_event.dart';
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
import 'package:afriqueen/features/chat/repository/chat_repository.dart';
import 'package:afriqueen/features/match/repository/like_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:afriqueen/features/chat/screen/chat_screen.dart';
import 'package:afriqueen/features/chat/bloc/chat_bloc.dart';

//-----------Image and Status---------------------------
class ImageAndStatus extends StatelessWidget {
  const ImageAndStatus({
    super.key,
    required this.user,
  });

  final HomeModel user;

  @override
  Widget build(BuildContext context) {
    final validUrl = user.photos.isNotEmpty &&
        user.photos.first.isNotEmpty &&
        Uri.tryParse(user.photos.first)?.hasAbsolutePath == true;
    return Stack(
      children: [
        Container(
          width: double.maxFinite,
          height: 220.h,
          decoration: validUrl
              ? BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16.r),
                    topRight: Radius.circular(16.r),
                  ),
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: CachedNetworkImageProvider(user.photos.isNotEmpty ? user.photos.first : ''),
                  ),
                  // Elite styling
                  border: user.isElite 
                      ? Border.all(
                          color: Color(0xFFFFD700), // Yellow border for elite accounts
                          width: 3.w,
                        )
                      : null,
                )
              : null,
        ),
        Positioned(
          top: 12.r,
          right: 12.r,
          child: UserStatus(id: user.id),
        ),
        // Elite badge
        if (user.isElite)
          Positioned(
            top: 12.r,
            left: 12.r,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: Color(0xFFFFD700).withOpacity(0.9),
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                'Compte élite',
                style: TextStyle(
                  color: AppColors.black,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Roboto-SemiBold',
                ),
              ),
            ),
          ),
        Positioned(
          bottom: 12.r,
          left: 12.r,
          child: CreatedDate(user: user),
        ),
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
      padding: EdgeInsets.symmetric(horizontal: 12.r, vertical: 6.r),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        Seniority.formatJoinedTime(user.createdDate),
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.floralWhite,
              fontWeight: FontWeight.w500,
            ),
      ),
    );
  }
}

//----------------fav , following, archive----------------
class ListOfButtons extends StatelessWidget {
  const ListOfButtons({
    super.key,
    required this.user,
  });

  final HomeModel user;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            onPressed: () async {
              final likeRepository = LikeRepository();
              final alreadyLiked = await likeRepository.hasLikedUser(user.id);
              if (alreadyLiked) {
                await likeRepository.unlikeUser(user.id);
                if (!context.mounted) return;
                snackBarMessage(
                  context,
                  'Unliked!',
                  Theme.of(context),
                );
              } else {
                await likeRepository.likeUser(user.id);
                if (!context.mounted) return;
                snackBarMessage(
                  context,
                  'Liked!',
                  Theme.of(context),
                );
              }
            },
            icon: Icon(
              Icons.thumb_up_alt_outlined,
              color: AppColors.primaryColor,
              size: 22.r,
            ),
          ),
          StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('chats')
                .where('participants', arrayContains: FirebaseAuth.instance.currentUser?.uid)
                .snapshots(),
            builder: (context, snapshot) {
              final currentUserId = FirebaseAuth.instance.currentUser?.uid;
              QueryDocumentSnapshot<Map<String, dynamic>>? existing;
              if (snapshot.hasData) {
                for (final d in snapshot.data!.docs) {
                  final p = List<String>.from(d['participants'] ?? []);
                  if (currentUserId != null && p.contains(currentUserId) && p.contains(user.id)) {
                    existing = d;
                    break;
                  }
                }
              }
              final isPending = existing != null && (existing!['isRequest'] == true) && ((existing!['status'] == null) || (existing!['status'] == 'PENDING'));
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () async {
                      try {
                        final chatRepository = ChatRepository();
                        final chatId = await chatRepository.createOrGetChat(
                          user.id,
                          {
                            'id': user.id,
                            'name': user.pseudo,
                            'photoUrl': user.photos.isNotEmpty ? user.photos.first : '',
                          },
                        );
                        if (!context.mounted) return;
                        Get.to(
                          () => RepositoryProvider(
                            create: (context) => ChatRepository(),
                            child: BlocProvider(
                              create: (context) => ChatBloc(ChatRepository()),
                              child: ChatScreen(
                                chatId: chatId,
                                receiverId: user.id,
                                receiverName: user.pseudo,
                                receiverPhotoUrl: user.photos.isNotEmpty ? user.photos.first : '',
                              ),
                            ),
                          ),
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
                    child: Icon(
                      CupertinoIcons.chat_bubble,
                      color: AppColors.primaryColor,
                      size: 22.r,
                    ),
                  ),
                  if (isPending) SizedBox(width: 6.w),
                  if (isPending)
                    GestureDetector(
                      onTap: () async {
                        try {
                          await FirebaseFirestore.instance.collection('chats').doc(existing!.id).delete();
                        } catch (e) {
                          if (!context.mounted) return;
                          snackBarMessage(context, EnumLocale.defaultError.name.tr, Theme.of(context));
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(EnumLocale.cancel.name.tr, style: TextStyle(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.w600)),
                      ),
                    ),
                ],
              );
            },
          ),
          IconButton(
            onPressed: () async {
              context
                  .read<FavoriteBloc>()
                  .add(FavoriteUserAdded(favId: user.id));
              snackBarMessage(
                context,
                EnumLocale.savedToFavorites.name.tr,
                Theme.of(context),
              );
              await Future.delayed(Duration(milliseconds: 500));
            },
            icon: Icon(
              Icons.favorite_border_outlined,
              size: 22.r,
              color: AppColors.primaryColor,
            ),
          ),
          IconButton(
            onPressed: () async {
              context
                  .read<ArchiveBloc>()
                  .add(ArchiveUserAdded(archiveId: user.id));
              snackBarMessage(
                context,
                EnumLocale.savedToArchives.name.tr,
                Theme.of(context),
              );
              await Future.delayed(Duration(milliseconds: 500));
            },
            icon: Icon(
              LineIcons.archive,
              color: AppColors.primaryColor,
              size: 22.r,
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
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.pseudo,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              SizedBox(height: 4.h),
              Text(
                "${user.age} ${EnumLocale.age.name.tr}",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.grey,
                    ),
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: AppColors.primaryColor.withOpacity(0.3),
                width: 1.w,
              ),
            ),
            child: Text(
              user.city,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

//-----------------------Interest grid------------------------
class Interests extends StatelessWidget {
  const Interests({super.key, required this.user});

  final HomeModel user;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            EnumLocale.interests.name.tr,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
          ),
          SizedBox(height: 8.h),
          Wrap(
            spacing: 6.w,
            runSpacing: 6.h,
            children: user.mainInterests.map((interest) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: AppColors.primaryColor.withOpacity(0.3),
                    width: 0.5.w,
                  ),
                ),
                child: Text(
                  interest.tr,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.w500,
                        fontSize: 10.sp,
                      ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
