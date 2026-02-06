//------------ main part of data fetched state-----------------
import 'package:afriqueen/common/constant/constant_colors.dart';
import 'package:afriqueen/common/widgets/shimmer_effect.dart';
import 'package:afriqueen/features/home/bloc/home_bloc.dart';
import 'package:afriqueen/features/home/bloc/home_event.dart';
import 'package:afriqueen/features/home/bloc/home_state.dart';
import 'package:afriqueen/features/home/model/home_model.dart';
import 'package:afriqueen/features/user_details/screen/user_details_screen.dart';
import 'package:afriqueen/common/localization/enums/enums.dart';
import 'package:afriqueen/features/activity/repository/user_profile_repository.dart';
import 'package:afriqueen/services/distance/distance_calculator.dart';
import 'package:afriqueen/features/archive/bloc/archive_bloc.dart';
import 'package:afriqueen/features/archive/bloc/archive_event.dart';
import 'package:afriqueen/features/archive/bloc/archive_state.dart';
import 'package:afriqueen/features/favorite/bloc/favorite_bloc.dart';
import 'package:afriqueen/features/favorite/bloc/favorite_event.dart';
import 'package:afriqueen/features/favorite/bloc/favorite_state.dart';
import 'package:afriqueen/features/match/bloc/match_bloc.dart';
import 'package:afriqueen/features/match/bloc/match_event.dart';
import 'package:afriqueen/features/match/bloc/match_state.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:afriqueen/features/chat/repository/chat_repository.dart';
import 'package:afriqueen/features/chat/screen/chat_screen.dart';
import 'package:afriqueen/features/chat/bloc/chat_bloc.dart';
import 'package:afriqueen/common/widgets/snackbar_message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

//-----------------------Profile Cards Grid----------------------------
class UserImageGrid extends StatefulWidget {
  const UserImageGrid({super.key});

  @override
  State<UserImageGrid> createState() => _UserImageGridState();
}

class _UserImageGridState extends State<UserImageGrid> {
  bool hasCheckedInitialLike = false;
  
  // Helper function to format last active time
  String _formatLastActive(DateTime lastActive) {
    final now = DateTime.now();
    final difference = now.difference(lastActive);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
  
  // Helper function to format created date
  String _formatCreatedDate(DateTime createdDate) {
    final now = DateTime.now();
    final difference = now.difference(createdDate);
    
    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years year${years > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months month${months > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else {
      return 'Today';
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocSelector<HomeBloc, HomeState, List<HomeModel?>>(
        selector: (state) => state.profileList,
        builder: (context, profileList) {
          print('UserImageGrid: Received ${profileList.length} profiles');
          
          // Check like status for the first profile on initial load
          if (!hasCheckedInitialLike && profileList.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final firstProfile = profileList.first;
              if (firstProfile != null) {
                context.read<MatchBloc>().add(CheckLikeStatus(userId: firstProfile.id));
              }
            });
            hasCheckedInitialLike = true;
          }
          
          // Debug: Print each profile
          for (int i = 0; i < profileList.length; i++) {
            final item = profileList[i];
            if (item != null) {
              print('UserImageGrid: Profile $i - ID: ${item.id}, Pseudo: ${item.pseudo}');
              print('UserImageGrid: Profile $i - photos: ${item.photos}');
              print('UserImageGrid: Profile $i - photos length: ${item.photos.length}');
            }
          }
          
          final hasValidImages = profileList.any(
            (item) =>
                item != null &&
                item.photos.isNotEmpty &&
                Uri.tryParse(item.photos.first)?.hasAbsolutePath == true,
          );
          
          print('UserImageGrid: Has valid images: $hasValidImages');

          // Use full list; allow scrolling when overflowing
          final displayList = profileList;

          return Transform.translate(
            offset: Offset(0, 0), // No upward shift to avoid overlapping app bar
            child: ShimmerScreen(
              enabled: profileList.isEmpty,
              child: GridView.builder(
                shrinkWrap: false,
                padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 12.h, bottom: 16.h), // Add some top padding to move cards down
                physics: const BouncingScrollPhysics(), // Enable scrolling
              itemCount: displayList.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // 2 cards side by side
                childAspectRatio: 0.4, // Card height ratio
                crossAxisSpacing: 8.w, // Horizontal spacing
                mainAxisSpacing: 20.h, // Vertical spacing
              ),
              itemBuilder: (BuildContext context, index) {
                final item = displayList[index];
                if (item == null) {
                  print('UserImageGrid: Item at index $index is null');
                  return SizedBox.shrink();
                }
                
                print('UserImageGrid: Building item at index $index - ID: ${item.id}, photos: ${item.photos}');
                
                final hasValidUrl = item.photos.isNotEmpty &&
                    Uri.tryParse(item.photos.first)?.hasAbsolutePath == true;
                    
                print('UserImageGrid: Item at index $index has valid URL: $hasValidUrl');
                
                // For testing, show all profiles even without valid URLs
                return ProfileCard(item: item);
              },
            ),
            ),
          );
        });
  }
}

//-----------------------Profile Card Widget----------------------------
class ProfileCard extends StatelessWidget {
  final HomeModel item;
  static final UserProfileRepository _userProfileRepository = UserProfileRepository();
  
  const ProfileCard({super.key, required this.item});

  // Helper function to format last active time
  String _formatLastActive(DateTime lastActive) {
    final now = DateTime.now();
    final difference = now.difference(lastActive);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
  
  // Helper function to format created date
  String _formatCreatedDate(DateTime createdDate) {
    final now = DateTime.now();
    final difference = now.difference(createdDate);
    
    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years year${years > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months month${months > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else {
      return 'Today';
    }
  }

  @override
  Widget build(BuildContext context) {
    print('ProfileCard: Building card for user ${item.pseudo}');
    print('ProfileCard: photos list: ${item.photos}');
    print('ProfileCard: photos list length: ${item.photos.length}');
    if (item.photos.isNotEmpty) {
      print('ProfileCard: First photo: ${item.photos.first}');
    }
    
    return InkWell(
      onTap: () async {
        try {
          await _userProfileRepository.markUserAsViewed(item.id);
        } catch (e) {
          print('ProfileCard: Error marking ${item.id} as viewed: $e');
        }
        Get.to(() => UserDetailsScreen(data: item));
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            // Profile Image Section
            Container(
              height: 150.h, // Further reduced to 150.h
              width: double.infinity,
              child: Stack(
                children: [
                  // Profile image with elite border
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      border: item.isElite ? Border.all(
                        color: Color(0xFFFFD700), // Yellow border for elite accounts
                        width: 2.w,
                      ) : null,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16.r),
                        topRight: Radius.circular(16.r),
                      ),
                      color: Colors.grey[300], // Fallback color
                    ),
                    child: item.photos.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(item.isElite ? 14.r : 16.r),
                              topRight: Radius.circular(item.isElite ? 14.r : 16.r),
                            ),
                            child: CachedNetworkImage(
                              imageUrl: item.photos.first,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              placeholder: (context, url) => Container(
                                color: Colors.grey[300],
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                              errorWidget: (context, url, error) {
                                print('ProfileCard: Error loading image: $error');
                                print('ProfileCard: Image URL: $url');
                                return Container(
                                  color: Colors.grey[300],
                                  child: Icon(Icons.person, size: 50.r, color: Colors.grey[600]),
                                );
                              },
                            ),
                          )
                        : Container(
                            color: Colors.grey[300],
                            child: Icon(Icons.person, size: 50.r, color: Colors.grey[600]),
                          ),
                  ),
                  
                  // Gift button overlay
                  Positioned(
                    top: 8.h,
                    left: 8.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: AppColors.red,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        EnumLocale.sendGift.name.tr,
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  
                  // Checkmark badge (only show for elite accounts)
                  if (item.isElite)
                    Positioned(
                      top: 11.h,
                      right: 8.w,
                      child: Container(
                        width: 17.w,
                        height: 13.42.h,
                        padding: EdgeInsets.fromLTRB(3.13.w, 1.34.h, 3.13.w, 1.34.h),
                        decoration: BoxDecoration(
                          color: Color(0xFF3A82F6),
                          borderRadius: BorderRadius.circular(7.12.r),
                        ),
                        child: Icon(
                          Icons.check,
                          color: AppColors.white,
                          size: 10.r,
                        ),
                      ),
                    ),
                  
                  // Name and distance overlay at bottom of image
                  Positioned(
                    bottom: 8.h,
                    left: 8.w,
                    right: 8.w,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${(item.name.isNotEmpty ? item.name : (item.pseudo.isNotEmpty ? item.pseudo : EnumLocale.unknownUser.name.tr))}, ${item.age ?? 0}",
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Roboto-SemiBold',
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.7),
                                offset: Offset(0, 1),
                                blurRadius: 3,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          "${EnumLocale.lastConnection.name.tr}: ${_formatLastActive(item.lastActive)}",
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 9.sp,
                            fontWeight: FontWeight.w400,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.7),
                                offset: Offset(0, 1),
                                blurRadius: 3,
                              ),
                            ],
                          ),
                        ),
                        Text(
                          "${EnumLocale.profileCreated.name.tr}: ${_formatCreatedDate(item.createdDate)}",
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 9.sp,
                            fontWeight: FontWeight.w400,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.7),
                                offset: Offset(0, 1),
                                blurRadius: 3,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 4.h),
                        // Elite account text overlay
                        if (item.isElite)
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: Color(0xFFFFD700).withOpacity(0.9),
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Text(
                              "Compte élite",
                              style: TextStyle(
                                color: AppColors.black,
                                fontSize: 8.sp,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Roboto-SemiBold',
                              ),
                            ),
                          ),
                        SizedBox(height: 4.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Spacer(),
                            FutureBuilder<double?>(
                              future: DistanceCalculator.calculateDistanceToUser(item.city, item.country),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return Text(
                                    '...',
                                    style: TextStyle(
                                      color: AppColors.white,
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.w500,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black.withOpacity(0.7),
                                          offset: Offset(0, 1),
                                          blurRadius: 3,
                                        ),
                                      ],
                                    ),
                                  );
                                }
                                final distance = snapshot.data;
                                return Text(
                                  DistanceCalculator.formatDistance(distance),
                                  style: TextStyle(
                                    color: AppColors.white,
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w500,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black.withOpacity(0.7),
                                        offset: Offset(0, 1),
                                        blurRadius: 3,
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                                    ),
                  
                ],
              ),
            ),
            
            // Action Buttons positioned over the content
            Transform.translate(
              offset: Offset(0, -8.h), // Reduced offset
              child: Container(
                height: 20.h, // Reduced height
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildLikeButton(),
                    SizedBox(width: 6.w),
                    _buildChatButton(context),
                    SizedBox(width: 6.w),
                    _buildFavoriteButton(),
                    SizedBox(width: 6.w),
                    _buildArchiveButton(),
                  ],
                ),
              ),
            ),
            
            // Content Section - Simplified for Activity page
            Container(
              padding: EdgeInsets.fromLTRB(12.w, 6.w, 12.w, 8.w), // Further reduced padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Only show marital status and main interest to reduce height
                  _buildInfoRow(EnumLocale.maritalStatus.name.tr, item.relationshipStatus.isNotEmpty ? item.relationshipStatus : EnumLocale.notSpecified.name.tr),
                  SizedBox(height: 3.h), // Reduced spacing
                  _buildInfoRow(EnumLocale.mainInterest.name.tr, item.mainInterests.isNotEmpty ? item.mainInterests.first : EnumLocale.notSpecified.name.tr),
                ],
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }

  Widget _buildLikeButton() {
    return BlocBuilder<MatchBloc, MatchState>(
      builder: (context, state) {
        final isLiked = state.likedUsers[item.id] ?? false;
        
        return GestureDetector(
          onTap: () {
            // Toggle like/unlike functionality
            if (isLiked) {
              context.read<MatchBloc>().add(UnlikeUser(userId: item.id));
            } else {
              context.read<MatchBloc>().add(LikeUser(userId: item.id));
            }
          },
          child: Container(
            width: 20.w,
            height: 20.h,
            decoration: BoxDecoration(
              color: isLiked ? Colors.red : Colors.white,
              shape: BoxShape.circle,
              border: isLiked ? null : Border.all(color: Colors.grey.shade300, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Icon(
              isLiked ? Icons.favorite : Icons.favorite_outline,
              color: isLiked ? Colors.white : AppColors.primaryColor,
              size: 10.r,
            ),
          ),
        );
      },
    );
  }

  Widget _buildChatButton(BuildContext context) {
    return StreamBuilder(
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
            if (currentUserId != null && p.contains(currentUserId) && p.contains(item.id)) {
              existing = d;
              break;
            }
          }
        }

        final isPending = existing != null && (existing!['isRequest'] == true) && ((existing!['status'] == null) || (existing!['status'] == 'PENDING'));

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isPending)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                child: Text(EnumLocale.chatPending.name.tr, style: TextStyle(fontSize: 12.sp, color: Colors.black87)),
              ),
            GestureDetector(
              onTap: () async {
                try {
                  final chatRepository = ChatRepository();
                  final chatId = await chatRepository.createOrGetChat(
                    item.id,
                    {
                      'id': item.id,
                      'name': item.pseudo,
                      'photoUrl': item.photos.first,
                    },
                  );
                  Get.to(
                    () => RepositoryProvider(
                      create: (context) => ChatRepository(),
                      child: BlocProvider(
                        create: (context) => ChatBloc(ChatRepository()),
                        child: ChatScreen(
                          chatId: chatId,
                          receiverId: item.id,
                          receiverName: item.pseudo,
                          receiverPhotoUrl: item.photos.first,
                        ),
                      ),
                    ),
                  );
                } catch (e) {
                  debugPrint('Error opening chat: $e');
                  if (!context.mounted) return;
                  snackBarMessage(context, EnumLocale.defaultError.name.tr, Theme.of(context));
                }
              },
              child: Container(
                width: 24.w,
                height: 24.h,
                decoration: BoxDecoration(
                  color: Color(0xFFF7BD8E),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.chat_bubble_outline,
                  color: Colors.white,
                  size: 10.r,
                ),
              ),
            ),
            if (isPending)
              SizedBox(width: 6.w),
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
    );
  }

  Widget _buildFavoriteButton() {
    return BlocBuilder<FavoriteBloc, FavoriteState>(
      builder: (context, state) {
        final isFavorited = state.favUserList.any((user) => user.id == item.id);
        
        return GestureDetector(
          onTap: () async {
            // Toggle favorite functionality
            if (isFavorited) {
              context.read<FavoriteBloc>().add(FavoriteUserRemoved(favId: item.id));
            } else {
              context.read<FavoriteBloc>().add(FavoriteUserAdded(favId: item.id));
            }
            
            // Refresh the current tab to update the list
            final currentState = context.read<HomeBloc>().state;
            final currentTabIndex = currentState.selectedTabIndex;
            
            switch (currentTabIndex) {
              case 0: // New
                context.read<HomeBloc>().add(HomeUsersProfileList());
                break;
              case 1: // Liked
                context.read<HomeBloc>().add(FetchLikedUsers());
                break;
              case 2: // Favorites
                context.read<HomeBloc>().add(FetchFavoriteUsers());
                break;
              case 3: // Archive
                context.read<HomeBloc>().add(FetchArchiveUsers());
                break;
              case 4: // All
                context.read<HomeBloc>().add(FetchAllUsers());
                break;
            }
          },
          child: Container(
            width: 20.w,
            height: 20.h,
            decoration: BoxDecoration(
              color: isFavorited ? Colors.amber : Color(0xFFF7BD8E),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Icon(
              isFavorited ? Icons.star : Icons.star_outline,
              color: Colors.white,
              size: 10.r,
            ),
          ),
        );
      },
    );
  }

  Widget _buildArchiveButton() {
    return BlocBuilder<ArchiveBloc, ArchiveState>(
      builder: (context, state) {
        final isArchived = state.archiveUserList.any((user) => user.id == item.id);
        
        return GestureDetector(
          onTap: () async {
            // Toggle archive functionality
            if (isArchived) {
              context.read<ArchiveBloc>().add(ArchiveUserRemoved(archiveId: item.id));
            } else {
              context.read<ArchiveBloc>().add(ArchiveUserAdded(archiveId: item.id));
            }
            
            // Refresh the current tab to update the list
            final currentState = context.read<HomeBloc>().state;
            final currentTabIndex = currentState.selectedTabIndex;
            
            switch (currentTabIndex) {
              case 0: // New
                context.read<HomeBloc>().add(HomeUsersProfileList());
                break;
              case 1: // Liked
                context.read<HomeBloc>().add(FetchLikedUsers());
                break;
              case 2: // Favorites
                context.read<HomeBloc>().add(FetchFavoriteUsers());
                break;
              case 3: // Archive
                context.read<HomeBloc>().add(FetchArchiveUsers());
                break;
              case 4: // Allw
                context.read<HomeBloc>().add(FetchAllUsers());
                break;
            }
          },
          child: Container(
            width: 20.w,
            height: 20.h,
            decoration: BoxDecoration(
              color: isArchived ? Colors.grey : Color(0xFFF7BD8E),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Icon(
              isArchived ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: Colors.white,
              size: 10.r,
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade800,
            fontSize: 10.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 4.h),
        Wrap(
          spacing: 4.w,
          runSpacing: 3.h,
          children: value.split(', ').map((tag) => Container(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h), // Reduced padding
            decoration: BoxDecoration(
              color: AppColors.red,
              borderRadius: BorderRadius.circular(10.r), // Reduced border radius
            ),
            child: Text(
              tag,
              style: TextStyle(
                color: AppColors.white,
                fontSize: 9.sp, // Reduced font size
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis, // Add overflow handling
            ),
          )).toList(),
        ),
      ],
    );
  }
}
