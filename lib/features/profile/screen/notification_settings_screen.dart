import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:afriqueen/common/localization/enums/enums.dart';
import 'package:afriqueen/common/theme/app_colors.dart';
import 'package:afriqueen/routes/app_routes.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  // Messaging notifications
  bool messageNotification = false;
  bool messageRequestNotification = false;
  bool notificationMessageNotification = false;
  bool adminMessageNotification = false;
  bool eventMessageNotification = false;
  bool archiveMessageNotification = false;

  // Activity notifications
  bool profileViewNotification = false;
  bool likeNotification = false;
  bool matchNotification = false;
  bool giftsReceivedNotification = false;
  bool storyViewNotification = false;
  bool storyLikeNotification = false;
  bool eventParticipationNotification = false;
  bool myEventParticipationsNotification = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 20.sp,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          EnumLocale.notificationSettingsTitle.name.tr,
          style: TextStyle(
            color: Colors.black,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          children: [
            SizedBox(height: 20.h),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Messaging Section
                    _buildSectionHeader(EnumLocale.notificationMessaging.name.tr),
                    SizedBox(height: 16.h),
                    _buildNotificationItem(
                      EnumLocale.notificationMessage.name.tr,
                      messageNotification,
                      (value) => setState(() => messageNotification = value),
                    ),
                    _buildNotificationItem(
                      EnumLocale.notificationMessageRequest.name.tr,
                      messageRequestNotification,
                      (value) => setState(() => messageRequestNotification = value),
                    ),
                    _buildNotificationItem(
                      EnumLocale.notificationNotificationMessage.name.tr,
                      notificationMessageNotification,
                      (value) => setState(() => notificationMessageNotification = value),
                    ),
                    _buildNotificationItem(
                      EnumLocale.notificationAdminMessage.name.tr,
                      adminMessageNotification,
                      (value) => setState(() => adminMessageNotification = value),
                    ),
                    _buildNotificationItem(
                      EnumLocale.notificationEventMessage.name.tr,
                      eventMessageNotification,
                      (value) => setState(() => eventMessageNotification = value),
                    ),
                    _buildNotificationItem(
                      EnumLocale.notificationArchiveMessage.name.tr,
                      archiveMessageNotification,
                      (value) => setState(() => archiveMessageNotification = value),
                    ),
                    
                    SizedBox(height: 32.h),
                    
                    // Activity Section
                    _buildSectionHeader(EnumLocale.notificationActivity.name.tr),
                    SizedBox(height: 16.h),
                    _buildNotificationItem(
                      EnumLocale.notificationProfileView.name.tr,
                      profileViewNotification,
                      (value) => setState(() => profileViewNotification = value),
                    ),
                    _buildNotificationItem(
                      EnumLocale.notificationLike.name.tr,
                      likeNotification,
                      (value) => setState(() => likeNotification = value),
                    ),
                    _buildNotificationItem(
                      EnumLocale.notificationMatch.name.tr,
                      matchNotification,
                      (value) => setState(() => matchNotification = value),
                    ),
                    _buildNotificationItem(
                      EnumLocale.notificationGiftsReceived.name.tr,
                      giftsReceivedNotification,
                      (value) => setState(() => giftsReceivedNotification = value),
                    ),
                    _buildNotificationItem(
                      EnumLocale.notificationStoryView.name.tr,
                      storyViewNotification,
                      (value) => setState(() => storyViewNotification = value),
                    ),
                    _buildNotificationItem(
                      EnumLocale.notificationStoryLike.name.tr,
                      storyLikeNotification,
                      (value) => setState(() => storyLikeNotification = value),
                    ),
                    _buildNotificationItem(
                      EnumLocale.notificationEventParticipation.name.tr,
                      eventParticipationNotification,
                      (value) => setState(() => eventParticipationNotification = value),
                    ),
                    _buildNotificationItem(
                      EnumLocale.notificationMyEventParticipations.name.tr,
                      myEventParticipationsNotification,
                      (value) => setState(() => myEventParticipationsNotification = value),
                    ),
                    
                    SizedBox(height: 40.h),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10.h),
            // Back button
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: (Get.width * 0.5) - 16.w, // Half width minus padding
                height: 44.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: AppColors.primaryColor),
                ),
                child: TextButton(
                  onPressed: () => Get.back(),
                  child: Text(
                    EnumLocale.notificationBack.name.tr,
                    style: TextStyle(
                      color: AppColors.primaryColor,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        color: Colors.black,
        fontSize: 16.sp,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildNotificationItem(String title, bool value, Function(bool) onChanged) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: Colors.black,
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primaryColor,
            inactiveThumbColor: Colors.grey[300],
            inactiveTrackColor: Colors.grey[200],
          ),
        ],
      ),
    );
  }
}
