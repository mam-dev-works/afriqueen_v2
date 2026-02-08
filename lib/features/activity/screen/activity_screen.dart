import 'package:afriqueen/common/localization/enums/enums.dart';
import 'package:afriqueen/common/theme/app_colors.dart';
import 'package:afriqueen/common/widgets/premium_info_dialog.dart';
import 'package:afriqueen/features/activity/bloc/user_profile_bloc.dart';
import 'package:afriqueen/features/activity/bloc/user_profile_event.dart';
import 'package:afriqueen/features/activity/widgets/activity_content.dart';
import 'package:afriqueen/features/activity/widgets/activity_tabs.dart';
import 'package:afriqueen/features/archive/bloc/archive_bloc.dart';
import 'package:afriqueen/features/archive/repository/archive_repository.dart';
import 'package:afriqueen/features/event/repository/event_repository.dart';
import 'package:afriqueen/features/event/repository/event_request_repository.dart';
import 'package:afriqueen/features/event/screen/create_event_screen.dart';
import 'package:afriqueen/features/favorite/bloc/favorite_bloc.dart';
import 'package:afriqueen/features/favorite/repository/favorite_repository.dart';
import 'package:afriqueen/features/gifts/service/gift_recharge_service.dart';
import 'package:afriqueen/features/match/bloc/match_bloc.dart';
import 'package:afriqueen/routes/app_routes.dart';
import 'package:afriqueen/services/premium_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../repository/user_profile_repository.dart';

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
  final EventRequestRepository _eventRequestRepository =
      EventRequestRepository();
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
          ActivityTabs(
            selectedMainTabIndex: _selectedMainTabIndex,
            selectedSubTabIndex: _selectedSubTabIndex,
            statisticsText: _getStatisticsText(),
            onMainTabSelected: (index) {
              setState(() {
                _selectedMainTabIndex = index;
                _selectedSubTabIndex = 0;
              });
              _loadDataForMainTab(index);
            },
            onSubTabSelected: (index) {
              setState(() {
                _selectedSubTabIndex = index;
              });
              _loadDataForSubTab(index);
            },
          ),
          Expanded(
            child: ActivityContent(
              selectedMainTabIndex: _selectedMainTabIndex,
              selectedSubTabIndex: _selectedSubTabIndex,
              isPremiumUser: _isPremiumUser,
              isPremiumStatusLoading: _isPremiumStatusLoading,
              eventRepository: _eventRepository,
              eventRequestRepository: _eventRequestRepository,
              onCreateEvent: _handleCreateEvent,
            ),
          ),
        ],
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

  void _loadDataForSubTab(int index) {
    final bloc = context.read<UserProfileBloc>();

    if (_selectedMainTabIndex == 1) {
      // Likes tab
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
    } else if (_selectedMainTabIndex == 2) {
      // Gifts tab
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
    } else if (_selectedMainTabIndex == 3) {
      // Story tab
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
    } else if (_selectedMainTabIndex == 4) {
      // Event tab
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

  String _getAppBarTitle() {
    if (_selectedMainTabIndex == 1) {
      // Likes tab
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
    } else if (_selectedMainTabIndex == 2) {
      // Gifts tab
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
    } else if (_selectedMainTabIndex == 3) {
      // Story tab
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
    } else if (_selectedMainTabIndex == 4) {
      // Event tab
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
    if (_selectedMainTabIndex == 2) {
      // Gifts tab
      return EnumLocale.activityNombreCadeaux7Jours.name.tr + ' : 4';
    } else if (_selectedMainTabIndex == 3) {
      // Story tab
      return EnumLocale.activityLikeDepuisStory7Jours.name.tr + ' : 4';
    } else if (_selectedMainTabIndex == 4) {
      // Event tab
      return EnumLocale.activityNombreParticipations7Jours.name.tr + ' : 58';
    }
    return EnumLocale.activityNombreVues7Jours.name.tr + ' : 4';
  }
}
