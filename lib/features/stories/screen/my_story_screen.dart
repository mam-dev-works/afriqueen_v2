import 'package:afriqueen/common/constant/constant_colors.dart';
import 'package:afriqueen/common/localization/enums/enums.dart';
import 'package:afriqueen/features/stories/bloc/stories_bloc.dart';
import 'package:afriqueen/features/stories/bloc/stories_event.dart';
import 'package:afriqueen/features/stories/bloc/stories_state.dart';
import 'package:afriqueen/features/stories/model/stories_model.dart';
import 'package:afriqueen/features/stories/repository/stories_repository.dart';
import 'package:afriqueen/features/stories/screen/create_story_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class MyStoryScreen extends StatelessWidget {
  const MyStoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (context) => StoriesRepository()),
      ],
      child: BlocProvider(
        create: (context) {
          final bloc = StoriesBloc(repo: context.read<StoriesRepository>());
          // Force fresh fetch from Firebase, ignoring cache
          bloc.add(StoriesRefresh());
          return bloc;
        },
        child: BlocBuilder<StoriesBloc, StoriesState>(
          builder: (context, state) {
            // Show loading while fetching data
            if (state is StoriesInitial) {
              return Scaffold(
                backgroundColor: AppColors.white,
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
            
            final currentUserId = FirebaseAuth.instance.currentUser?.uid;
            print('MyStoryScreen - Current user ID: $currentUserId');
            print('MyStoryScreen - Available stories: ${state.data.length}');
            
            // Debug: print all story IDs
            for (var story in state.data) {
              print('MyStoryScreen - Story ID: ${story.id}, UserName: ${story.userName}');
            }
            
            final userStory = state.data.where((story) => story.id == currentUserId).firstOrNull;
            print('MyStoryScreen - User story found: ${userStory != null}');
            
            if (userStory != null) {
              print('MyStoryScreen - User story has containUrl: ${userStory.containUrl.isNotEmpty}');
              print('MyStoryScreen - User story has imageUrl: ${userStory.imageUrl != null && userStory.imageUrl!.isNotEmpty}');
              
              if (userStory.containUrl.isNotEmpty || (userStory.imageUrl != null && userStory.imageUrl!.isNotEmpty)) {
                // User has a story, show the story view
                print('MyStoryScreen - Showing story view');
                return _buildStoryView(userStory);
              }
            }
            
            // User doesn't have a story, show create story screen
            print('MyStoryScreen - Showing create story screen');
            return CreateStoryScreen();
          },
        ),
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${EnumLocale.publieIlY.name.tr} ${difference.inDays}${EnumLocale.publieJ.name.tr}';
    } else if (difference.inHours > 0) {
      return '${EnumLocale.publieIlY.name.tr} ${difference.inHours}${EnumLocale.publieH.name.tr}';
    } else if (difference.inMinutes > 0) {
      return '${EnumLocale.publieIlY.name.tr} ${difference.inMinutes}${EnumLocale.publieMin.name.tr}';
    } else {
      return EnumLocale.publieInstant.name.tr;
    }
  }

  Future<void> _deleteStory(StoriesFetchModel story) async {
    try {
      // Get the current user ID
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      if (currentUserId == null) {
        Get.snackbar(
          EnumLocale.errorWithMessage.name.tr,
          EnumLocale.utilisateurNonConnecte.name.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // Delete story from Firebase
      final storiesRepository = StoriesRepository();
      
      // Find and delete the story document
      final storyQuery = await storiesRepository.firestore
          .collection('stories')
          .where('uid', isEqualTo: currentUserId)
          .get();

      if (storyQuery.docs.isNotEmpty) {
        // Delete all stories for this user
        for (var doc in storyQuery.docs) {
          await doc.reference.delete();
        }
        
        // Navigate back to previous screen (not the dialog, but the previous page)
        Get.back(); // Close dialog
        
        // Show success message after a short delay to avoid snackbar conflicts
        Future.delayed(Duration(milliseconds: 300), () {
          Get.snackbar(
            EnumLocale.updateSuccessMessage.name.tr,
            EnumLocale.storySupprimee.name.tr,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: Duration(seconds: 2),
          );
        });
        
        // Navigate back to previous page after a short delay
        Future.delayed(Duration(milliseconds: 500), () {
          Get.back(); // Go back to previous page
        });
      } else {
        Get.snackbar(
          EnumLocale.errorWithMessage.name.tr,
          EnumLocale.storyNonTrouvee.name.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        EnumLocale.errorWithMessage.name.tr,
        '${EnumLocale.erreurSuppression.name.tr} ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Widget _buildStoryView(StoriesFetchModel story) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          EnumLocale.maStoryTitle.name.tr,
          style: TextStyle(
            color: AppColors.black,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            fontFamily: 'Roboto-SemiBold',
          ),
        ),
        actions: [],
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(
            Icons.arrow_back,
            color: AppColors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main Story Image with Delete Icon
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 350.h,
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
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12.r),
                    child: (story.imageUrl != null && story.imageUrl!.isNotEmpty) || story.containUrl.isNotEmpty
                        ? Image.network(
                            story.imageUrl ?? story.containUrl.first,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey.shade300,
                                child: Icon(
                                  Icons.image,
                                  size: 80.r,
                                  color: Colors.grey,
                                ),
                              );
                            },
                          )
                        : Container(
                            color: Colors.grey.shade300,
                            child: Icon(
                              Icons.image,
                              size: 80.r,
                              color: Colors.grey,
                            ),
                          ),
                  ),
                ),
                // Delete Icon positioned at top-right corner
                Positioned(
                  top: 8.h,
                  right: 8.w,
                  child: GestureDetector(
                    onTap: () {
                      // Delete story confirmation dialog
                      Get.dialog(
                        Dialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Container(
                            padding: EdgeInsets.all(20.w),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  EnumLocale.etesVousSur.name.tr,
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.black,
                                  ),
                                ),
                                SizedBox(height: 20.h),
                                Divider(height: 1, color: Colors.grey.shade300),
                                SizedBox(height: 20.h),
                                Row(
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () => Get.back(),
                                        child: Text(
                                          EnumLocale.non.name.tr,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w500,
                                            color: AppColors.black,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      height: 20.h,
                                      width: 1,
                                      color: Colors.grey.shade300,
                                    ),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          // Delete story from Firebase
                                          _deleteStory(story);
                                          Get.back();
                                        },
                                        child: Text(
                                          EnumLocale.oui.name.tr,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w500,
                                            color: AppColors.black,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Icon(
                        Icons.delete,
                        color: Colors.white,
                        size: 20.r,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 16.h),
            
            // Description Text
            if (story.text != null && story.text!.isNotEmpty)
              Text(
                story.text!,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.black,
                  height: 1.4,
                ),
              ),
            
            SizedBox(height: 16.h),
            
            // Engagement Metrics (Likes only)
            Row(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.favorite,
                      color: Colors.red,
                      size: 20.r,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      '26',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Spacer(),
                Text(
                  _getTimeAgo(story.createdDate.isNotEmpty ? story.createdDate.first : DateTime.now()),
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 8.h),
            
            // Requests Count
            Text(
              '${EnumLocale.nombreDemande.name.tr} 23',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.black,
              ),
            ),
            
            SizedBox(height: 16.h),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.black,
                      side: BorderSide(color: Color(0xFFF7BD8E)),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      EnumLocale.retour.name.tr,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate to create story screen
                      Get.toNamed('/create-story');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFF7BD8E),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      EnumLocale.creer.name.tr,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 