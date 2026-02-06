import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:afriqueen/routes/app_routes.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:afriqueen/common/localization/enums/enums.dart';
import 'package:afriqueen/common/theme/app_colors.dart';
import 'package:afriqueen/features/event/screen/create_event_screen.dart';
import 'package:afriqueen/features/event/repository/event_repository.dart';
import 'package:afriqueen/features/event/model/event_model.dart';
import 'package:afriqueen/features/event/repository/event_request_repository.dart';
import 'package:afriqueen/features/event/model/event_request_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:afriqueen/features/home/widget/data_fetched_screen_widgets.dart';
import 'package:afriqueen/features/home/model/home_model.dart';
import 'package:afriqueen/features/match/bloc/match_bloc.dart';
import 'package:afriqueen/features/favorite/bloc/favorite_bloc.dart';
import 'package:afriqueen/features/favorite/repository/favorite_repository.dart';
import 'package:afriqueen/features/archive/bloc/archive_bloc.dart';
import 'package:afriqueen/features/archive/repository/archive_repository.dart';
import '../bloc/user_profile_bloc.dart';
import '../model/user_profile_model.dart';
import '../model/story_model.dart';
import '../model/gift_model.dart';
import '../model/user_gift_model.dart';
import '../repository/user_profile_repository.dart';
import 'package:afriqueen/features/gifts/service/gift_recharge_service.dart';
import 'package:afriqueen/features/gifts/service/gift_send_service.dart';
import 'package:afriqueen/services/distance/distance_calculator.dart';
import 'package:afriqueen/features/gifts/model/gift_sent_model.dart';
import 'package:afriqueen/common/widgets/premium_info_dialog.dart';
import 'package:afriqueen/services/premium_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({Key? key}) : super(key: key);

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class ActivityScreenWrapper extends StatelessWidget {
  const ActivityScreenWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => UserProfileBloc(UserProfileRepository()),
        ),
        BlocProvider(
          create: (context) => MatchBloc(),
        ),
        BlocProvider(
          create: (context) => FavoriteBloc(repository: FavoriteRepository()),
        ),
        BlocProvider(
          create: (context) => ArchiveBloc(repository: ArchiveRepository()),
        ),
      ],
      child: const ActivityScreen(),
    );
  }
}

class _ActivityScreenState extends State<ActivityScreen> {
  int _selectedMainTabIndex = 0;
  int _selectedSubTabIndex = 0;
  final EventRequestRepository _eventRequestRepository = EventRequestRepository();
  final EventRepository _eventRepository = EventRepository();
  final PremiumService _premiumService = PremiumService();
  bool _isPremiumUser = false;
  bool _isPremiumStatusLoading = true;

  @override
  void initState() {
    super.initState();
    // Load data based on selected tab (default is Views tab, first sub-tab is "I have been seen")
    // Don't load anything initially, let the tab selection trigger the load
    // Initialize recharge timers
    GiftRechargeService.initializeRechargeTimers();

    _loadPremiumStatus();
    
    // Load initial data for the default tab (Views > "I have been seen")
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProfileBloc>().add(LoadViewedUsers());
    });
  }

  Future<void> _loadPremiumStatus() async {
    try {
      final isPremium = await _premiumService.isUserPremium();
      if (!mounted) return;
      setState(() {
        _isPremiumUser = isPremium;
        _isPremiumStatusLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isPremiumUser = false;
        _isPremiumStatusLoading = false;
      });
    }
  }

  Future<void> _handleCreateEvent() async {
    try {
      // Debug user status
      await _premiumService.debugUserStatus();
      
      final hasReachedLimit = await _premiumService.hasReachedEventLimit();
      
      if (hasReachedLimit) {
        // Show premium info dialog
        PremiumInfoDialog.show(context);
      } else {
        // Navigate to create event screen
        Get.to(() => const CreateEventScreen());
      }
    } catch (e) {
      // On error, show premium dialog as fallback
      PremiumInfoDialog.show(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.home_outlined,
            color: AppColors.black,
            size: 24.sp,
          ),
          onPressed: () => Get.toNamed(AppRoutes.profileHome),
        ),
         title: Text(
           _getAppBarTitle(),
           style: TextStyle(
             fontSize: 18.sp,
             fontWeight: FontWeight.w600,
             color: AppColors.black,
           ),
         ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.notifications_outlined,
              color: AppColors.black,
              size: 24.sp,
            ),
            onPressed: () {
              // TODO: Navigate to notifications
            },
          ),
          IconButton(
            icon: Icon(
              Icons.filter_list_outlined,
              color: AppColors.black,
              size: 24.sp,
            ),
            onPressed: () {
              // TODO: Open filter
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Main Navigation Tabs
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Column(
              children: [
                // First row of main tabs
                Container(
                  height: 32.h,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildMainTab(EnumLocale.activityVus.name.tr, 0, _selectedMainTabIndex == 0, 0),
                      _buildMainTab(EnumLocale.activityLikes.name.tr, 1, _selectedMainTabIndex == 1, 0),
                      _buildMainTab(EnumLocale.activityCadeaux.name.tr, 2, _selectedMainTabIndex == 2, 0),
                      _buildMainTab(EnumLocale.activityStory.name.tr, 3, _selectedMainTabIndex == 3, 0),
                      _buildMainTab(EnumLocale.activityEvenement.name.tr, 4, _selectedMainTabIndex == 4, 0),
                    ],
                  ),
                ),
                
                SizedBox(height: 6.h),
                
                 // Second row of sub tabs
                 Container(
                   height: 32.h,
                   child: ListView(
                     scrollDirection: Axis.horizontal,
                     children: _buildSubTabs(),
                   ),
                 ),
                
                SizedBox(height: 16.h),
                
                // Statistics
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _getStatisticsText(),
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Content
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildMainTab(String title, int index, bool isSelected, int count) {
    return Container(
      margin: EdgeInsets.only(right: 8.w),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16.r),
           onTap: () {
             setState(() {
               _selectedMainTabIndex = index;
               _selectedSubTabIndex = 0; // Reset sub-tab when main tab changes
             });
             _loadDataForMainTab(index);
           },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: isSelected ? Color(0xFFF7BD8E) : Colors.transparent,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: isSelected ? Color(0xFFF7BD8E) : Colors.grey.shade300,
                width: 1.w,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : AppColors.black,
                  ),
                ),
                if (count > 0) ...[
                  SizedBox(width: 4.w),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Text(
                      count.toString(),
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubTab(String title, int index, bool isSelected, int count) {
    return Container(
      margin: EdgeInsets.only(right: 8.w),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16.r),
          onTap: () {
            setState(() {
              _selectedSubTabIndex = index;
            });
            _loadDataForSubTab(index);
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: isSelected ? Color(0xFFF7BD8E) : Colors.transparent,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: isSelected ? Color(0xFFF7BD8E) : Colors.grey.shade300,
                width: 1.w,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : AppColors.black,
                  ),
                ),
                if (count > 0) ...[
                  SizedBox(width: 4.w),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Text(
                      count.toString(),
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _loadDataForMainTab(int index) {
    final bloc = context.read<UserProfileBloc>();
    switch (index) {
      case 0: // Vus
        bloc.add(LoadViewedUsers());
        break;
      case 1: // Likes
        bloc.add(LoadLikedUsers()); // Load liked users by default
        break;
      case 2: // Cadeaux
        bloc.add(LoadAllUsers());
        break;
      case 3: // Story
        bloc.add(LoadStoryLikedUsers()); // Load story liked users by default
        break;
      case 4: // Évènement
        bloc.add(LoadAllUsers());
        break;
    }
  }

  String _getAppBarTitle() {
    if (_selectedMainTabIndex == 1) { // Likes tab
      switch (_selectedSubTabIndex) {
        case 0:
          return EnumLocale.activityLikeRecu.name.tr;
        case 1:
          return EnumLocale.activityMatch.name.tr;
        case 2:
          return EnumLocale.activityJaiLike.name.tr;
        default:
          return EnumLocale.activityLikesTitle.name.tr;
      }
    } else if (_selectedMainTabIndex == 2) { // Gifts tab
      switch (_selectedSubTabIndex) {
        case 0:
          return EnumLocale.activityCadeauxRecu.name.tr;
        case 1:
          return EnumLocale.activityCadeauxEnvoye.name.tr;
        case 2:
          return EnumLocale.activityMesCadeaux.name.tr;
        default:
          return EnumLocale.activityCadeaux.name.tr;
      }
    } else if (_selectedMainTabIndex == 3) { // Story tab
      switch (_selectedSubTabIndex) {
        case 0:
          return EnumLocale.activityVu.name.tr;
        case 1:
          return EnumLocale.activityLike.name.tr;
        case 2:
          return EnumLocale.activityMesStory.name.tr;
        default:
          return EnumLocale.activityStory.name.tr;
      }
    } else if (_selectedMainTabIndex == 4) { // Event tab
      switch (_selectedSubTabIndex) {
        case 0:
          return EnumLocale.activityEventIlsOntParticipe.name.tr;
        case 1:
          return EnumLocale.activityEventJaiParticipe.name.tr;
        case 2:
          return EnumLocale.activityEventMesEvenements.name.tr;
        default:
          return EnumLocale.activityEvenement.name.tr;
      }
    }
    return EnumLocale.activityVuOnMaVu.name.tr;
  }

  String _getStatisticsText() {
    if (_selectedMainTabIndex == 2) { // Gifts tab
      return EnumLocale.activityNombreCadeaux7Jours.name.tr + ' : 4';
    } else if (_selectedMainTabIndex == 3) { // Story tab
      return EnumLocale.activityLikeDepuisStory7Jours.name.tr + ' : 4';
    } else if (_selectedMainTabIndex == 4) { // Event tab
      return EnumLocale.activityNombreParticipations7Jours.name.tr + ' : 58';
    }
    return EnumLocale.activityNombreVues7Jours.name.tr + ' : 4';
  }

  List<Widget> _buildSubTabs() {
    if (_selectedMainTabIndex == 1) { // Likes tab
      return [
        _buildSubTab(EnumLocale.activityLikeRecu.name.tr, 0, _selectedSubTabIndex == 0, 0),
        _buildSubTab(EnumLocale.activityMatch.name.tr, 1, _selectedSubTabIndex == 1, 0),
        _buildSubTab(EnumLocale.activityJaiLike.name.tr, 2, _selectedSubTabIndex == 2, 0),
      ];
    } else if (_selectedMainTabIndex == 2) { // Gifts tab
      return [
        _buildSubTab(EnumLocale.activityCadeauxRecu.name.tr, 0, _selectedSubTabIndex == 0, 0),
        _buildSubTab(EnumLocale.activityCadeauxEnvoye.name.tr, 1, _selectedSubTabIndex == 1, 0),
        _buildSubTab(EnumLocale.activityMesCadeaux.name.tr, 2, _selectedSubTabIndex == 2, 0),
      ];
    } else if (_selectedMainTabIndex == 3) { // Story tab
      return [
        _buildSubTab(EnumLocale.activityVu.name.tr, 0, _selectedSubTabIndex == 0, 0),
        _buildSubTab(EnumLocale.activityLike.name.tr, 1, _selectedSubTabIndex == 1, 0),
        _buildSubTab(EnumLocale.activityMesStory.name.tr, 2, _selectedSubTabIndex == 2, 0),
      ];
    } else if (_selectedMainTabIndex == 4) { // Event tab
      return [
        _buildSubTab(EnumLocale.activityEventIlsOntParticipe.name.tr, 0, _selectedSubTabIndex == 0, 0),
        _buildSubTab(EnumLocale.activityEventJaiParticipe.name.tr, 1, _selectedSubTabIndex == 1, 0),
        _buildSubTab(EnumLocale.activityEventMesEvenements.name.tr, 2, _selectedSubTabIndex == 2, 0),
      ];
    } else {
      return [
        _buildSubTab(EnumLocale.activityOnMaVu.name.tr, 0, _selectedSubTabIndex == 0, 0),
        _buildSubTab(EnumLocale.activityJaiVu.name.tr, 1, _selectedSubTabIndex == 1, 0),
      ];
    }
  }

  void _loadDataForSubTab(int index) {
    final bloc = context.read<UserProfileBloc>();
    
    if (_selectedMainTabIndex == 1) { // Likes tab
      switch (index) {
        case 0: // Like reçu
          bloc.add(LoadLikedUsers());
          break;
        case 1: // Match
          bloc.add(LoadAllUsers()); // TODO: Implement match logic
          break;
        case 2: // J'ai liké
          bloc.add(LoadUsersILiked());
          break;
      }
    } else if (_selectedMainTabIndex == 2) { // Gifts tab
      switch (index) {
        case 0: // Cadeaux reçus
          // TODO: Load received gifts
          break;
        case 1: // Cadeaux envoyés
          // TODO: Load sent gifts
          break;
        case 2: // Mes cadeaux
          // TODO: Load my gifts
          break;
      }
    } else if (_selectedMainTabIndex == 3) { // Story tab
      switch (index) {
        case 0: // Vu
          bloc.add(LoadStoryLikedUsers());
          break;
        case 1: // Like
          bloc.add(LoadUsersILikedStory());
          break;
        case 2: // Mes story
          bloc.add(LoadMyStories());
          break;
      }
    } else if (_selectedMainTabIndex == 4) { // Event tab
      switch (index) {
        case 0: // Ils ont participé
          // TODO: wire to event feed later
          break;
        case 1: // J'ai participé
          // TODO: wire to my participations later
          break;
        case 2: // Mes évènements -> open Create Event UI
          // Do not navigate; show embedded "Mes évènements" list below
          setState(() {});
          break;
      }
    } else {
      switch (index) {
        case 0: // On m'a vu
          bloc.add(LoadViewedUsers());
          break;
        case 1: // J'ai vu
          bloc.add(LoadUsersIViewed());
          break;
      }
    }
  }

  Widget _buildContent() {
    return BlocBuilder<UserProfileBloc, UserProfileState>(
      builder: (context, state) {
        if (state is UserProfileLoading) {
          return Center(
            child: CircularProgressIndicator(
              color: Color(0xFFF7BD8E),
            ),
          );
        }
        // Gifts tab: Use custom UI per design
        if (_selectedMainTabIndex == 2) {
          if (_selectedSubTabIndex == 2) {
            // My Gifts tab
            return _buildMyGiftsUI();
          } else {
            // Received/Sent Gifts tabs
            return _buildGiftsUI();
          }
        }
        
        // Event tab: Sub-tab 0 and 1 use custom UI per design
        if (_selectedMainTabIndex == 4 && _selectedSubTabIndex == 0) {
          return _buildTheyParticipatedUI();
        }
        if (_selectedMainTabIndex == 4 && _selectedSubTabIndex == 1) {
          return _buildIParticipatedUI();
        }
        
        if (state is UserProfileError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64.sp,
                  color: Colors.grey.shade400,
                ),
                SizedBox(height: 16.h),
                Text(
                  '${EnumLocale.giftError.name.tr} ${state.message}',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }
        
        // Mes évènements embedded UI
        if (_selectedMainTabIndex == 4 && _selectedSubTabIndex == 2) {
          final userId = FirebaseAuth.instance.currentUser?.uid;
          if (userId == null) {
            return Center(child: Text(EnumLocale.giftNotLoggedIn.name.tr));
          }
          return StreamBuilder<List<EventModel>>(
            stream: EventRepository().streamEventsByCreator(userId),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(color: Color(0xFFF7BD8E)),
                );
              }
              final events = snap.data ?? [];
              const int totalSlots = 5; // show 5 rows (events first, then create placeholders)
              final int showEvents = events.length > totalSlots ? totalSlots : events.length;
              final List<Widget> rows = [];
              for (int i = 0; i < showEvents; i++) {
                rows.add(_buildMyEventCard(events[i]));
                rows.add(SizedBox(height: 12.h));
              }
              for (int i = showEvents; i < totalSlots; i++) {
                rows.add(_buildCreatePlaceholder());
                if (i < totalSlots - 1) rows.add(SizedBox(height: 12.h));
              }

              return ListView(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                children: rows,
              );
            },
          );
        }

        if (state is StoryLoaded) {
          if (state.stories.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.image_outlined,
                    size: 64.sp,
                    color: Colors.grey.shade400,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    EnumLocale.giftNoStories.name.tr,
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            shrinkWrap: false,
            padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 12.h, bottom: 16.h),
            physics: const BouncingScrollPhysics(),
            itemCount: state.stories.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.72,
              crossAxisSpacing: 8.w,
              mainAxisSpacing: 20.h,
            ),
            itemBuilder: (context, index) {
              final story = state.stories[index];
              return _buildStoryCard(story);
            },
          );
        }

        if (state is UserProfileLoaded) {
          print('ActivityScreen: Received ${state.users.length} users');
          
          // Debug: Print each user
          for (int i = 0; i < state.users.length; i++) {
            final user = state.users[i];
            print('ActivityScreen: User $i - ID: ${user.id}, Name: ${user.name}, Pseudo: ${user.pseudo}');
            print('ActivityScreen: User $i - photos: ${user.photos}');
            print('ActivityScreen: User $i - photos length: ${user.photos?.length ?? 0}');
          }
          
          if (state.users.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 64.sp,
                    color: Colors.grey.shade400,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    EnumLocale.giftNoUsersFound.name.tr,
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            );
          }
          
          return Transform.translate(
            offset: Offset(0, 0),
            child: GridView.builder(
              shrinkWrap: false,
              padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 12.h, bottom: 16.h),
              physics: const BouncingScrollPhysics(),
              itemCount: state.users.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.4, // Same as home screen
                crossAxisSpacing: 8.w,
                mainAxisSpacing: 20.h,
              ),
              itemBuilder: (BuildContext context, index) {
                final user = state.users[index];
                if (user == null) {
                  return SizedBox.shrink();
                }
                return _buildProfileCardFromModel(user);
              },
            ),
          );
        }
        
        return SizedBox.shrink();
      },
    );
  }

  Widget _buildStoryCard(StoryModel story) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16.r),
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              color: Colors.grey.shade200,
              child: story.imageUrl.isNotEmpty
                  ? Image.network(
                      story.imageUrl,
                      fit: BoxFit.cover,
                    )
                  : Center(
                      child: Icon(
                        Icons.image_outlined,
                        size: 48.sp,
                        color: Colors.grey.shade400,
                      ),
                    ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.0),
                    Colors.black.withOpacity(0.5),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (story.text.isNotEmpty)
                    Text(
                      story.text,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  SizedBox(height: 4.h),
                  Text(
                    story.createdDate != null
                        ? timeago.format(story.createdDate!.toLocal())
                        : '',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 10.sp,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyEventCard(EventModel e) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8.r),
          child: Container(
            width: 48.w,
            height: 48.w,
            color: Colors.grey.shade300,
            child: (e.imageUrl?.isNotEmpty == true)
                ? Image.network(e.imageUrl!, fit: BoxFit.cover)
                : Icon(Icons.event, color: Colors.grey.shade600, size: 24.sp),
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${(e.status == EventStatus.GROUP ? EnumLocale.groupText.name.tr : EnumLocale.duoText.name.tr)} : ${e.title}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 2.h),
              Text(
                '${EnumLocale.eventDateLabel.name.tr} ${_formatEventDate(e.date)}',
                style: TextStyle(fontSize: 10.sp, color: Colors.grey.shade700),
              ),
              Text(
                '${EnumLocale.eventPlaceLabel.name.tr} : ${e.location}',
                style: TextStyle(fontSize: 10.sp, color: Colors.grey.shade700),
              ),
              Text(
                '${EnumLocale.eventParticipantsCountLabel.name.tr} ${e.maxParticipants ?? '-'}',
                style: TextStyle(fontSize: 10.sp, color: Colors.grey.shade700),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatEventDate(DateTime date) {
    final two = (int v) => v.toString().padLeft(2, '0');
    return '${two(date.day)}/${two(date.month)}/${date.year} ${two(date.hour)}:${two(date.minute)}';
  }

  // Event request action methods
  Future<void> _acceptEventRequest(EventRequestModel request) async {
    try {
      // Update the request status to accepted
      await _eventRequestRepository.updateEventRequestStatus(
        requestId: request.id,
        status: EventRequestStatus.ACCEPTED,
      );
      
      // Add the user to the event's participants collection
      await _eventRepository.addParticipantToEvent(
        eventId: request.eventId,
        userId: request.requesterId,
        userName: request.requesterName,
        userPhotoUrl: request.requesterPhotoUrl,
      );
      
      Get.snackbar(
        'Success',
        'Event request accepted and user added to participants',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade800,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to accept request: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
    }
  }

  Future<void> _rejectEventRequest(EventRequestModel request) async {
    try {
      await _eventRequestRepository.updateEventRequestStatus(
        requestId: request.id,
        status: EventRequestStatus.REJECTED,
      );
      
      Get.snackbar(
        'Success',
        'Event request rejected',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange.shade100,
        colorText: Colors.orange.shade800,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to reject request: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
    }
  }

  Future<void> _cancelEventRequest(EventRequestModel request) async {
    try {
      await _eventRequestRepository.deleteEventRequest(request.id);
      
      Get.snackbar(
        'Success',
        'Event request cancelled',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.blue.shade100,
        colorText: Colors.blue.shade800,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to cancel request: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
    }
  }

  Widget _buildCreatePlaceholder() {
    return Row(
      children: [
        Container(
          width: 48.w,
          height: 48.w,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Container(
            height: 56.h,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Center(
              child: ElevatedButton(
                onPressed: _handleCreateEvent,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF6564C0),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24.r),
                  ),
                  minimumSize: Size(120.w, 32.h),
                ),
                child: Text(EnumLocale.giftCreate.name.tr),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============ Event Tab UIs (They participated / I participated) ============
  Widget _buildTheyParticipatedUI() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return Center(
        child: Text(
          'Please log in to see event requests',
          style: TextStyle(fontSize: 16.sp, color: Colors.grey.shade600),
        ),
      );
    }

    return StreamBuilder<List<EventRequestModel>>(
      stream: _eventRequestRepository.streamReceivedEventRequests(currentUser.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              color: Color(0xFFF7BD8E),
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading event requests: ${snapshot.error}',
              style: TextStyle(fontSize: 16.sp, color: Colors.red.shade600),
            ),
          );
        }

        final requests = snapshot.data ?? [];
        if (requests.isEmpty) {
          return Center(
            child: Text(
              'No event participation requests yet',
              style: TextStyle(fontSize: 16.sp, color: Colors.grey.shade600),
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final request = requests[index];
            return _buildEventRequestCard(request);
          },
        );
      },
    );
  }

  Widget _buildIParticipatedUI() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return Center(
        child: Text(
          'Please log in to see your event requests',
          style: TextStyle(fontSize: 16.sp, color: Colors.grey.shade600),
        ),
      );
    }

    return StreamBuilder<List<EventRequestModel>>(
      stream: _eventRequestRepository.streamSentEventRequests(currentUser.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              color: Color(0xFFF7BD8E),
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading your event requests: ${snapshot.error}',
              style: TextStyle(fontSize: 16.sp, color: Colors.red.shade600),
            ),
          );
        }

        final requests = snapshot.data ?? [];
        if (requests.isEmpty) {
          return Center(
            child: Text(
              'No event participation requests sent yet',
              style: TextStyle(fontSize: 16.sp, color: Colors.grey.shade600),
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final request = requests[index];
            return _buildMyEventRequestCard(request);
          },
        );
      },
    );
  }

  Widget _eventUserCard({
    required String name,
    required String subtitleTop,
    required String subtitleMid,
    required String subtitleBottom,
    required Widget primaryAction,
    required Widget secondaryAction,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(24.r),
            child: Image.network(
              'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=200',
              width: 48.w,
              height: 48.w,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.black,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  subtitleTop,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade600),
                ),
                SizedBox(height: 2.h),
                Text(
                  subtitleMid,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade600),
                ),
                SizedBox(height: 2.h),
                Text(
                  subtitleBottom,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade600),
                ),
                SizedBox(height: 10.h),
                Row(
                  children: [
                    primaryAction,
                    SizedBox(width: 12.w),
                    secondaryAction,
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _pillButton({required String label, required Color color, required VoidCallback onTap}) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.r),
        ),
        minimumSize: Size(120.w, 36.h),
        elevation: 0,
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600),
      ),
    );
  }

  // New widget for displaying received event requests
  Widget _buildEventRequestCard(EventRequestModel request) {
    final timeAgo = timeago.format(request.createdAt, locale: 'en');
    String statusText = '';
    Color statusColor = Colors.grey.shade600;
    
    switch (request.status) {
      case EventRequestStatus.PENDING:
        statusText = '';
        break;
      case EventRequestStatus.ACCEPTED:
        statusText = 'Accepted';
        statusColor = Color(0xFF1DB954);
        break;
      case EventRequestStatus.REJECTED:
        statusText = 'Rejected';
        statusColor = Color(0xFFE53935);
        break;
    }
    
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(24.r),
            child: Container(
              width: 48.w,
              height: 48.w,
              color: Colors.grey.shade300,
              child: (request.requesterPhotoUrl?.isNotEmpty == true)
                  ? Image.network(request.requesterPhotoUrl!, fit: BoxFit.cover)
                  : Icon(Icons.person, color: Colors.grey.shade600, size: 24.sp),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.requesterName ?? 'Unknown User',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.black,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '$timeAgo',
                  style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade600),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Event: ${request.eventTitle ?? 'Unknown Event'}',
                  style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade600),
                ),
                SizedBox(height: 2.h),
                Text(
                  request.message,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade600),
                ),
                SizedBox(height: 10.h),
                // Show action buttons only for pending requests
                if (request.status == EventRequestStatus.PENDING)
                  Row(
                    children: [
                      _pillButton(
                        label: EnumLocale.accept.name.tr,
                        color: Color(0xFF1DB954),
                        onTap: () => _acceptEventRequest(request),
                      ),
                      SizedBox(width: 12.w),
                      _pillButton(
                        label: EnumLocale.reject.name.tr,
                        color: Color(0xFFE53935),
                        onTap: () => _rejectEventRequest(request),
                      ),
                    ],
                  )
                else
                  // Show status text for accepted/rejected requests
                  Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // New widget for displaying sent event requests
  Widget _buildMyEventRequestCard(EventRequestModel request) {
    final timeAgo = timeago.format(request.createdAt, locale: 'en');
    String statusText = '';
    Color statusColor = Colors.grey.shade600;
    
    switch (request.status) {
      case EventRequestStatus.PENDING:
        statusText = EnumLocale.giftWaiting.name.tr;
        statusColor = Colors.orange;
        break;
      case EventRequestStatus.ACCEPTED:
        statusText = 'Accepted';
        statusColor = Color(0xFF1DB954);
        break;
      case EventRequestStatus.REJECTED:
        statusText = 'Rejected';
        statusColor = Color(0xFFE53935);
        break;
    }
    
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(24.r),
            child: Container(
              width: 48.w,
              height: 48.w,
              color: Colors.grey.shade300,
              child: Icon(Icons.event, color: Colors.grey.shade600, size: 24.sp),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.eventTitle ?? 'Unknown Event',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.black,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '$timeAgo',
                  style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade600),
                ),
                SizedBox(height: 2.h),
                Text(
                  request.message,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade600),
                ),
                SizedBox(height: 10.h),
                Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(right: 12.w),
                      child: Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (request.status == EventRequestStatus.PENDING)
                      _pillButton(
                        label: EnumLocale.giftCancel.name.tr,
                        color: Color(0xFFF48B8B),
                        onTap: () => _cancelEventRequest(request),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCardFromModel(UserProfileModel user) {
    // Convert UserProfileModel to HomeModel
    final homeModel = HomeModel(
      id: user.id,
      pseudo: user.pseudo?.isNotEmpty == true ? user.pseudo! : user.name,
      name: user.name,
      gender: user.gender ?? '',
      orientation: user.orientation ?? '',
      age: user.age ?? 0,
      country: user.country ?? '',
      city: user.city ?? '',
      description: user.description ?? '',
      searchDescription: user.searchDescription ?? '',
      whatLookingFor: user.whatLookingFor ?? '',
      whatNotWant: user.whatNotWant ?? '',
      mainInterests: user.mainInterests ?? [],
      secondaryInterests: user.secondaryInterests ?? [],
      passions: user.passions ?? [],
      hobbies: user.hobbies ?? [],
      languages: user.languages ?? [],
      educationLevels: user.educationLevels ?? [],
      ethnicOrigins: user.ethnicOrigins ?? [],
      religions: user.religions ?? [],
      qualities: user.qualities ?? [],
      flaws: user.flaws ?? [],
      photos: user.photos ?? [],
      createdDate: user.createdDate ?? DateTime.now(),
      dob: user.dob ?? DateTime.now(),
      lastActive: user.lastActive ?? DateTime.now(),
      relationshipStatus: user.relationshipStatus ?? '',
      height: user.height ?? 0,
      silhouette: user.silhouette ?? 0,
      hasChildren: user.hasChildren ?? 0,
      wantsChildren: user.wantsChildren ?? 0,
      hasAnimals: user.hasAnimals ?? 0,
      alcohol: user.alcohol ?? 0,
      smoking: user.smoking ?? 0,
      snoring: user.snoring ?? 0,
      isElite: user.isElite ?? false,
      isActive: user.isActive ?? false,
      isPremium: user.isPremium ?? false,
      email: user.email ?? '',
    );

    return ProfileCard(item: homeModel);
  }

  // ============ Gifts UI ============
  Widget _buildGiftsUI() {
    if (_selectedSubTabIndex == 0) {
      // Received Gifts tab
      return StreamBuilder<List<GiftSentModel>>(
        stream: GiftSendService.getGiftsReceivedByUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor),
            );
          }
          
          if (snapshot.hasError) {
            return Center(
              child: Text('${EnumLocale.giftError.name.tr} ${snapshot.error}'),
            );
          }
          
          final gifts = snapshot.data ?? [];
          if (gifts.isEmpty) {
            return Center(
              child: Text(
                EnumLocale.giftNoUsersFound.name.tr,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.grey.shade600,
                ),
              ),
            );
          }
          
          return ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            itemCount: gifts.length,
            itemBuilder: (context, index) {
              final gift = gifts[index];
              return _buildGiftSentCard(gift, true); // true = received
            },
          );
        },
      );
    } else {
      // Sent Gifts tab
      return StreamBuilder<List<GiftSentModel>>(
        stream: GiftSendService.getGiftsSentByUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor),
            );
          }
          
          if (snapshot.hasError) {
            return Center(
              child: Text('${EnumLocale.giftError.name.tr} ${snapshot.error}'),
            );
          }
          
          final gifts = snapshot.data ?? [];
          if (gifts.isEmpty) {
            return Center(
              child: Text(
                EnumLocale.giftNoUsersFound.name.tr,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.grey.shade600,
                ),
              ),
            );
          }
          
          return ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            itemCount: gifts.length,
            itemBuilder: (context, index) {
              final gift = gifts[index];
              return _buildGiftSentCard(gift, false); // false = sent
            },
          );
        },
      );
    }
  }

  Widget _buildGiftSentCard(GiftSentModel gift, bool isReceived) {
    // Get user ID based on whether it's received or sent
    final userId = isReceived ? gift.senderId : gift.recipientId;
    
    print('ActivityScreen: Building gift card for ${isReceived ? "received" : "sent"} gift');
    print('ActivityScreen: User ID: $userId');
    print('ActivityScreen: Gift data: senderName=${gift.senderName}, senderAge=${gift.senderAge}, recipientName=${gift.recipientName}, recipientAge=${gift.recipientAge}');
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('user').doc(userId).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            margin: EdgeInsets.only(bottom: 16.h),
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor),
            ),
          );
        }
        
        if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
          print('ActivityScreen: Error fetching user data for $userId: ${snapshot.error}');
          return Container(
            margin: EdgeInsets.only(bottom: 16.h),
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Text('Error loading user data'),
          );
        }
        
        final userData = snapshot.data!.data() as Map<String, dynamic>;
        final userName = userData['name'] ?? 'Unknown';
        final userAge = userData['age'] ?? 0;
        final userPhotos = userData['photos'] as List<dynamic>?;
        final userPhotoUrl = userPhotos?.isNotEmpty == true ? userPhotos!.first : null;
        final userCity = userData['city']?.toString() ?? '';
        final userCountry = userData['country']?.toString() ?? '';
        
        print('ActivityScreen: Fetched user data - name: $userName, age: $userAge, photo: $userPhotoUrl');
        
        return Container(
          margin: EdgeInsets.only(bottom: 16.h),
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile picture with colored border
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _getGiftBorderColor(gift.giftType),
                        width: 2.w,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24.r),
                      child: Image.network(
                        userPhotoUrl ?? 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=200',
                        width: 48.w,
                        height: 48.w,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 48.w,
                            height: 48.w,
                            color: Colors.grey.shade100,
                            child: Icon(
                              Icons.person,
                              color: Colors.grey.shade400,
                              size: 24.sp,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  // User details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '$userName, $userAge',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.black,
                              ),
                            ),
                            Spacer(),
                            FutureBuilder<double?>(
                              future: DistanceCalculator.calculateDistanceToUser(userCity, userCountry),
                              builder: (context, distanceSnapshot) {
                                if (distanceSnapshot.connectionState == ConnectionState.waiting) {
                                  return Text(
                                    '...',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: Colors.grey.shade600,
                                    ),
                                  );
                                }
                                return Text(
                                  DistanceCalculator.formatDistance(distanceSnapshot.data),
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.grey.shade600,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          '${EnumLocale.giftLastConnection.name.tr} ${_formatLastActive(DateTime.now().subtract(Duration(hours: 2)))}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Text(
                          EnumLocale.giftLookingForSerious.name.tr,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 12.w),
                  // Gift icon
                  Column(
                    children: [
                      _buildGiftIconFromType(gift.giftType),
                      SizedBox(height: 4.h),
                      Text(
                        gift.giftName,
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              // Timestamp at bottom
              Text(
                '${isReceived ? EnumLocale.giftReceived.name.tr : EnumLocale.giftSent.name.tr} ${_formatTimeAgo(gift.sentAt)}',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGiftCard(GiftModel gift) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile picture with border
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: gift.giftType == GiftType.heart ? Colors.yellow : Colors.red,
                width: 2.w,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24.r),
              child: Image.network(
                gift.senderPhotoUrl ?? 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=200',
                width: 48.w,
                height: 48.w,
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          // Gift details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '${gift.senderName}, ${gift.senderAge}',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.black,
                      ),
                    ),
                    Spacer(),
                    Text(
                      gift.senderLocation ?? '',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  '${EnumLocale.giftLastConnection.name.tr} ${_formatLastActive(gift.senderLastActive)}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  gift.senderRelationshipStatus ?? '',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  '${EnumLocale.giftReceived.name.tr} ${_formatTimeAgo(gift.timestamp)}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          // Gift icon
          Column(
            children: [
              _buildGiftIcon(gift.giftType),
              SizedBox(height: 4.h),
              Text(
                _getGiftTypeName(gift.giftType),
                style: TextStyle(
                  fontSize: 10.sp,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getGiftBorderColor(String giftType) {
    switch (giftType) {
      case 'rose':
        return Colors.pink;
      case 'chocolat':
        return Colors.brown;
      case 'bouquet':
        return Colors.green;
      case 'vetement':
        return Colors.blue;
      case 'coeur':
        return Colors.red;
      case 'bague':
        return Colors.blue;
      case 'papillon':
        return Colors.purple;
      case 'trophee':
        return Colors.amber;
      case 'donut':
        return Colors.brown;
      case 'pizza':
        return Colors.orange;
      case 'sac':
        return Colors.teal;
      case 'chiot':
        return Colors.brown;
      default:
        return Colors.grey;
    }
  }

  Widget _buildGiftIconFromType(String giftType) {
    IconData iconData;
    Color iconColor;
    
    switch (giftType) {
      case 'rose':
        iconData = Icons.local_florist;
        iconColor = Colors.pink;
        break;
      case 'chocolat':
        iconData = Icons.cake;
        iconColor = Colors.brown;
        break;
      case 'bouquet':
        iconData = Icons.eco;
        iconColor = Colors.green;
        break;
      case 'vetement':
        iconData = Icons.checkroom;
        iconColor = Colors.blue;
        break;
      case 'coeur':
        iconData = Icons.favorite;
        iconColor = Colors.red;
        break;
      case 'bague':
        iconData = Icons.diamond;
        iconColor = Colors.blue;
        break;
      case 'papillon':
        iconData = Icons.flutter_dash;
        iconColor = Colors.purple;
        break;
      case 'trophee':
        iconData = Icons.emoji_events;
        iconColor = Colors.amber;
        break;
      case 'donut':
        iconData = Icons.donut_large;
        iconColor = Colors.brown;
        break;
      case 'pizza':
        iconData = Icons.local_pizza;
        iconColor = Colors.orange;
        break;
      case 'sac':
        iconData = Icons.shopping_bag;
        iconColor = Colors.teal;
        break;
      case 'chiot':
        iconData = Icons.pets;
        iconColor = Colors.brown;
        break;
      default:
        iconData = Icons.card_giftcard;
        iconColor = Colors.grey;
        break;
    }
    
    return Icon(
      iconData,
      size: 24.sp,
      color: iconColor,
    );
  }

  Widget _buildGiftIcon(GiftType giftType) {
    IconData iconData;
    Color iconColor;
    
    switch (giftType) {
      case GiftType.heart:
        iconData = Icons.favorite;
        iconColor = Colors.red;
        break;
      case GiftType.rose:
        iconData = Icons.local_florist;
        iconColor = Colors.pink;
        break;
      case GiftType.chocolate:
        iconData = Icons.cake;
        iconColor = Colors.brown;
        break;
      case GiftType.diamond:
        iconData = Icons.diamond;
        iconColor = Colors.blue;
        break;
      case GiftType.flower:
        iconData = Icons.eco;
        iconColor = Colors.green;
        break;
      case GiftType.star:
        iconData = Icons.star;
        iconColor = Colors.amber;
        break;
    }
    
    return Icon(
      iconData,
      size: 24.sp,
      color: iconColor,
    );
  }

  String _getGiftTypeName(GiftType giftType) {
    switch (giftType) {
      case GiftType.heart:
        return EnumLocale.giftHeart.name.tr;
      case GiftType.rose:
        return EnumLocale.giftRose.name.tr;
      case GiftType.chocolate:
        return EnumLocale.giftChocolate.name.tr;
      case GiftType.diamond:
        return EnumLocale.giftDiamond.name.tr;
      case GiftType.flower:
        return EnumLocale.giftFlower.name.tr;
      case GiftType.star:
        return EnumLocale.giftStar.name.tr;
    }
  }

  String _formatLastActive(DateTime? lastActive) {
    if (lastActive == null) return '';
    
    final now = DateTime.now();
    final difference = now.difference(lastActive);
    
    if (difference.inHours < 1) {
      return 'il y a ${difference.inMinutes}min';
    } else if (difference.inHours < 24) {
      return 'il y a ${difference.inHours}h';
    } else {
      return 'il y a ${difference.inDays}j';
    }
  }

  String _formatTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inHours < 1) {
      return 'il y a ${difference.inMinutes}min';
    } else if (difference.inHours < 24) {
      return 'il y a ${difference.inHours}h';
    } else {
      return 'il y a ${difference.inDays}j';
    }
  }

  // ============ My Gifts UI ============
  Widget _buildMyGiftsUI() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      return Center(child: Text(EnumLocale.giftNotLoggedIn.name.tr));
    }

    return StreamBuilder<List<UserGiftModel>>(
      stream: _getUserGiftsStream(userId),
      builder: (context, snapshot) {
        if (_isPremiumStatusLoading) {
          return Center(
            child: CircularProgressIndicator(color: Color(0xFFF7BD8E)),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(color: Color(0xFFF7BD8E)),
          );
        }

        final gifts = snapshot.data ?? [];
        final regularGifts = gifts.where((gift) => !gift.isPremium).toList();
        final premiumGifts = gifts.where((gift) => gift.isPremium).toList();

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Regular Gifts Section
              _buildGiftGrid(regularGifts),
              
              SizedBox(height: 24.h),
              
              // Premium Gifts Section
              _buildPremiumGiftsHeader(),
              SizedBox(height: 16.h),
              _buildGiftGrid(premiumGifts),
            ],
          ),
        );
      },
    );
  }

  Stream<List<UserGiftModel>> _getUserGiftsStream(String userId) {
    return FirebaseFirestore.instance
        .collection('user')
        .doc(userId)
        .collection('gifts')
        .snapshots()
        .map((snapshot) {
      // Always start with default gifts (all with 0 count)
      final defaultGifts = _getDefaultGiftsWithZeroCount();
      
      if (snapshot.docs.isEmpty) {
        // Return default gifts with 0 count if collection doesn't exist
        return defaultGifts;
      }
      
      // Merge Firestore data with default gifts
      final firestoreGifts = snapshot.docs.map((doc) => UserGiftModel.fromFirestore(doc)).toList();
      final Map<String, UserGiftModel> giftMap = {};
      
      // Add default gifts first (all with 0 count)
      for (var gift in defaultGifts) {
        giftMap[gift.giftType] = gift;
      }
      
      // Update with Firestore data
      for (var gift in firestoreGifts) {
        giftMap[gift.giftType] = gift;
      }
      
      return giftMap.values.toList();
    }).handleError((error) {
      // If there's any error (like permission denied), return default gifts with 0 count
      return _getDefaultGiftsWithZeroCount();
    });
  }

  List<UserGiftModel> _getDefaultGiftsWithZeroCount() {
    final List<UserGiftModel> defaultGifts = [];
    
    // Add regular gifts with 0 count
    for (String giftType in GiftTypes.regularGifts) {
      defaultGifts.add(UserGiftModel(
        giftType: giftType,
        remainingCount: 0,
        isPremium: false,
      ));
    }
    
    // Add premium gifts with 0 count
    for (String giftType in GiftTypes.premiumGifts) {
      defaultGifts.add(UserGiftModel(
        giftType: giftType,
        remainingCount: 0,
        isPremium: true,
      ));
    }
    
    return defaultGifts;
  }

  Widget _buildPremiumGiftsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.card_giftcard,
          size: 20.sp,
          color: Colors.grey.shade600,
        ),
        SizedBox(width: 8.w),
        Text(
          EnumLocale.giftCadeauxPremium.name.tr,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildGiftGrid(List<UserGiftModel> gifts) {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.2,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
      ),
      itemCount: gifts.length,
      itemBuilder: (context, index) {
        final gift = gifts[index];
        return _buildUserGiftCard(gift);
      },
    );
  }

  Widget _buildUserGiftCard(UserGiftModel gift) {
    final bool isUnlocked = !gift.isPremium || _isPremiumUser;
    final bool hasStock = gift.remainingCount > 0;
    final bool isActive = isUnlocked && hasStock;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Gift Icon
          Icon(
            _getGiftIcon(gift.giftType),
            size: 32.sp,
            color: isActive
                ? _getGiftIconColor(gift.giftType)
                : Colors.grey.shade400,
          ),
          SizedBox(height: 8.h),
          
          // Gift Name
          Text(
            GiftTypes.giftNames[gift.giftType] ?? gift.giftType,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: isActive
                  ? AppColors.black
                  : Colors.grey.shade400,
            ),
          ),
          SizedBox(height: 4.h),
          
          // Remaining Count
          Text(
            '${gift.remainingCount} ${gift.remainingCount > 1 ? EnumLocale.giftRestants.name.tr : EnumLocale.giftRestant.name.tr}',
            style: TextStyle(
              fontSize: 12.sp,
              color: gift.remainingCount > 0 ? Colors.grey.shade600 : Colors.grey.shade400,
            ),
          ),
          
          // Lock icon for premium gifts
          if (gift.isPremium && !_isPremiumUser) ...[
            SizedBox(height: 8.h),
            Icon(
              Icons.lock,
              size: 16.sp,
              color: Colors.grey.shade400,
            ),
          ],
        ],
      ),
    );
  }

  IconData _getGiftIcon(String giftType) {
    final iconName = GiftTypes.giftIcons[giftType] ?? 'card_giftcard';
    
    switch (iconName) {
      case 'local_florist':
        return Icons.local_florist;
      case 'cake':
        return Icons.cake;
      case 'eco':
        return Icons.eco;
      case 'checkroom':
        return Icons.checkroom;
      case 'favorite':
        return Icons.favorite;
      case 'diamond':
        return Icons.diamond;
      case 'flutter_dash':
        return Icons.flutter_dash;
      case 'emoji_events':
        return Icons.emoji_events;
      case 'donut_large':
        return Icons.donut_large;
      case 'local_pizza':
        return Icons.local_pizza;
      case 'shopping_bag':
        return Icons.shopping_bag;
      case 'pets':
        return Icons.pets;
      default:
        return Icons.card_giftcard;
    }
  }

  Color _getGiftIconColor(String giftType) {
    switch (giftType) {
      case 'rose':
        return Colors.pink;
      case 'chocolat':
        return Colors.brown;
      case 'bouquet':
        return Colors.green;
      case 'vetement':
        return Colors.blue;
      case 'coeur':
        return Colors.red;
      case 'bague':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }

}
