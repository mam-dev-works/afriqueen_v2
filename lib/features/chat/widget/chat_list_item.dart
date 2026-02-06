import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:afriqueen/features/chat/model/chat_model.dart';
import 'package:afriqueen/features/chat/screen/chat_screen.dart';
import 'package:afriqueen/features/chat/bloc/chat_bloc.dart';
import 'package:afriqueen/features/chat/repository/chat_repository.dart';
import 'package:afriqueen/common/theme/app_colors.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChatListItem extends StatelessWidget {
  final ChatModel chat;

  const ChatListItem({
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
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16.r),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => RepositoryProvider(
                  create: (context) => ChatRepository(),
                  child: BlocProvider(
                    create: (context) => ChatBloc(ChatRepository()),
                    child: ChatScreen(
                      chatId: chat.id,
                      receiverId: otherUser['id'],
                      receiverName: otherUser['name'],
                      receiverPhotoUrl: otherUser['photoUrl'],
                    ),
                  ),
                ),
              ),
            );
          },
          child: Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: AppColors.grey.withOpacity(0.1),
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
            child: Row(
              children: [
                // Profile Image
                Container(
                  width: 56.w,
                  height: 56.w,
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
                                size: 24.sp,
                                color: AppColors.grey,
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: AppColors.grey.withOpacity(0.2),
                              child: Icon(
                                Icons.person,
                                size: 24.sp,
                                color: AppColors.grey,
                              ),
                            ),
                          )
                        : Container(
                            color: AppColors.grey.withOpacity(0.2),
                            child: Icon(
                              Icons.person,
                              size: 24.sp,
                              color: AppColors.grey,
                            ),
                          ),
                  ),
                ),
                
                SizedBox(width: 16.w),
                
                // Chat Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name and Time
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              otherUser['name'] ?? '',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16.sp,
                                color: AppColors.primaryColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
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
                      
                      SizedBox(height: 6.h),
                      
                      // Last Message
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              chat.lastMessage ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: AppColors.grey,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                          
                          // Unread Count Badge
                          if (chat.unreadCount > 0) ...[
                            SizedBox(width: 8.w),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 4.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor,
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Text(
                                chat.unreadCount.toString(),
                                style: TextStyle(
                                  color: AppColors.floralWhite,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12.sp,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 