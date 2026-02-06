import 'package:afriqueen/common/constant/constant_colors.dart';
import 'package:afriqueen/common/localization/enums/enums.dart';
import 'package:afriqueen/features/chat/bloc/chat_bloc.dart';
import 'package:afriqueen/features/chat/repository/chat_repository.dart';
import 'package:afriqueen/features/chat/screen/chat_list_screen.dart';
import 'package:afriqueen/features/reels/screen/reels_screen.dart';
import 'package:afriqueen/features/meeting/screen/meeting_screen.dart';
import 'package:afriqueen/features/stories/screen/stories_screen.dart';
import 'package:afriqueen/features/activity/screen/activity_screen.dart';
import 'package:afriqueen/services/status/repository/status_repository.dart';
import 'package:afriqueen/features/event/bloc/event_message_bloc.dart';
import 'package:afriqueen/features/event/repository/event_message_repository.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../add/screen/add_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 2; // Meeting butonu aktif olsun (swap sonrası index 2)
  late final List<Widget> _widgets;

  @override
  void initState() {
    super.initState();
    _widgets = [
      AddScreen(), // Evenement (Event)
      const StoriesScreen(), // Story
      const MeetingScreen(), // Meeting (combines Match, Liste, Profile)
      const ActivityScreenWrapper(), // Activité (Activity)
      MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => ChatBloc(ChatRepository()),
          ),
          BlocProvider(
            create: (context) => EventMessageBloc(EventMessageRepository()),
          ),
        ],
        child: const ChatListScreen(),
      ), // Messagerie (Messaging)
    ];
    
    if (FirebaseAuth.instance.currentUser != null) {
      StatusRepository().setupUserPresence();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgets[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              color: Colors.black.withValues(alpha: 0.1),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            child: Stack(
              children: [
                GNav(
              rippleColor: AppColors.grey.withValues(alpha: 0.2),
              hoverColor: AppColors.grey.withValues(alpha: 0.2),
              gap: 4.w,
              activeColor: AppColors.orangeAccent,
              iconSize: 20.r,
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
              duration: Duration(milliseconds: 400),
              tabBackgroundColor: AppColors.lightOrange,
              color: Colors.grey.shade600,
              tabs: [
                GButton(
                  text: EnumLocale.altNavbarEvenement.name.tr,
                  textStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: AppColors.orangeAccent,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w500,
                      ),
                  iconSize: 20.r,
                  gap: 2.w,
                  icon: Icons.calendar_today_outlined,
                ),
                GButton(
                  text: EnumLocale.altNavbarStories.name.tr,
                  textStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: AppColors.orangeAccent,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w500,
                      ),
                  gap: 2.w,
                  iconSize: 20.r,
                  icon: Icons.photo_library_outlined,
                ),
                GButton(
                  text: EnumLocale.altNavbarDiscover.name.tr,
                  textStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: AppColors.orangeAccent,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w500,
                      ),
                  gap: 2.w,
                  iconSize: 20.r,
                  icon: Icons.favorite,
                ),
                GButton(
                  text: EnumLocale.altNavbarActivite.name.tr,
                  textStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: AppColors.orangeAccent,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w500,
                      ),
                  iconSize: 20.r,
                  gap: 2.w,
                  icon: Icons.access_time_outlined,
                ),
                GButton(
                  text: EnumLocale.altNavbarMessagerie.name.tr,
                  textStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: AppColors.orangeAccent,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w500,
                      ),
                  gap: 2.w,
                  iconSize: 20.r,
                  icon: CupertinoIcons.chat_bubble,
                ),
              ],
              selectedIndex: _selectedIndex,
              onTabChange: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
            ),
            ],
          ),
        ),
      ),
    ));
  }
}
