// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:afriqueen/common/constant/constant_colors.dart';
import 'package:afriqueen/common/widgets/seniority.dart';
import 'package:afriqueen/features/archive/bloc/archive_bloc.dart';
import 'package:afriqueen/features/archive/bloc/archive_event.dart';
import 'package:afriqueen/features/archive/repository/archive_repository.dart';
import 'package:afriqueen/features/favorite/bloc/favorite_bloc.dart';
import 'package:afriqueen/features/favorite/bloc/favorite_event.dart';
import 'package:afriqueen/features/favorite/repository/favorite_repository.dart';
import 'package:afriqueen/features/home/model/home_model.dart';
import 'package:afriqueen/features/user_details/widgets/user_details_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:afriqueen/common/localization/enums/enums.dart';
import 'package:afriqueen/routes/app_routes.dart';
import 'package:afriqueen/features/gifts/screen/send_gifts_screen.dart';
import 'package:afriqueen/features/activity/repository/user_profile_repository.dart';

class UserDetailsScreen extends StatefulWidget {
  UserDetailsScreen({super.key, required this.data});

  final HomeModel data;

  @override
  State<UserDetailsScreen> createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  bool _isScrollingUp = false;
  double _previousOffset = 0;
  final UserProfileRepository _userProfileRepository = UserProfileRepository();

  @override
  void initState() {
    super.initState();
    // Mark user as viewed when profile screen opens
    _markUserAsViewed();
  }

  Future<void> _markUserAsViewed() async {
    try {
      await _userProfileRepository.markUserAsViewed(widget.data.id);
      print('UserDetailsScreen: Marked user ${widget.data.id} as viewed');
    } catch (e) {
      print('UserDetailsScreen: Error marking user ${widget.data.id} as viewed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final date = Seniority.formatJoinedTime(widget.data.createdDate);
    final hasValidUrl = widget.data.photos.first.isNotEmpty &&
        Uri.tryParse(widget.data.photos.first)?.hasAbsolutePath == true;
    return MultiRepositoryProvider(
        providers: [
          RepositoryProvider(
            create: (context) => FavoriteRepository(),
          ),
          RepositoryProvider(
            create: (context) => ArchiveRepository(),
          ),
        ],
        child: MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) =>
                  FavoriteBloc(repository: context.read<FavoriteRepository>())
                    ..add(FavoriteUsersFetched()),
            ),
            BlocProvider(
              create: (context) =>
                  ArchiveBloc(repository: context.read<ArchiveRepository>())
                    ..add(ArchiveUsersFetched()),
            ),
          ],
          child: Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: Column(
                children: [
                  // Header with back button and title
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Get.back(),
                          icon: Icon(Icons.arrow_back, color: Colors.black),
                        ),
                        Expanded(
                          child: Text(
                            EnumLocale.userDetailsTitle.name.tr,
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(width: 48.w), // Balance the back button
                      ],
                    ),
                  ),
                  
                  // Main content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Profile Images Section
                          ProfileImageGallery(widget: widget, hasValidUrl: hasValidUrl),
                          SizedBox(height: 16.h),
                          
                          // Action Buttons
                          ActionButtonsRow(model: widget.data),
                          SizedBox(height: 16.h),
                          
                          // Basic Info Section
                          BasicInfoSection(userDetailsScreen: widget, date: date),
                          SizedBox(height: 16.h),
                          
                          // Send Gift Button
                          Center(
                            child: GestureDetector(
                              onTap: () {
                                print('UserDetailsScreen: Navigating to Send Gifts with data: ${widget.data.name} (ID: ${widget.data.id})');
                                Get.to(() => const SendGiftsScreen(), arguments: widget.data);
                              },
                            child: Container(
                              width: double.infinity,
                              height: 48.h,
                              decoration: BoxDecoration(
                                color: AppColors.red,
                                borderRadius: BorderRadius.circular(24.r),
                              ),
                              child: Center(
                                child: Text(
                                  EnumLocale.userDetailsSendGifts.name.tr,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 24.h),
                          
                          // Information Categories
                          Text(
                            EnumLocale.userDetailsInformation.name.tr,
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          InformationCategories(),
                          SizedBox(height: 24.h),
                          
                          // Description Section
                          DescriptionSection(widget: widget),
                          SizedBox(height: 24.h),
                          
                          // What Looking For Section
                          WhatLookingForSection(widget: widget),
                          SizedBox(height: 24.h),
                          
                          // What Not Want Section
                          WhatNotWantSection(widget: widget),
                          SizedBox(height: 24.h),
                          
                          // Story Section
                          StorySection(),
                          SizedBox(height: 24.h),
                          
                          // Events Section
                          EventsSection(),
                          SizedBox(height: 24.h),
                        ],
                      ),
                    ),
                  ),
                  
                  // Bottom Back Button
                  Container(
                    padding: EdgeInsets.all(16.w),
                    child: GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        width: double.infinity,
                        height: 48.h,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24.r),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Center(
                          child: Text(
                            EnumLocale.userDetailsBack.name.tr,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
