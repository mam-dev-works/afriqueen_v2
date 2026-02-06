import 'package:afriqueen/features/event/model/event_message_model.dart';
import 'package:afriqueen/common/theme/app_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:timeago/timeago.dart' as timeago;

class EventMessageItem extends StatelessWidget {
  final EventMessageModel message;
  final VoidCallback? onTap;

  const EventMessageItem({
    super.key,
    required this.message,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Picture
            Container(
              width: 50.w,
              height: 50.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.shade300,
                image: message.senderPhotoUrl.isNotEmpty
                    ? DecorationImage(
                        image: CachedNetworkImageProvider(message.senderPhotoUrl),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: message.senderPhotoUrl.isEmpty
                  ? Icon(
                      Icons.person,
                      size: 24.sp,
                      color: Colors.grey.shade600,
                    )
                  : null,
            ),
            
            SizedBox(width: 12.w),
            
            // Message Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sender name and time
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        message.senderName,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.black,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        _formatTimeAgo(message.timestamp),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 4.h),
                  
                  // Event title with bold formatting
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                      children: [
                        TextSpan(text: 'Votre évènement : '),
                        TextSpan(
                          text: message.eventTitle,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.black,
                          ),
                        ),
                      ],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  SizedBox(height: 6.h),
                  
                  // Message content
                  Text(
                    message.content,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.black,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  SizedBox(height: 8.h),
                  
                  // Event status indicator
                  if (message.isEventFinished)
                    Text(
                      'Evenement terminé',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ),
            
            SizedBox(width: 8.w),
            
            // Event image thumbnail
            Container(
              width: 60.w,
              height: 60.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.r),
                color: Colors.grey.shade300,
                image: message.eventImageUrl.isNotEmpty
                    ? DecorationImage(
                        image: CachedNetworkImageProvider(message.eventImageUrl),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: message.eventImageUrl.isEmpty
                  ? Icon(
                      Icons.event,
                      size: 24.sp,
                      color: Colors.grey.shade600,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inDays > 0) {
      return 'Reçu il y a ${difference.inDays}j';
    } else if (difference.inHours > 0) {
      return 'Reçu il y a ${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return 'Reçu il y a ${difference.inMinutes}min';
    } else {
      return 'Reçu maintenant';
    }
  }
}
