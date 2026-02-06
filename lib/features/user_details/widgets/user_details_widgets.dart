// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:afriqueen/common/constant/constant_colors.dart';
import 'package:afriqueen/common/localization/enums/enums.dart';
import 'package:afriqueen/common/widgets/common_button.dart';
import 'package:afriqueen/common/widgets/snackbar_message.dart';
import 'package:afriqueen/common/widgets/user_status.dart';
import 'package:afriqueen/common/widgets/seniority.dart';
import 'package:afriqueen/features/archive/bloc/archive_bloc.dart';
import 'package:afriqueen/features/archive/bloc/archive_event.dart';
import 'package:afriqueen/features/chat/bloc/chat_bloc.dart';
import 'package:afriqueen/features/chat/screen/chat_screen.dart';
import 'package:afriqueen/features/favorite/bloc/favorite_bloc.dart';
import 'package:afriqueen/features/favorite/bloc/favorite_event.dart';
import 'package:afriqueen/features/home/model/home_model.dart';
import 'package:afriqueen/features/user_details/screen/user_details_screen.dart';
import 'package:afriqueen/routes/app_routes.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:line_icons/line_icons.dart';
import 'package:afriqueen/features/chat/repository/chat_repository.dart';
import 'package:afriqueen/features/blocked/repository/blocked_repository.dart';
import 'package:afriqueen/features/report_profile/screen/report_profile_reason_screen.dart';
import 'package:afriqueen/services/distance/distance_calculator.dart';

import '../../match/repository/like_repository.dart';

//-------------------Profile Image Gallery------------------------------
class ProfileImageGallery extends StatelessWidget {
  const ProfileImageGallery({
    super.key,
    required this.widget,
    required this.hasValidUrl,
  });

  final UserDetailsScreen widget;
  final bool hasValidUrl;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Main profile image
        Expanded(
          flex: 2,
          child: Container(
            height: 200.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              border: widget.data.isElite ? Border.all(
                color: Color(0xFFFFD700), // Yellow border for elite accounts
                width: 3.w,
              ) : null,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(widget.data.isElite ? 9.r : 12.r),
              child: hasValidUrl
                  ? CachedNetworkImage(
                      imageUrl: widget.data.photos.first,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[300],
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[300],
                        child: Icon(Icons.person, size: 50.r, color: Colors.grey[600]),
                      ),
                    )
                  : Container(
                      color: Colors.grey[300],
                      child: Icon(Icons.person, size: 50.r, color: Colors.grey[600]),
                    ),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        
        // Thumbnail images
        Expanded(
          child: Column(
            children: [
              // First row of thumbnails
              Row(
                children: [
                  Expanded(child: _buildThumbnail(1)),
                  SizedBox(width: 8.w),
                  Expanded(child: _buildThumbnail(2)),
                ],
              ),
              SizedBox(height: 8.h),
              // Second row of thumbnails
              Row(
                children: [
                  Expanded(child: _buildThumbnail(3)),
                  SizedBox(width: 8.w),
                  Expanded(child: _buildThumbnail(4)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildThumbnail(int index) {
    final hasPhoto = widget.data.photos.length > index;
    return Container(
      height: 96.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        color: hasPhoto ? null : Colors.grey[200],
      ),
      child: hasPhoto
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: CachedNetworkImage(
                imageUrl: widget.data.photos[index],
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                placeholder: (context, url) => Container(
                  color: Colors.grey[300],
                  child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[200],
                  child: Center(
                    child: Text(
                      EnumLocale.userDetailsNoPhoto.name.tr,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            )
          : Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.r),
                color: Colors.grey[200],
              ),
              child: Center(
                child: Text(
                  EnumLocale.userDetailsNoPhoto.name.tr,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
    );
  }
}

//-------------------Action Buttons Row------------------------------
class ActionButtonsRow extends StatefulWidget {
  const ActionButtonsRow({super.key, required this.model});
  final HomeModel model;
  
  @override
  State<ActionButtonsRow> createState() => _ActionButtonsRowState();
}

class _ActionButtonsRowState extends State<ActionButtonsRow> {
  bool isLiked = false;
  bool loadingLike = true;

  @override
  void initState() {
    super.initState();
    _checkLikeStatus();
  }

  Future<void> _checkLikeStatus() async {
    final likeRepository = LikeRepository();
    final liked = await likeRepository.hasLikedUser(widget.model.id);
    if (mounted) {
      setState(() {
        isLiked = liked;
        loadingLike = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildActionButton(
          icon: loadingLike
              ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(
                  isLiked ? Icons.favorite : Icons.favorite_outline,
                  color: isLiked ? Colors.red : Colors.grey[600],
                  size: 24,
                ),
          onTap: () async {
            final likeRepository = LikeRepository();
            final alreadyLiked = await likeRepository.hasLikedUser(widget.model.id);
            if (alreadyLiked) {
              await likeRepository.unlikeUser(widget.model.id);
              if (mounted) {
                setState(() {
                  isLiked = false;
                });
              }
            } else {
              await likeRepository.likeUser(widget.model.id);
              if (mounted) {
                setState(() {
                  isLiked = true;
                });
              }
            }
          },
        ),
        _buildActionButton(
          icon: Icon(Icons.chat_bubble_outline, color: Colors.grey[600], size: 24),
          onTap: () async {
            final chatRepository = ChatRepository();
            try {
              final chatId = await chatRepository.createOrGetChat(
                widget.model.id,
                {
                  'id': widget.model.id,
                  'name': widget.model.pseudo,
                  'photoUrl': widget.model.photos.first,
                },
              );
              
              if (!mounted) return;
              
              Get.to(
                () => RepositoryProvider(
                  create: (context) => ChatRepository(),
                  child: BlocProvider(
                    create: (context) => ChatBloc(ChatRepository()),
                    child: ChatScreen(
                      chatId: chatId,
                      receiverId: widget.model.id,
                      receiverName: widget.model.pseudo,
                      receiverPhotoUrl: widget.model.photos.first,
                    ),
                  ),
                ),
              );
            } catch (e) {
              debugPrint('Error creating chat: $e');
            }
          },
        ),
        _buildActionButton(
          icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[600], size: 24),
          onTap: () {
            context.read<ArchiveBloc>().add(ArchiveUserAdded(archiveId: widget.model.id));
            snackBarMessage(context, EnumLocale.savedToArchives.name.tr, Theme.of(context));
          },
        ),
        _buildActionButton(
          icon: Icon(Icons.star_outline, color: Colors.grey[600], size: 24),
          onTap: () {
            context.read<FavoriteBloc>().add(FavoriteUserAdded(favId: widget.model.id));
            snackBarMessage(context, EnumLocale.savedToFavorites.name.tr, Theme.of(context));
          },
        ),
        _buildActionButton(
          icon: Icon(Icons.block_outlined, color: Colors.grey[600], size: 24),
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => BlockAlertDialog(
                userId: widget.model.id,
                userName: widget.model.pseudo,
              ),
            );
          },
        ),
        _buildActionButton(
          icon: Icon(Icons.report_outlined, color: Colors.grey[600], size: 24),
          onTap: () {
            Get.to(() => ReportProfileReasonScreen(user: widget.model));
          },
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required Widget icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40.w,
        height: 40.h,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade300, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Center(child: icon),
      ),
    );
  }
}

//-------------------Basic Info Section------------------------------
class BasicInfoSection extends StatefulWidget {
  const BasicInfoSection({
    super.key,
    required this.userDetailsScreen,
    required this.date,
  });

  final UserDetailsScreen userDetailsScreen;
  final String date;

  @override
  State<BasicInfoSection> createState() => _BasicInfoSectionState();
}

class _BasicInfoSectionState extends State<BasicInfoSection> {
  double? _distance;
  bool _isLoadingDistance = true;

  @override
  void initState() {
    super.initState();
    _calculateDistance();
  }

  Future<void> _calculateDistance() async {
    try {
      final distance = await DistanceCalculator.calculateDistanceToUser(
        widget.userDetailsScreen.data.city,
        widget.userDetailsScreen.data.country,
      );
      if (mounted) {
        setState(() {
          _distance = distance;
          _isLoadingDistance = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingDistance = false;
        });
      }
    }
  }

  String _formatCreatedDate(DateTime createdDate) {
    return Seniority.formatJoinedTime(createdDate);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Left column
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${widget.userDetailsScreen.data.age} ${EnumLocale.userDetailsAgeSuffix.name.tr}",
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 4.h),
              _isLoadingDistance
                  ? Text(
                      '...',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    )
                  : Text(
                      "${DistanceCalculator.formatDistance(_distance)}${EnumLocale.userDetailsDistance.name.tr.isNotEmpty ? ' ' : ''}${EnumLocale.userDetailsDistance.name.tr}",
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
              SizedBox(height: 4.h),
              Text(
                _formatCreatedDate(widget.userDetailsScreen.data.createdDate),
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
        
        // Right column
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.userDetailsScreen.data.relationshipStatus.isNotEmpty 
                    ? widget.userDetailsScreen.data.relationshipStatus 
                    : EnumLocale.userDetailsSingle.name.tr,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                widget.userDetailsScreen.data.mainInterests.isNotEmpty 
                    ? widget.userDetailsScreen.data.mainInterests.first 
                    : EnumLocale.userDetailsDating.name.tr,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                widget.userDetailsScreen.data.pseudo,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

//-------------------Information Categories------------------------------
class InformationCategories extends StatelessWidget {
  const InformationCategories({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildCategoryButton(EnumLocale.userDetailsPhysical.name.tr),
        SizedBox(height: 8.h),
        _buildCategoryButton(EnumLocale.userDetailsPersonal.name.tr),
        SizedBox(height: 8.h),
        _buildCategoryButton(EnumLocale.userDetailsInterest.name.tr),
        SizedBox(height: 8.h),
        _buildCategoryButton(EnumLocale.userDetailsProfessional.name.tr),
      ],
    );
  }

  Widget _buildCategoryButton(String title) {
    return Container(
      width: double.infinity,
      height: 40.h,
      decoration: BoxDecoration(
        color: Color(0xFFFFB6C1).withOpacity(0.3), // Light pink
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Center(
        child: Text(
          title,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}

//-------------------Description Section------------------------------
class DescriptionSection extends StatelessWidget {
  const DescriptionSection({super.key, required this.widget});

  final UserDetailsScreen widget;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          EnumLocale.userDetailsDescription.name.tr,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          widget.data.description.isNotEmpty 
              ? widget.data.description 
              : EnumLocale.userDetailsDefaultDescription.name.tr,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            color: Colors.black,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

//-------------------What Looking For Section------------------------------
class WhatLookingForSection extends StatelessWidget {
  const WhatLookingForSection({super.key, required this.widget});

  final UserDetailsScreen widget;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          EnumLocale.userDetailsWhatLookingFor.name.tr,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          widget.data.whatLookingFor.isNotEmpty 
              ? widget.data.whatLookingFor 
              : EnumLocale.userDetailsDefaultLookingFor.name.tr,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            color: Colors.black,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

//-------------------What Not Want Section------------------------------
class WhatNotWantSection extends StatelessWidget {
  const WhatNotWantSection({super.key, required this.widget});

  final UserDetailsScreen widget;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          EnumLocale.userDetailsWhatNotWant.name.tr,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          widget.data.whatNotWant.isNotEmpty 
              ? widget.data.whatNotWant 
              : EnumLocale.userDetailsDefaultNotWant.name.tr,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            color: Colors.black,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

//-------------------Story Section------------------------------
class StorySection extends StatelessWidget {
  const StorySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          EnumLocale.userDetailsStory.name.tr,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          EnumLocale.userDetailsNoStory.name.tr,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            color: Colors.black,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

//-------------------Events Section------------------------------
class EventsSection extends StatelessWidget {
  const EventsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          EnumLocale.userDetailsEvents.name.tr,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          EnumLocale.userDetailsNoEvents.name.tr,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            color: Colors.black,
            height: 1.4,
          ),
        ),
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
      padding: EdgeInsets.only(left: 20.w),
      child: Container(
          padding: EdgeInsets.all(8.r),
          decoration: BoxDecoration(
              color: AppColors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r)),
          child: Text(date, style: Theme.of(context).textTheme.bodyMedium)),
    );
  }
}

//-----------------User description-------------------------
class Description extends StatelessWidget {
  const Description({super.key, required this.widget});

  final UserDetailsScreen widget;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(14.r),
        decoration: BoxDecoration(
          color: AppColors.floralWhite,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          widget.data.description,
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
            color: AppColors.black,
            fontSize: 16.sp,
            fontWeight: FontWeight.w400,
          ),
        ),
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
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Wrap(
        spacing: 8.w,
        runSpacing: 8.h,
        children: widget.data.mainInterests.map((interest) {
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: AppColors.primaryColor, width: 1.2.w),
            ),
            child: Text(
              interest,
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                color: AppColors.primaryColor,
                fontWeight: FontWeight.w600,
                fontSize: 14.sp,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ---------pesudo, age and City--------------------------
class UserDetails extends StatelessWidget {
  const UserDetails({super.key, required this.widget});

  final UserDetailsScreen widget;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            widget.data.pseudo,
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
              color: AppColors.black,
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(width: 10.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Text(
              "${widget.data.age}",
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: AppColors.primaryColor,
                fontWeight: FontWeight.w600,
                fontSize: 18.sp,
              ),
            ),
          ),
          SizedBox(width: 10.w),
          Icon(Icons.location_on, color: AppColors.primaryColor, size: 20.r),
          SizedBox(width: 2.w),
          Text(
            widget.data.city,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              color: AppColors.grey,
              fontWeight: FontWeight.w400,
              fontSize: 16.sp,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

//----------------Like, Chat, Favorites, Achieve----------------
class ButtonList extends StatefulWidget {
  const ButtonList({super.key, required this.model});
  final HomeModel model;
  
  @override
  State<ButtonList> createState() => _ButtonListState();
}

class _ButtonListState extends State<ButtonList> {
  bool isLiked = false;
  bool loadingLike = true;

  @override
  void initState() {
    super.initState();
    _checkLikeStatus();
  }

  Future<void> _checkLikeStatus() async {
    final likeRepository = LikeRepository();
    final liked = await likeRepository.hasLikedUser(widget.model.id);
    if (mounted) {
      setState(() {
        isLiked = liked;
        loadingLike = false;
      });
    }
  }

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
                onPressed: () async {
                  final likeRepository = LikeRepository();
                  final alreadyLiked = await likeRepository.hasLikedUser(widget.model.id);
                  if (alreadyLiked) {
                    await likeRepository.unlikeUser(widget.model.id);
                    if (mounted) {
                      setState(() {
                        isLiked = false;
                      });
                    }
                    snackBarMessage(
                      context,
                      'Unliked!',
                      Theme.of(context),
                    );
                  } else {
                    await likeRepository.likeUser(widget.model.id);
                    if (mounted) {
                      setState(() {
                        isLiked = true;
                      });
                    }
                    snackBarMessage(
                      context,
                      'Liked!',
                      Theme.of(context),
                    );
                  }
                },
                icon: loadingLike
                    ? SizedBox(
                        width: 30,
                        height: 30,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(
                        isLiked ? Icons.thumb_up_alt : Icons.thumb_up_alt_outlined,
                        color: isLiked ? Colors.red : AppColors.black,
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
                    debugPrint('Creating chat for user: ${widget.model.id}');
                    final chatId = await chatRepository.createOrGetChat(
                      widget.model.id,
                      {
                        'id': widget.model.id,
                        'name': widget.model.pseudo,
                        'photoUrl': widget.model.photos.first,
                      },
                    );
                    debugPrint('Chat created with ID: $chatId');
                    
                    if (!mounted) return;
                    
                    final args = {
                      'chatId': chatId,
                      'otherUser': {
                        'id': widget.model.id,
                        'name': widget.model.pseudo,
                        'photoUrl': widget.model.photos.first,
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
                            receiverId: widget.model.id,
                            receiverName: widget.model.pseudo,
                            receiverPhotoUrl: widget.model.photos.first,
                          ),
                        ),
                      ),
                      arguments: args,
                    );
                  } catch (e) {
                    debugPrint('Error creating chat: $e');
                    if (!mounted) return;
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
                onPressed: () async {
                  context
                      .read<FavoriteBloc>()
                      .add(FavoriteUserAdded(favId: widget.model.id));
                  snackBarMessage(context, EnumLocale.savedToFavorites.name.tr,
                      Theme.of(context));
                  await Future.delayed(Duration(milliseconds: 500));
                  Get.toNamed(AppRoutes.main);
                },
                icon: Icon(Icons.favorite_border_outlined,
                    size: 30, color: AppColors.black),
              ),
              Text(
                EnumLocale.Favorite.name.tr,
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
                  context
                      .read<ArchiveBloc>()
                      .add(ArchiveUserAdded(archiveId: widget.model.id));
                  snackBarMessage(context, EnumLocale.savedToArchives.name.tr,
                      Theme.of(context));
                  await Future.delayed(Duration(milliseconds: 500));
                  Get.toNamed(AppRoutes.main);
                },
                icon: Icon(
                  LineIcons.archive,
                  color: AppColors.black,
                  size: 30,
                ),
              ),
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

//---------------- AppBar -----------------------
class UserDetailsAppBar extends StatelessWidget {
  const UserDetailsAppBar({
    Key? key,
    required this.isScrollingUp,
    required this.name,
    required this.userId,
    required this.userName,
  }) : super(key: key);
  final bool isScrollingUp;
  final String name;
  final String userId;
  final String userName;
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
          itemBuilder: (context) => [
            PopupMenuItem(
              child: Text(
                EnumLocale.report.name.tr,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium!.copyWith(color: AppColors.red),
              ),
            ),
            PopupMenuItem(
              onTap: () => showDialog(
                  context: context, builder: (context) => BlockAlertDialog(
                    userId: userId,
                    userName: userName,
                  )),
              child: Text(
                EnumLocale.block.name.tr,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

//----------- Dialog Box to ask for block----------------------------------
class BlockAlertDialog extends StatelessWidget {
  const BlockAlertDialog({
    super.key,
    required this.userId,
    required this.userName,
  });

  final String userId;
  final String userName;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.symmetric(horizontal: 15.w),
      titlePadding: EdgeInsets.only(top: 10.h),
      title: Icon(
        Icons.block_outlined,
        color: AppColors.red,
        size: 100.r,
        shadows: [
          Shadow(
              color: AppColors.primaryColor.withValues(alpha: 1),
              blurRadius: 100.r)
        ],
      ),
      backgroundColor: AppColors.floralWhite,
      shape: RoundedRectangleBorder(
          side: BorderSide(color: AppColors.grey, width: 1),
          borderRadius: BorderRadiusGeometry.circular(8.r)),
      content: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 10.h,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 10.h,
          ),
          Text(
            EnumLocale.blockTitle.name.tr,
            style: Theme.of(context)
                .textTheme
                .bodyLarge!
                .copyWith(fontSize: 20.sp),
          ),
          SizedBox(
            height: 10.h,
          ),
          CommonButton(
              onPressed: () async {
                try {
                  final repository = BlockedRepository();
                  await repository.blockUser(userId);
                  
                  if (context.mounted) {
                    snackBarMessage(
                      context,
                      '$userName ' + EnumLocale.hasBeenBlocked.name.tr,
                      Theme.of(context),
                    );
                    
                    // Navigate back to main screen
                    await Future.delayed(Duration(milliseconds: 500));
                    Get.offAllNamed(AppRoutes.main);
                  }
                } catch (e) {
                  debugPrint('Error blocking user: $e');
                  if (context.mounted) {
                    snackBarMessage(
                      context,
                      EnumLocale.defaultError.name.tr,
                      Theme.of(context),
                    );
                  }
                }
              }, 
              buttonText: EnumLocale.yesBlock.name.tr),
          TextButton(
              onPressed: () => Get.back(),
              child: Text(
                EnumLocale.cancel.name.tr,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .copyWith(fontSize: 18.sp),
              ))
        ],
      ),
    );
  }
}
