//------------ main part of data fetched state-----------------

import 'package:afriqueen/common/constant/constant_colors.dart';
import 'package:afriqueen/features/home/bloc/home_bloc.dart';
import 'package:afriqueen/features/home/bloc/home_event.dart';
import 'package:afriqueen/features/home/bloc/home_state.dart';
import 'package:afriqueen/features/home/repository/home_repository.dart';
import 'package:afriqueen/features/home/widget/data_fetched_screen_widgets.dart';
import 'package:afriqueen/features/home/widget/home_widgets.dart';
import 'package:afriqueen/routes/app_routes.dart';
import 'package:afriqueen/features/archive/bloc/archive_bloc.dart';
import 'package:afriqueen/features/archive/bloc/archive_event.dart';
import 'package:afriqueen/features/archive/repository/archive_repository.dart';
import 'package:afriqueen/features/favorite/bloc/favorite_bloc.dart';
import 'package:afriqueen/features/favorite/bloc/favorite_event.dart';
import 'package:afriqueen/features/favorite/repository/favorite_repository.dart';
import 'package:afriqueen/features/match/bloc/match_bloc.dart';
import 'package:afriqueen/features/match/bloc/match_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class HomeDataContent extends StatefulWidget {
  const HomeDataContent({super.key});

  @override
  State<HomeDataContent> createState() => _HomeDataContentState();
}

class _HomeDataContentState extends State<HomeDataContent> {
  void _onTabChanged(int index) {
    // Fetch appropriate data based on selected tab
    switch (index) {
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
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<FavoriteBloc>(
          create: (context) => FavoriteBloc(repository: FavoriteRepository())..add(FavoriteUsersFetched()),
        ),
        BlocProvider<ArchiveBloc>(
          create: (context) => ArchiveBloc(repository: ArchiveRepository())..add(ArchiveUsersFetched()),
        ),
        BlocProvider<MatchBloc>(
          create: (context) => MatchBloc(),
        ),
      ],
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            return Column(
              children: [
                //-------------------Navigation Tabs-------------------
                Container(
                  width: double.infinity,
                  child: NavigationTabs(
                    onTabChanged: _onTabChanged,
                    selectedIndex: state.selectedTabIndex,
                  ),
                ),
                //-------------------User Grid - NO SCROLL-------------------
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 0.w, vertical: 0.h),
                    child: UserImageGrid(),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
