import 'package:afriqueen/common/constant/constant_colors.dart';
import 'package:afriqueen/common/localization/enums/enums.dart';
import 'package:afriqueen/features/home/model/home_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class ReportProfileUserHeader extends StatelessWidget {
  const ReportProfileUserHeader({super.key, required this.user});

  final HomeModel user;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          _buildAvatar(),
          SizedBox(width: 12.w),
          Expanded(child: _buildUserInfo(context)),
          _buildStatusChip(context),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    final hasPhoto = user.photos.isNotEmpty && user.photos.first.isNotEmpty;
    return ClipRRect(
      borderRadius: BorderRadius.circular(40.r),
      child: SizedBox(
        width: 56.w,
        height: 56.w,
        child: hasPhoto
            ? CachedNetworkImage(
                imageUrl: user.photos.first,
                fit: BoxFit.cover,
              )
            : Container(
                color: Colors.grey.shade300,
                child: Icon(
                  Icons.person,
                  size: 32.r,
                  color: Colors.grey.shade600,
                ),
              ),
      ),
    );
  }

  Widget _buildUserInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          user.pseudo.isNotEmpty ? user.pseudo : user.name,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        SizedBox(height: 2.h),
        Text(
          '${user.age} ${EnumLocale.userDetailsAgeSuffix.name.tr}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        SizedBox(height: 2.h),
        Text(
          _formatLastActive(user.lastActive),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade600,
              ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.primaryColor),
        color: AppColors.primaryColor.withOpacity(0.08),
      ),
      child: Text(
        EnumLocale.message.name.tr,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.primaryColor,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  String _formatLastActive(DateTime lastActive) {
    final now = DateTime.now();
    final difference = now.difference(lastActive);

    if (difference.inDays > 0) {
      return '${EnumLocale.derniereConnexion.name.tr} ${difference.inDays}${EnumLocale.derniereConnexionJ.name.tr}';
    } else if (difference.inHours > 0) {
      return '${EnumLocale.derniereConnexion.name.tr} ${difference.inHours}${EnumLocale.derniereConnexionH.name.tr}';
    } else if (difference.inMinutes > 0) {
      return '${EnumLocale.derniereConnexion.name.tr} ${difference.inMinutes}${EnumLocale.derniereConnexionM.name.tr}';
    } else {
      return EnumLocale.derniereConnexionInstant.name.tr;
    }
  }
}

