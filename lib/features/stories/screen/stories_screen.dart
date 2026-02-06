import 'package:afriqueen/common/constant/constant_colors.dart';
import 'package:afriqueen/common/localization/enums/enums.dart';
import 'package:afriqueen/common/widgets/shimmer_effect.dart';
import 'package:afriqueen/features/stories/bloc/stories_bloc.dart';
import 'package:afriqueen/features/stories/bloc/stories_event.dart';
import 'package:afriqueen/features/stories/bloc/stories_state.dart';
import 'package:afriqueen/features/stories/model/stories_model.dart';
import 'package:afriqueen/features/stories/repository/stories_repository.dart';
import 'package:afriqueen/features/profile/repository/profile_repository.dart';
import 'package:afriqueen/features/profile/model/profile_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:afriqueen/routes/app_routes.dart';

class StoriesScreen extends StatefulWidget {
  const StoriesScreen({super.key});

  @override
  State<StoriesScreen> createState() => _StoriesScreenState();
}

class _StoriesScreenState extends State<StoriesScreen> {
  int selectedTabIndex = 0;
  int currentStoryIndex = 0; // Current story index
  final ProfileRepository _profileRepository = ProfileRepository();
  final Map<String, ProfileModel?> _userDataCache = {};
  bool hasCheckedInitialLike = false;

  // Dummy user id lists for demonstration
  final List<String> favoriteUserIds = ['favUser1', 'favUser2'];
  final List<String> archivedUserIds = ['archUser1', 'archUser2'];
  final List<String> likedStoryIds = ['likedStory1', 'likedStory2'];

  // Helper function to format last active time
  String _formatLastActive(DateTime lastActive) {
    final now = DateTime.now();
    final difference = now.difference(lastActive);
    
    if (difference.inDays > 0) {
      return '${EnumLocale.derniereConnexion.name.tr} ${difference.inDays}${EnumLocale.derniereConnexionJ.name.tr}';
    } else if (difference.inHours > 0) {
      return '${EnumLocale.derniereConnexion.name.tr} ${difference.inHours}${EnumLocale.derniereConnexionH.name.tr}';
    } else if (difference.inMinutes > 0) {
      return '${EnumLocale.derniereConnexion.name.tr} ${difference.inMinutes}${EnumLocale.derniereConnexionM.name.tr}';
    } else {
      return EnumLocale.derniereConnexionInstant.name.tr;
    }
  }

  void _onTabSelected(int index) {
    setState(() {
      selectedTabIndex = index;
      currentStoryIndex = 0; // Reset story index when tab changes
    });
    
    // Liké tab'ına geçildiğinde liked stories'leri fetch et
    if (index == 3) {
      context.read<StoriesBloc>().add(StoriesFetchLikedStories());
    }
  }

  void _onNextStory(List<StoriesFetchModel> stories) {
    if (stories.isNotEmpty) {
      setState(() {
        currentStoryIndex = (currentStoryIndex + 1) % stories.length;
      });
    }
  }

  void _onPreviousStory(List<StoriesFetchModel> stories) {
    if (stories.isNotEmpty) {
      setState(() {
        currentStoryIndex = (currentStoryIndex - 1 + stories.length) % stories.length;
      });
    }
  }

  List<StoriesFetchModel> getFilteredStories(
      List<StoriesFetchModel> allStories, List<StoriesFetchModel> likedStoriesList) {
    switch (selectedTabIndex) {
      case 1: // Favori
        return allStories
            .where((story) => favoriteUserIds.contains(story.id))
            .toList();
      case 2: // Archive
        return allStories
            .where((story) => archivedUserIds.contains(story.id))
            .toList();
      case 3: // Liké
        return likedStoriesList; // Gerçek liked stories listesi
      default: // Nouveau, Tous
        return allStories;
    }
  }

  Future<ProfileModel?> _fetchUserData(String userId) async {
    if (_userDataCache.containsKey(userId)) {
      return _userDataCache[userId];
    }

    try {
      final userData = await _profileRepository.fetchUserDataById(userId);
      _userDataCache[userId] = userData;
      return userData;
    } catch (e) {
      debugPrint('Error fetching user data for $userId: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.white,
        body: MultiRepositoryProvider(
          providers: [
            RepositoryProvider(create: (context) => StoriesRepository()),
          ],
          child: BlocProvider(
            create: (context) =>
                StoriesBloc(repo: context.read<StoriesRepository>())
                  ..add(StoriesFetching()),
            child: MultiBlocListener(
              listeners: [
                BlocListener<StoriesBloc, StoriesState>(
                  listener: (context, state) {
                                      if (state is StoriesCreateSuccess) {
                    Get.snackbar(
                      EnumLocale.updateSuccessMessage.name.tr,
                      EnumLocale.storyAdded.name.tr,
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.green,
                      colorText: Colors.white,
                      duration: Duration(seconds: 2),
                    );
                  }
                  },
                ),
              ],
              child: BlocSelector<StoriesBloc, StoriesState,
                  Map<String, dynamic>>(
                selector: (state) => {
                  'data': state.data,
                  'likedStoriesList': state.likedStoriesList,
                  'likedStories': state.likedStories,
                },
                builder: (context, dataMap) {
                  final String currentUserId =
                      FirebaseAuth.instance.currentUser!.uid;
                  debugPrint("StoriesScreen - Current user ID: $currentUserId");

                  final allStories = dataMap['data'] as List<StoriesFetchModel>;
                  final likedStoriesList = dataMap['likedStoriesList'] as List<StoriesFetchModel>;
                  final likedStories = dataMap['likedStories'] as Map<String, bool>;

                  // Filter out current user's story and get other users' stories
                  final filteredStories = getFilteredStories(allStories, likedStoriesList)
                      .where((story) => story.id != currentUserId)
                      .toList();
                  
                  debugPrint("StoriesScreen - Other users' stories count: ${filteredStories.length}");

                  // Get current story
                  final currentStory = filteredStories.isNotEmpty && currentStoryIndex < filteredStories.length
                      ? filteredStories[currentStoryIndex]
                      : null;

                  // Check like status for all stories on initial load
                  if (!hasCheckedInitialLike && filteredStories.isNotEmpty) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      print('=== CHECKING LIKE STATUS FOR ALL STORIES ===');
                      for (final story in filteredStories) {
                        if (story.documentId != null) {
                          print('Checking like status for story: ${story.documentId}');
                          context.read<StoriesBloc>().add(
                            StoriesCheckLikeStatus(storyId: story.documentId!)
                          );
                        } else {
                          print('Story has no documentId: ${story.id}');
                        }
                      }
                      print('=== END CHECKING LIKE STATUS ===');
                    });
                    hasCheckedInitialLike = true;
                  }

                  // Liké tab'ına geçildiğinde liked stories'leri fetch et
                  if (selectedTabIndex == 3) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      context.read<StoriesBloc>().add(StoriesFetchLikedStories());
                    });
                  }

                  return CustomScrollView(
                    slivers: [
                      // App Bar
                      SliverAppBar(
                        backgroundColor: AppColors.white,
                        elevation: 0,
                        centerTitle: false,
                        title: Padding(
                          padding: EdgeInsets.only(left: 42.w),
                          child: Text(
                            _getTitleForTab(selectedTabIndex),
                            style: TextStyle(
                              color: AppColors.black,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Roboto-SemiBold',
                            ),
                          ),
                        ),
                        actions: [
                          Container(
                            margin: EdgeInsets.only(right: 8.w),
                            child: ElevatedButton(
                              onPressed: () {
                                _onMaStoryPressed(allStories);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFFF7BD8E),
                                foregroundColor: AppColors.white,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12.w, vertical: 6.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16.r),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                EnumLocale.maStory.name.tr,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              // Filter butonu
                            },
                            icon: Icon(
                              Icons.tune_outlined,
                              size: 24.r,
                              color: AppColors.black,
                            ),
                          ),
                        ],
                        leading: IconButton(
                          onPressed: () => Get.toNamed(AppRoutes.profileHome),
                          icon: Icon(
                            Icons.home_outlined,
                            size: 24.r,
                            color: AppColors.black,
                          ),
                        ),
                      ),
                      // Navigation Tabs
                      SliverToBoxAdapter(
                        child: Container(
                          height: 35.h,
                          padding: EdgeInsets.symmetric(horizontal: 18.w),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildTab(
                                  context, EnumLocale.nouveau.name.tr, 0, selectedTabIndex == 0),
                              _buildTab(
                                  context, EnumLocale.favori.name.tr, 1, selectedTabIndex == 1),
                              _buildTab(
                                  context, EnumLocale.archive.name.tr, 2, selectedTabIndex == 2),
                              _buildTab(
                                  context, EnumLocale.like.name.tr, 3, selectedTabIndex == 3),
                              _buildTab(
                                  context, EnumLocale.tous.name.tr, 4, selectedTabIndex == 4),
                            ],
                          ),
                        ),
                      ),
                      // Stories Content
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.all(16.w),
                          child: filteredStories.isNotEmpty
                              ? Column(
                                  children: [
                                    // Profile Card with Animation
                                    AnimatedSwitcher(
                                      duration: Duration(milliseconds: 300),
                                      transitionBuilder: (Widget child, Animation<double> animation) {
                                        return SlideTransition(
                                          position: Tween<Offset>(
                                            begin: Offset(1.0, 0.0),
                                            end: Offset.zero,
                                          ).animate(CurvedAnimation(
                                            parent: animation,
                                            curve: Curves.easeInOut,
                                          )),
                                          child: child,
                                        );
                                      },
                                      child: _buildProfileCard(currentStory),
                                      key: ValueKey(currentStory?.documentId ?? currentStoryIndex),
                                    ),
                                    SizedBox(height: 16.h),
                                    // Main Content Area with Gesture Detection
                                    GestureDetector(
                                      onTapUp: (details) {
                                        final screenWidth = MediaQuery.of(context).size.width;
                                        final tapX = details.globalPosition.dx;
                                        
                                        if (tapX < screenWidth * 0.3) {
                                          // Left side - previous story
                                          _onPreviousStory(filteredStories);
                                        } else if (tapX > screenWidth * 0.7) {
                                          // Right side - next story
                                          _onNextStory(filteredStories);
                                        }
                                      },
                                      child: AnimatedSwitcher(
                                        duration: Duration(milliseconds: 300),
                                        transitionBuilder: (Widget child, Animation<double> animation) {
                                          return SlideTransition(
                                            position: Tween<Offset>(
                                              begin: Offset(1.0, 0.0),
                                              end: Offset.zero,
                                            ).animate(CurvedAnimation(
                                              parent: animation,
                                              curve: Curves.easeInOut,
                                            )),
                                            child: child,
                                          );
                                        },
                                        child: _buildMainContent(currentStory, filteredStories),
                                        key: ValueKey(currentStory?.documentId ?? currentStoryIndex),
                                      ),
                                    ),
                                  ],
                                )
                              : _buildNoDataFound(),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ));
  }

  Widget _buildTab(
      BuildContext context, String text, int index, bool isSelected) {
    return GestureDetector(
      onTap: () {
        _onTabSelected(index);
      },
      child: Container(
        width: (MediaQuery.of(context).size.width - 36.w - 40.w) / 5,
        height: 30.h,
        margin: EdgeInsets.symmetric(horizontal: 4.w),
        padding: EdgeInsets.all(6.w),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFFF7BD8E) : Colors.transparent,
          borderRadius: BorderRadius.circular(13.r),
          border: Border.all(
            color: isSelected ? Color(0xFFF7BD8E) : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: AppColors.black,
              fontSize: 9.sp,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              fontFamily: 'Roboto-SemiBold',
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard(StoriesFetchModel? story) {
    return FutureBuilder<ProfileModel?>(
      future: story != null ? _fetchUserData(story.id) : Future.value(null),
      builder: (context, snapshot) {
        final userData = snapshot.data;
        
        return Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Profile Picture
              Container(
                width: 60.w,
                height: 60.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.red,
                    width: 2,
                  ),
                ),
                child: CircleAvatar(
                  backgroundImage: userData?.imgURL.isNotEmpty == true
                      ? NetworkImage(userData!.imgURL)
                      : story?.userImg.isNotEmpty == true
                          ? NetworkImage(story!.userImg)
                          : null,
                  child: (userData?.imgURL.isEmpty != false && 
                          story?.userImg.isEmpty != false)
                      ? Icon(Icons.person, size: 30.r, color: Colors.grey)
                      : null,
                ),
              ),
              SizedBox(width: 12.w),
              // Profile Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          userData != null
                              ? '${(userData!.pseudo.isNotEmpty ? userData!.pseudo : EnumLocale.unknownUser.name.tr)}${userData!.age > 0 ? ', ${userData!.age}' : ''}'
                              : (story?.userName.isNotEmpty == true
                                  ? story!.userName
                                  : EnumLocale.utilisateur.name.tr),
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.black,
                          ),
                        ),
                        Spacer(),
                        Text(
                          '2.5 ${EnumLocale.km.name.tr}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      userData?.lastActive != null 
                          ? _formatLastActive(userData!.lastActive!)
                          : EnumLocale.derniereConnexionInconnue.name.tr,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      userData?.description.isNotEmpty == true
                          ? userData!.description
                          : EnumLocale.chercheRelationSerieuse.name.tr,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMainContent(StoriesFetchModel? story, List<StoriesFetchModel> filteredStories) {
    return Column(
      children: [
        // Main Image Container
        Container(
          height: 300.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Main Image
              Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  image: (story?.imageUrl != null && story!.imageUrl!.isNotEmpty) || story?.containUrl.isNotEmpty == true
                      ? DecorationImage(
                          image: NetworkImage(story!.imageUrl ?? story.containUrl.first),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: ((story?.imageUrl == null || story!.imageUrl!.isEmpty) && story?.containUrl.isEmpty != false)
                    ? Container(
                        color: Colors.grey.shade300,
                        child: Icon(
                          Icons.image,
                          size: 50.r,
                          color: Colors.grey,
                        ),
                      )
                    : null,
              ),

              // Action Buttons (Right Side - Vertical)
              Positioned(
                right: 16.w,
                bottom: 16.h,
                child: Column(
                  children: [
                    _buildActionButton(Icons.play_arrow, () {
                      _onNextStory(filteredStories);
                    }),
                    SizedBox(height: 12.h),
                    BlocBuilder<StoriesBloc, StoriesState>(
                      builder: (context, state) {
                        final isLiked = story?.documentId != null && 
                            state.likedStories[story!.documentId!] == true;
                        
                        debugPrint('=== LIKE BUTTON DEBUG ===');
                        debugPrint('Story documentId: ${story?.documentId}');
                        debugPrint('Story ID: ${story?.id}');
                        debugPrint('Is story liked: $isLiked');
                        debugPrint('Liked stories in state: ${state.likedStories}');
                        debugPrint('Current story in likedStories: ${state.likedStories[story?.documentId]}');
                        debugPrint('=== END LIKE BUTTON DEBUG ===');
                        
                        return _buildActionButton(
                          isLiked ? Icons.favorite : Icons.favorite_border,
                          () {
                            if (story != null && story.documentId != null) {
                              context.read<StoriesBloc>().add(
                                StoriesLikeToggle(storyId: story.documentId!)
                              );
                            }
                          },
                          iconColor: isLiked ? Colors.red : null,
                        );
                      },
                    ),
                    SizedBox(height: 12.h),
                    _buildActionButton(Icons.chat_bubble_outline, () {}),
                    SizedBox(height: 12.h),
                    _buildActionButton(Icons.flag_outlined, () {}),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        // Text Description (Below Photo with White Background)
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(12.r),
              bottomRight: Radius.circular(12.r),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Text(
            story?.text != null && story!.text!.isNotEmpty
                ? story.text!
                : EnumLocale.femmeAfricaineCurieuse.name.tr,
            style: TextStyle(
              color: AppColors.black,
              fontSize: 14.sp,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(IconData icon, VoidCallback onTap, {Color? iconColor}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40.w,
        height: 40.w,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          size: 20.r,
          color: iconColor ?? AppColors.black,
        ),
      ),
    );
  }

  Widget _buildStoryCounter(int current, int total) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        '$current / $total',
        style: TextStyle(
          color: Colors.white,
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildNoDataFound() {
    return Container(
      height: 300.h,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.photo_library_outlined,
              size: 80.r,
              color: Colors.grey.shade400,
            ),
            SizedBox(height: 16.h),
            Text(
              EnumLocale.aucuneStoryTrouvee.name.tr,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              EnumLocale.aucuneStoryDisponible.name.tr,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _getTitleForTab(int index) {
    switch (index) {
      case 0:
        return EnumLocale.storyNouveau.name.tr;
      case 1:
        return EnumLocale.storyFavori.name.tr;
      case 2:
        return EnumLocale.storyArchive.name.tr;
      case 3:
        return EnumLocale.storyLike.name.tr;
      default:
        return EnumLocale.storyTous.name.tr;
    }
  }

  void _onMaStoryPressed(List<StoriesFetchModel> data) {
    final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
    final int currentUserIndexInData =
        data.indexWhere((story) => story.id == currentUserId);

    if (currentUserIndexInData != -1) {
      // User has a story, navigate to MyStoryScreen
      Get.toNamed('/my-story');
    } else {
      // User does not have a story, navigate to CreateStoryScreen
      Get.toNamed('/create-story');
    }
  }
}
