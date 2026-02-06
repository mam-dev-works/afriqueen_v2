import 'package:afriqueen/features/event/model/event_model.dart';
import 'package:afriqueen/features/event/screen/event_participation_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:afriqueen/features/profile/model/profile_model.dart';
import 'package:afriqueen/features/profile/repository/profile_repository.dart';
import 'package:get/get.dart';
import 'package:afriqueen/common/localization/enums/enums.dart';

class EventCard extends StatelessWidget {
  const EventCard({super.key, required this.event, this.onNext});

  final EventModel event;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.shade200),
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
          // Header with avatar and creator info
          FutureBuilder<ProfileModel?>(
            future: ProfileRepository().fetchUserDataById(event.creatorId),
            builder: (context, snap) {
              final profile = snap.data;
              final String displayName = profile != null && (profile.toMap().containsKey('name') || profile.toMap().containsKey('surname'))
                  ? '${(profile.toMap()['name'] ?? '').toString().trim()} ${(profile.toMap()['surname'] ?? '').toString().trim()}'.trim()
                  : (profile?.pseudo ?? '');
              final String nameAge = (displayName.isNotEmpty ? displayName : EnumLocale.utilisateur.name.tr) + (profile != null && profile.age > 0 ? ', ${profile.age}' : '');
              final ImageProvider<Object> avatar = (profile != null && profile.imgURL.isNotEmpty)
                  ? (NetworkImage(profile.imgURL) as ImageProvider<Object>)
                  : (const AssetImage('assets/images/couple.png') as ImageProvider<Object>);
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 26.r,
                    backgroundImage: avatar,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                nameAge,
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            Text(
                              '2.5 km',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          '${EnumLocale.derniereConnexion.name.tr}: ${'il y a'.tr} 2h',
                          style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade700),
                        ),
                        Text(
                          EnumLocale.chercheRelationSerieuse.name.tr,
                          style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade700),
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          '${EnumLocale.eventOrganizedPrefix.name.tr} 6',
                          style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade800),
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          '${EnumLocale.eventToDoPrefix.name.tr} ${event.status == EventStatus.DUO ? EnumLocale.duoText.name.tr : EnumLocale.groupText.name.tr}',
                          style: TextStyle(fontSize: 12.sp, color: Colors.black, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          SizedBox(height: 12.h),
          Center(
            child: Text(
              event.title,
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700),
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(EnumLocale.eventDateLabel.name.tr, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.sp)),
                    SizedBox(height: 2.h),
                    Text(_formatDate(event.date), style: TextStyle(fontSize: 12.sp)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(EnumLocale.eventPlaceLabel.name.tr, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.sp)),
                    SizedBox(height: 2.h),
                    Text(event.location, style: TextStyle(fontSize: 12.sp)),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: event.imageUrl != null
                    ? Image.network(
                        event.imageUrl!,
                        height: 160.h,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                    : Image.asset(
                        'assets/images/couple.png',
                        height: 160.h,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
              ),
              Positioned(
                right: 8.w,
                top: 8.h,
                child: Column(
                  children: [
                    _circleButton(Icons.play_arrow, onPressed: onNext),
                    SizedBox(height: 10.h),
                    _circleButton(
                      Icons.auto_awesome,
                      onPressed: () {
                        Get.to(() => EventParticipationScreen(event: event));
                      },
                    ),
                    SizedBox(height: 10.h),
                    _circleButton(Icons.info_outline),
                  ],
                ),
              )
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            event.description,
            style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade800),
          ),
          SizedBox(height: 10.h),
          Text(
            '${EnumLocale.eventFeesLabel.name.tr} ${event.costCovered ? EnumLocale.eventCostCoveredYes.name.tr : EnumLocale.eventCostCoveredNo.name.tr}',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.sp),
          ),
          if (event.maxParticipants != null) ...[
            SizedBox(height: 4.h),
            Text(
              '${EnumLocale.eventParticipantsCountLabel.name.tr} ${event.maxParticipants}',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.sp),
            ),
          ],
        ],
      ),
    );
  }

  static Widget _circleButton(IconData icon, {VoidCallback? onPressed}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFE0CC),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.black),
        onPressed: onPressed,
      ),
    );
  }

  String _pad(int n) => n.toString().padLeft(2, '0');
  String _formatDate(DateTime d) => '${_pad(d.day)}/${_pad(d.month)}/${d.year}';
}


