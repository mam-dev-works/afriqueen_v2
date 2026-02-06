import 'package:afriqueen/common/constant/constant_colors.dart';
import 'package:afriqueen/common/localization/enums/enums.dart';
import 'package:afriqueen/common/widgets/premium_info_dialog.dart';
import 'package:afriqueen/features/event/model/event_model.dart';
import 'package:afriqueen/features/event/repository/event_repository.dart';
import 'package:afriqueen/features/event/screen/create_event_screen.dart';
import 'package:afriqueen/features/event/widget/event_card.dart';
import 'package:afriqueen/services/premium_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class MyEventsScreen extends StatefulWidget {
  const MyEventsScreen({super.key});

  @override
  State<MyEventsScreen> createState() => _MyEventsScreenState();
}

class _MyEventsScreenState extends State<MyEventsScreen> {
  final PremiumService _premiumService = PremiumService();

  Future<void> _handleCreateEvent() async {
    try {
      // Debug user status
      await _premiumService.debugUserStatus();
      
      final hasReachedLimit = await _premiumService.hasReachedEventLimit();
      
      if (hasReachedLimit) {
        // Show premium info dialog
        PremiumInfoDialog.show(context);
      } else {
        // Navigate to create event screen
        await Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const CreateEventScreen()),
        );
      }
    } catch (e) {
      // On error, show premium dialog as fallback
      PremiumInfoDialog.show(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: const SizedBox.shrink(),
        centerTitle: true,
        title: Text(
          EnumLocale.myEvents.name.tr,
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
        ),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (uid == null)
              Expanded(
                child: Center(
                  child: Text(EnumLocale.defaultError.name.tr),
                ),
              )
            else
              Expanded(
                child: StreamBuilder<List<EventModel>>(
                  stream: EventRepository().streamEventsByCreator(uid),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final events = snapshot.data ?? <EventModel>[];
                    // Ensure newest first, fallback to createdAt if date is same
                    events.sort((a, b) {
                      final cmp = b.date.compareTo(a.date);
                      if (cmp != 0) return cmp;
                      final aCreated = a.createdAt ?? a.date;
                      final bCreated = b.createdAt ?? b.date;
                      return bCreated.compareTo(aCreated);
                    });

                    // Build exactly 5 slots as per design
                    final int totalSlots = 5;
                    return ListView.separated(
                      itemCount: totalSlots,
                      separatorBuilder: (_, __) => SizedBox(height: 12.h),
                      itemBuilder: (context, index) {
                        final EventModel? event = index < events.length ? events[index] : null;
                        if (event != null) {
                          return _EventRow(event: event);
                        }
                        return _CreateRow(onCreate: _handleCreateEvent);
                      },
                    );
                  },
                ),
              ),
            SizedBox(height: 8.h),
            Padding(
              padding: EdgeInsets.only(bottom: 48.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    height: 36.h,
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.black,
                        backgroundColor: Colors.white,
                        side: BorderSide(color: AppColors.primaryColor.withOpacity(0.6), width: 1),
                        shape: const StadiumBorder(),
                        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
                        minimumSize: Size(0, 36.h),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        EnumLocale.retour.name.tr,
                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 12.sp),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 36.h,
                    child: ElevatedButton(
                      onPressed: _handleCreateEvent,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6B6FB2),
                        elevation: 0,
                        shadowColor: Colors.transparent,
                        shape: const StadiumBorder(),
                        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
                        minimumSize: Size(0, 36.h),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        EnumLocale.creer.name.tr,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EventRow extends StatelessWidget {
  const _EventRow({required this.event});

  final EventModel event;

  String _twoDigits(int n) => n.toString().padLeft(2, '0');

  String _formatDate(DateTime d) {
    // Example: Samedi 28 septembre, 19h00
    final day = _twoDigits(d.day);
    final month = _monthName(d.month);
    final hour = _twoDigits(d.hour);
    final minute = _twoDigits(d.minute);
    return '$day $month, ${hour}h$minute';
  }

  String _monthName(int m) {
    const months = [
      'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
      'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'
    ];
    return months[(m - 1).clamp(0, 11)];
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Thumbnail
        ClipRRect(
          borderRadius: BorderRadius.circular(8.r),
          child: Container(
            width: 48.w,
            height: 48.h,
            color: Colors.grey.shade300,
            child: event.imageUrl != null
                ? Image.network(event.imageUrl!, fit: BoxFit.cover)
                : const SizedBox.shrink(),
          ),
        ),
        SizedBox(width: 8.w),
        // Details
        Expanded(
          child: Container(
            height: 48.h,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8.r),
            ),
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            child: FittedBox(
              alignment: Alignment.centerLeft,
              fit: BoxFit.scaleDown,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.sp),
                  ),
                  Text(
                    '${EnumLocale.eventDateLabel.name.tr} ${_formatDate(event.date)}',
                    style: TextStyle(fontSize: 11.sp, color: Colors.black87),
                  ),
                  Text(
                    '${EnumLocale.eventPlaceLabel.name.tr} ${event.location}',
                    style: TextStyle(fontSize: 11.sp, color: Colors.black87),
                  ),
                  if (event.maxParticipants != null)
                    Text(
                      '${EnumLocale.eventParticipantsCountLabel.name.tr} ${event.maxParticipants}',
                      style: TextStyle(fontSize: 11.sp, color: Colors.black87),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CreateRow extends StatelessWidget {
  const _CreateRow({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 48.w,
          height: 48.h,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Container(
            height: 48.h,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Center(
              child: ElevatedButton.icon(
                onPressed: onCreate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6B6FB2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.r)),
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                  elevation: 0,
                ),
                icon: const Icon(Icons.add, size: 16, color: Colors.white),
                label: Text(
                  EnumLocale.creer.name.tr,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}


