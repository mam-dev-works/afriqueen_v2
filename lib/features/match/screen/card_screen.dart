import 'package:afriqueen/common/constant/constant_colors.dart';
import 'package:afriqueen/common/localization/enums/enums.dart';
import 'package:afriqueen/common/widgets/circular_indicator.dart';
import 'package:afriqueen/features/archive/bloc/archive_bloc.dart';
import 'package:afriqueen/features/archive/bloc/archive_event.dart';
import 'package:afriqueen/features/archive/repository/archive_repository.dart';
import 'package:afriqueen/features/favorite/bloc/favorite_bloc.dart';
import 'package:afriqueen/features/favorite/bloc/favorite_event.dart';
import 'package:afriqueen/features/favorite/repository/favorite_repository.dart';
import 'package:afriqueen/features/home/model/home_model.dart';
import 'package:afriqueen/features/match/bloc/match_bloc.dart';
import 'package:afriqueen/features/match/bloc/match_event.dart';
import 'package:afriqueen/features/match/bloc/match_state.dart';
import 'package:afriqueen/features/match/repository/like_repository.dart';
import 'package:afriqueen/features/match/widget/card_screen_widget.dart';
import 'package:afriqueen/features/user_details/screen/user_details_screen.dart';
import 'package:afriqueen/features/activity/repository/user_profile_repository.dart';
import 'package:afriqueen/services/distance/distance_calculator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CardScreen extends StatefulWidget {
  const CardScreen({super.key});

  @override
  State<CardScreen> createState() => _CardScreenState();
}

class _CardScreenState extends State<CardScreen> {
  int currentCardIndex = 0;
  bool hasCheckedInitialLike = false;
  bool hasInitialized = false;
  
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
  void initState() {
    super.initState();
    // Reset flags when screen is initialized
    hasInitialized = false;
    hasCheckedInitialLike = false;
    currentCardIndex = 0;
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reset initialization flags when dependencies change (screen is entered)
    hasInitialized = false;
    hasCheckedInitialLike = false;
    currentCardIndex = 0;
  }
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ArchiveBloc(
            repository: ArchiveRepository(),
          ),
        ),
        BlocProvider(
          create: (context) => FavoriteBloc(
            repository: FavoriteRepository(),
          ),
        ),
        BlocProvider(
          create: (context) => MatchBloc(),
        ),
      ],
      child: BlocBuilder<MatchBloc, MatchState>(
                 builder: (context, state) {
           // Refresh data every time the screen is entered
           if (!hasInitialized) {
             WidgetsBinding.instance.addPostFrameCallback((_) {
               context.read<MatchBloc>().add(MatchUsersFetched());
             });
             hasInitialized = true;
           }
          
          // Reset currentCardIndex if it's out of bounds
          if (state.data.isNotEmpty && currentCardIndex >= state.data.length) {
            currentCardIndex = 0;
          }
          
          // Check like status for the first card on initial load
          if (!hasCheckedInitialLike && state.data.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.read<MatchBloc>().add(CheckLikeStatus(userId: state.data[0]!.id));
            });
            hasCheckedInitialLike = true;
          }
          
          return Scaffold(
            backgroundColor: Color(0xFFFDFDFD),
            body: Builder(
              builder: (context) {
                try {
                  return switch (state) {
                    Loading() => const CustomCircularIndicator(),
                    Error() => Center(
                        child: Text(
                          state.error,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    MatchDataEmpty() => Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inbox_outlined,
                              size: 64.sp,
                              color: Color(0xFFF7BD8E),
                            ),
                            SizedBox(height: 24.h),
                            Text(
                              EnumLocale.noDataAvailable.name.tr,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    _ => state.data.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.inbox_outlined,
                                  size: 64.sp,
                                  color: Color(0xFFF7BD8E),
                                ),
                                SizedBox(height: 24.h),
                                Text(
                                  EnumLocale.noDataAvailable.name.tr,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          )
                        : Column(
                        children: [
                          // Card Swiper - no top spacing
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(left: 8.w, right: 8.w, top: 0.h), // No top padding
                              child: Row(
                                children: [
                                                                     // Card Swiper
                                   Expanded(
                                     child: state.data.isNotEmpty
                                         ? SizedBox(
                                             height: 420.h, // Reduced from 460 to 420
                                             child: CardSwiper(
                                        duration: Duration(milliseconds: 100),
                                        numberOfCardsDisplayed: state.data.length > 1 ? 2 : 1,
                                        padding: EdgeInsets.only(left: 5.w, right: 5.w, top: 0.h, bottom: 0.h), // No vertical padding
                                        cardBuilder: (
                                          context,
                                          index,
                                          horizontalThresholdPercentage,
                                          verticalThresholdPercentage,
                                        ) {
                                          if (index >= state.data.length) {
                                            return SizedBox.shrink();
                                          }
                                          final item = state.data[index];
                                          if (item == null) {
                                            return SizedBox.shrink();
                                          }
                                          return _buildCompactProfileCard(context, item);
                                        },
                                        onSwipe: (previousIndex, currentIndex, direction) {
                                          // Update current card index and check like status
                                          if (currentIndex != null && currentIndex < state.data.length) {
                                            setState(() {
                                              currentCardIndex = currentIndex;
                                            });
                                            final currentUser = state.data[currentIndex];
                                            if (currentUser != null) {
                                              context.read<MatchBloc>().add(CheckLikeStatus(userId: currentUser.id));
                                            }
                                          }
                                          return true;
                                        },
                                        cardsCount: state.data.length,
                                      ),
                                    )
                                    : Center(
                                        child: Text(
                                          EnumLocale.noDataFound.name.tr,
                                          style: Theme.of(context).textTheme.bodyMedium,
                                        ),
                                      ),
                                  ),
                                  SizedBox(width: 16.w),
                                  // Action Buttons
                                  state.data.isNotEmpty && currentCardIndex < state.data.length
                                      ? _buildActionButtons(context, state.data[currentCardIndex]!)
                                      : SizedBox.shrink(),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                  };
                } catch (e) {
                  // Catch any "Bad state: No element" or other errors
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inbox_outlined,
                          size: 64.sp,
                          color: Color(0xFFF7BD8E),
                        ),
                        SizedBox(height: 24.h),
                        Text(
                          EnumLocale.noDataAvailable.name.tr,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.h), // No vertical padding
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Only Title, no icons
          Text(
            EnumLocale.match.name.tr,
            style: TextStyle(
              color: AppColors.black,
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              fontFamily: 'Roboto-SemiBold',
            ),
          ),
        ],
      ),
    );
  }

       Widget _buildCompactProfileCard(BuildContext context, HomeModel user) {
    final validUrl = user.photos.isNotEmpty &&
        user.photos.first.isNotEmpty &&
        Uri.tryParse(user.photos.first)?.hasAbsolutePath == true;
    final UserProfileRepository _userProfileRepository = UserProfileRepository();

     return Container(
       height: 400.h, // Reduced height from 440 to 400
       decoration: BoxDecoration(
         borderRadius: BorderRadius.circular(16.r),
         color: Color(0xFFFDFDFD),
       ),
       child: ClipRRect(
         borderRadius: BorderRadius.circular(16.r),
         child: Column(
           children: [
                         // Profile Image Section
            InkWell(
              onTap: () async {
                try {
                  await _userProfileRepository.markUserAsViewed(user.id);
                } catch (e) {
                  print('CardScreen: Error marking ${user.id} as viewed: $e');
                }
                Get.to(() => UserDetailsScreen(data: user));
              },
              child: Container(
                height: 250.h, // Reduced from 280 to 250
               width: double.infinity,
               child: Stack(
                 children: [
                   // Profile image with elite border
                   Container(
                     width: double.infinity,
                     height: double.infinity,
                     decoration: BoxDecoration(
                       border: user.isElite ? Border.all(
                         color: Color(0xFFFFD700), // Yellow border for elite accounts
                         width: 3.w,
                       ) : null,
                       borderRadius: BorderRadius.circular(16.r),
                     ),
                     child: ClipRRect(
                       borderRadius: BorderRadius.circular(user.isElite ? 13.r : 16.r),
                       child: Container(
                         width: double.infinity,
                         height: double.infinity,
                         decoration: validUrl
                             ? BoxDecoration(
                                 image: DecorationImage(
                                   fit: BoxFit.cover,
                                   image: CachedNetworkImageProvider(user.photos.first),
                                 ),
                               )
                             : BoxDecoration(
                                 color: Colors.grey[300],
                               ),
                         child: validUrl
                             ? null
                             : Center(
                                 child: Icon(
                                   Icons.person,
                                   size: 80.r,
                                   color: Colors.grey[600],
                                 ),
                               ),
                       ),
                     ),
                   ),
                   // Verified Badge (only show for elite accounts)
                   if (user.isElite)
                     Positioned(
                       top: 12.h,
                       right: 12.w,
                       child: Container(
                         width: 20.w,
                         height: 20.h,
                         decoration: BoxDecoration(
                           color: Color(0xFF3A82F6),
                           shape: BoxShape.circle,
                         ),
                         child: Icon(
                           Icons.check,
                           color: AppColors.white,
                           size: 14.r,
                         ),
                       ),
                     ),
                   // User Info Overlay
                   Positioned(
                     bottom: 12.h,
                     left: 12.w,
                     right: 12.w,
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Text(
                           "${(user.name.isNotEmpty ? user.name : (user.pseudo.isNotEmpty ? user.pseudo : EnumLocale.unknownUser.name.tr))}, ${user.age ?? 0}",
                           style: TextStyle(
                             color: AppColors.white,
                             fontSize: 16.sp,
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
                           "${EnumLocale.lastConnection.name.tr}: ${_formatLastActive(user.lastActive)}",
                           style: TextStyle(
                             color: AppColors.white,
                             fontSize: 10.sp,
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
                           "${EnumLocale.profileCreated.name.tr}: ${_formatCreatedDate(user.createdDate)}",
                           style: TextStyle(
                             color: AppColors.white,
                             fontSize: 10.sp,
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
                         if (user.isElite)
                           Container(
                             padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                             decoration: BoxDecoration(
                               color: Color(0xFFFFD700).withOpacity(0.9),
                               borderRadius: BorderRadius.circular(4.r),
                             ),
                             child: Text(
                               "Compte élite",
                               style: TextStyle(
                                 color: AppColors.black,
                                 fontSize: 10.sp,
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
                               future: DistanceCalculator.calculateDistanceToUser(user.city, user.country),
                               builder: (context, snapshot) {
                                 if (snapshot.connectionState == ConnectionState.waiting) {
                                   return Text(
                                     '...',
                                     style: TextStyle(
                                       color: AppColors.white,
                                       fontSize: 12.sp,
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
                                     fontSize: 12.sp,
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
             ),
             // Profile Details Section
             Expanded(
                                child: Container(
                   padding: EdgeInsets.only(left: 10.w, right: 10.w, top: 10.w, bottom: 0),
                   decoration: BoxDecoration(
                     color: Color(0xFFFDFDFD),
                   ),
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.stretch,
                   children: [
                     _buildCompactDetailRow(
                       EnumLocale.sexualOrientation.name.tr,
                       user.orientation.isNotEmpty ? user.orientation : EnumLocale.notSpecified.name.tr,
                     ),
                     SizedBox(height: 3.h), // Reduced spacing
                     _buildCompactDetailRow(
                       EnumLocale.maritalStatus.name.tr,
                       user.relationshipStatus.isNotEmpty ? user.relationshipStatus : EnumLocale.notSpecified.name.tr,
                     ),
                     SizedBox(height: 3.h), // Reduced spacing
                     _buildCompactDetailRow(
                       EnumLocale.mainInterest.name.tr,
                       user.mainInterests.isNotEmpty ? user.mainInterests.first : EnumLocale.notSpecified.name.tr,
                     ),
                     SizedBox(height: 3.h), // Reduced spacing
                     _buildCompactDetailRow(
                       EnumLocale.passions.name.tr,
                       user.passions.isNotEmpty ? user.passions.take(2).join(", ") : EnumLocale.notSpecified.name.tr,
                     ),
                   ],
                 ),
               ),
             ),
           ],
         ),
       ),
     );
   }

   Widget _buildProfileCard(BuildContext context, HomeModel user) {
    final validUrl = user.photos.isNotEmpty &&
        user.photos.first.isNotEmpty &&
        Uri.tryParse(user.photos.first)?.hasAbsolutePath == true;

    return Container(
      height: 450.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: Stack(
          children: [
            // Profile Image with elite border
            Container(
              width: double.infinity,
              height: 300.h,
              decoration: BoxDecoration(
                border: user.isElite ? Border.all(
                  color: Color(0xFFFFD700), // Yellow border for elite accounts
                  width: 3.w,
                ) : null,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(user.isElite ? 13.r : 16.r),
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: validUrl
                      ? BoxDecoration(
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: CachedNetworkImageProvider(user.photos.first),
                          ),
                        )
                      : BoxDecoration(
                          color: Colors.grey[300],
                        ),
                  child: validUrl
                      ? null
                      : Center(
                          child: Icon(
                            Icons.person,
                            size: 100.r,
                            color: Colors.grey[600],
                          ),
                        ),
                ),
              ),
            ),
            // Verified Badge (only show for elite accounts)
            if (user.isElite)
              Positioned(
                top: 16.h,
                right: 16.w,
                child: Container(
                  width: 24.w,
                  height: 24.h,
                  decoration: BoxDecoration(
                    color: Color(0xFF3A82F6),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check,
                    color: AppColors.white,
                    size: 16.r,
                  ),
                ),
              ),
            // User Info Overlay
            Positioned(
              bottom: 16.h,
              left: 16.w,
              right: 16.w,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${(user.name.isNotEmpty ? user.name : (user.pseudo.isNotEmpty ? user.pseudo : EnumLocale.unknownUser.name.tr))}, ${user.age ?? 0}",
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 20.sp,
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
                  SizedBox(height: 4.h),
                  Text(
                    EnumLocale.lastConnection.name.tr,
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 12.sp,
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
                    EnumLocale.profileCreated.name.tr,
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 12.sp,
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
                  SizedBox(height: 8.h),
                  // Elite account text overlay
                  if (user.isElite)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: Color(0xFFFFD700).withOpacity(0.9),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        "Compte élite",
                        style: TextStyle(
                          color: AppColors.black,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Roboto-SemiBold',
                        ),
                      ),
                    ),
                  SizedBox(height: 8.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Spacer(),
                      FutureBuilder<double?>(
                        future: DistanceCalculator.calculateDistanceToUser(user.city, user.country),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Text(
                              '...',
                              style: TextStyle(
                                color: AppColors.white,
                                fontSize: 14.sp,
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
                              fontSize: 14.sp,
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
    );
  }

  Widget _buildActionButtons(BuildContext context, HomeModel user) {
    return BlocBuilder<MatchBloc, MatchState>(
      builder: (context, state) {
        final isLiked = state.likedUsers[user.id] ?? false;
        
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildActionButton(
              icon: isLiked ? Icons.favorite : Icons.favorite_outline,
              color: isLiked ? Colors.red : Color(0xFFF7BD8E),
              onTap: () {
                // Toggle like/unlike functionality
                if (isLiked) {
                  context.read<MatchBloc>().add(UnlikeUser(userId: user.id));
                } else {
                  context.read<MatchBloc>().add(LikeUser(userId: user.id));
                }
              },
            ),
        SizedBox(height: 8.h),
        _buildActionButton(
          icon: Icons.chat_bubble_outline,
          color: Color(0xFFF7BD8E),
          onTap: () {
            // Message functionality
            Get.toNamed('/chat', arguments: user);
          },
        ),
        SizedBox(height: 8.h),
        _buildActionButton(
          icon: Icons.keyboard_arrow_down,
          color: Color(0xFFF7BD8E),
          onTap: () {
            // Archive functionality
            context.read<ArchiveBloc>().add(ArchiveUserAdded(archiveId: user.id));
            // Remove user from match list
            context.read<MatchBloc>().add(RemoveUserFromMatch(userId: user.id));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(EnumLocale.savedToArchives.name.tr),
                backgroundColor: Colors.green,
              ),
            );
          },
        ),
        SizedBox(height: 8.h),
        _buildActionButton(
          icon: Icons.star_outline,
          color: Color(0xFFF7BD8E),
          onTap: () {
            // Favorite functionality
            context.read<FavoriteBloc>().add(FavoriteUserAdded(favId: user.id));
            // Remove user from match list
            context.read<MatchBloc>().add(RemoveUserFromMatch(userId: user.id));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(EnumLocale.savedToFavorites.name.tr),
                backgroundColor: Colors.green,
              ),
            );
          },
        ),
      ],
    );
      },
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36.w,
        height: 36.h,
        decoration: BoxDecoration(
          color: color == Color(0xFFF7BD8E) ? color : Colors.white,
          shape: BoxShape.circle,
          border: color == Color(0xFFF7BD8E) ? null : Border.all(color: Colors.grey.shade300, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: color == Color(0xFFF7BD8E) ? Colors.white : (icon == Icons.favorite ? Colors.red : Colors.black),
          size: 18.r,
        ),
             ),
     );
   }

   Widget _buildProfileDetails(BuildContext context, HomeModel user) {
     return Container(
       padding: EdgeInsets.all(16.w),
       decoration: BoxDecoration(
         color: AppColors.white,
         borderRadius: BorderRadius.circular(12.r),
         boxShadow: [
           BoxShadow(
             color: Colors.black.withOpacity(0.05),
             blurRadius: 4,
             offset: Offset(0, 2),
           ),
         ],
       ),
       child: Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
           _buildDetailRow(
             EnumLocale.sexualOrientation.name.tr,
             user.orientation.isNotEmpty ? user.orientation : EnumLocale.notSpecified.name.tr,
           ),
           SizedBox(height: 12.h),
           _buildDetailRow(
             EnumLocale.maritalStatus.name.tr,
             user.relationshipStatus.isNotEmpty ? user.relationshipStatus : EnumLocale.notSpecified.name.tr,
           ),
           SizedBox(height: 12.h),
           _buildDetailRow(
             EnumLocale.mainInterest.name.tr,
             user.mainInterests.isNotEmpty ? user.mainInterests.first : EnumLocale.notSpecified.name.tr,
           ),
           SizedBox(height: 12.h),
           _buildDetailRow(
             EnumLocale.passions.name.tr,
             user.passions.isNotEmpty ? user.passions.take(2).join(", ") : EnumLocale.notSpecified.name.tr,
           ),
         ],
       ),
     );
   }

   Widget _buildCompactDetailRow(String label, String value) {
     return Container(
       width: double.infinity,
       child: Column(
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
           SizedBox(height: 3.h),
           Wrap(
             spacing: 3.w,
             runSpacing: 2.h,
             children: value.split(', ').map((tag) => Container(
               padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
               decoration: BoxDecoration(
                 color: AppColors.red,
                 borderRadius: BorderRadius.circular(12.r),
               ),
               child: Text(
                 tag,
                 style: TextStyle(
                   color: AppColors.white,
                   fontSize: 9.sp,
                   fontWeight: FontWeight.w500,
                 ),
               ),
             )).toList(),
           ),
         ],
       ),
     );
   }

   Widget _buildDetailRow(String label, String value) {
     return Column(
       crossAxisAlignment: CrossAxisAlignment.start,
       children: [
         Text(
           label,
           style: TextStyle(
             color: Colors.grey.shade800,
             fontSize: 12.sp,
             fontWeight: FontWeight.w600,
           ),
         ),
         SizedBox(height: 6.h),
         Wrap(
           spacing: 6.w,
           runSpacing: 4.h,
           children: value.split(', ').map((tag) => Container(
             padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
             decoration: BoxDecoration(
               color: AppColors.red,
               borderRadius: BorderRadius.circular(16.r),
             ),
             child: Text(
               tag,
               style: TextStyle(
                 color: AppColors.white,
                 fontSize: 11.sp,
                 fontWeight: FontWeight.w500,
               ),
             ),
           )).toList(),
         ),
       ],
     );
   }
}
