import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:afriqueen/features/chat/model/message_request_model.dart';
import 'package:afriqueen/features/chat/bloc/chat_bloc.dart';
import 'package:afriqueen/common/theme/app_colors.dart';
import 'package:afriqueen/common/localization/enums/enums.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MessageRequestItem extends StatelessWidget {
  final MessageRequestModel request;

  const MessageRequestItem({
    Key? key,
    required this.request,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                      child: request.senderPhotoUrl != null && request.senderPhotoUrl!.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: request.senderPhotoUrl!,
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
                          request.senderName,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16.sp,
                            color: AppColors.primaryColor,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          timeago.format(
                            request.timestamp,
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
                  request.content,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              request.isRejected
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
                            "You've rejected this request",
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
                              onPressed: () {
                                context.read<ChatBloc>().add(AcceptMessageRequest(request.id));
                              },
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
                              onPressed: () {
                                context.read<ChatBloc>().add(RejectMessageRequest(request.id));
                              },
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
} 