import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:afriqueen/features/chat/model/chat_model.dart';
import 'package:afriqueen/features/chat/bloc/chat_bloc.dart';
import 'package:afriqueen/common/theme/app_colors.dart';
import 'package:afriqueen/common/localization/enums/enums.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RequestChatItem extends StatelessWidget {
  final ChatModel chat;

  const RequestChatItem({
    Key? key,
    required this.chat,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final otherUser = chat.participants.firstWhere(
      (user) => user['id'] != currentUserId,
    );

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: AppColors.primaryColor.withOpacity(0.2),
              width: 1.w,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48.w,
                    height: 48.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primaryColor.withOpacity(0.2),
                        width: 2.w,
                      ),
                    ),
                    child: ClipOval(
                      child: otherUser['photoUrl'] != null && otherUser['photoUrl'].toString().isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: otherUser['photoUrl'],
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: AppColors.grey.withOpacity(0.2),
                                child: Icon(
                                  Icons.person,
                                  size: 20.sp,
                                  color: AppColors.grey,
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: AppColors.grey.withOpacity(0.2),
                                child: Icon(
                                  Icons.person,
                                  size: 20.sp,
                                  color: AppColors.grey,
                                ),
                              ),
                            )
                          : Container(
                              color: AppColors.grey.withOpacity(0.2),
                              child: Icon(
                                Icons.person,
                                size: 20.sp,
                                color: AppColors.grey,
                              ),
                            ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          otherUser['name'] ?? '',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16.sp,
                            color: AppColors.primaryColor,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          timeago.format(
                            chat.lastMessageTime ?? DateTime.now(),
                            locale: Get.locale?.languageCode ?? 'en',
                          ),
                          style: TextStyle(
                            color: AppColors.grey,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (chat.lastMessage != null && chat.lastMessage!.isNotEmpty) ...[
                SizedBox(height: 16.h),
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: AppColors.primaryColor.withOpacity(0.1),
                      width: 1.w,
                    ),
                  ),
                  child: Text(
                    chat.lastMessage!,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
              SizedBox(height: 20.h),
              chat.isDeclined
                  ? Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: AppColors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: AppColors.grey.withOpacity(0.3),
                          width: 1.w,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.block,
                            color: AppColors.grey,
                            size: 20.sp,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            EnumLocale.userBlockedText.name.tr,
                            style: TextStyle(
                              color: AppColors.grey,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 48.h,
                            child: ElevatedButton(
                              onPressed: () => _acceptRequest(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryColor,
                                foregroundColor: AppColors.floralWhite,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                              ),
                              child: Text(
                                EnumLocale.accept.name.tr,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Container(
                            height: 48.h,
                            child: OutlinedButton(
                              onPressed: () => _declineRequest(context),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.grey,
                                side: BorderSide(
                                  color: AppColors.grey.withOpacity(0.5),
                                  width: 1.w,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                              ),
                              child: Text(
                                EnumLocale.reject.name.tr,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                ),
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
  }

  void _acceptRequest(BuildContext context) async {
    try {
      // Use ChatBloc to accept request
      context.read<ChatBloc>().add(AcceptRequestChat(chat.id));
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(EnumLocale.requestAccepted.name.tr),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(EnumLocale.defaultError.name.tr),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _declineRequest(BuildContext context) async {
    try {
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      final otherUser = chat.participants.firstWhere(
        (user) => user['id'] != currentUserId,
      );
      final otherUserId = otherUser['id'];

      // Use ChatBloc to decline request
      context.read<ChatBloc>().add(DeclineRequestChat(
        chatId: chat.id,
        otherUserId: otherUserId,
      ));

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(EnumLocale.userSuccessfullyBlockedText.name.tr),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(EnumLocale.defaultError.name.tr),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
} 