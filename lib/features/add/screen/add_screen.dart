import 'package:afriqueen/common/constant/constant_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:afriqueen/features/event/model/event_model.dart';
import 'package:afriqueen/features/event/repository/event_repository.dart';
// Removed: create_event import (not used here)
import 'package:afriqueen/features/event/widget/event_card.dart';
import 'package:get/get.dart';
import 'package:afriqueen/routes/app_routes.dart';
import 'package:afriqueen/common/localization/enums/enums.dart';
import 'package:afriqueen/features/event/screen/my_events_screen.dart';

class AddScreen extends StatefulWidget {
  const AddScreen({super.key, this.initialFilter = 2});

  // 0: A deux, 1: En groupe, 2: Tous
  final int initialFilter;

  @override
  State<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  int _selectedFilter = 2; // 0: A deux, 1: En groupe, 2: Tous
  final List<GlobalKey> _itemKeys = [];
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedFilter = widget.initialFilter;
  }

  String get _appBarTitle {
    switch (_selectedFilter) {
      case 0:
        return '${EnumLocale.eventAppTitlePrefix.name.tr}${EnumLocale.duoText.name.tr}';
      case 1:
        return '${EnumLocale.eventAppTitlePrefix.name.tr}${EnumLocale.groupText.name.tr}';
      default:
        return '${EnumLocale.eventAppTitlePrefix.name.tr}${EnumLocale.allText.name.tr}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.toNamed(AppRoutes.profileHome),
          icon: const Icon(Icons.home_outlined, color: Colors.black),
        ),
        title: Text(
          _appBarTitle,
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 16.sp,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none, color: Colors.black),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.tune_outlined, color: Colors.black),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const MyEventsScreen()),
                  );
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE0CC),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Text(
                    EnumLocale.myEvents.name.tr,
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                      fontSize: 12.sp,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 8.h),
            SizedBox(
              height: 34.h,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildChip(EnumLocale.duoText.name.tr, 0),
                  SizedBox(width: 12.w),
                  _buildChip(EnumLocale.groupText.name.tr, 1),
                  SizedBox(width: 12.w),
                  _buildChip(EnumLocale.allText.name.tr, 2),
                ],
              ),
            ),
            SizedBox(height: 12.h),
            _buildEventsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String text, int index) {
    final bool selected = _selectedFilter == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = index;
          _currentIndex = 0;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFF7BD8E) : Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  EventStatus? _statusFromIndex() {
    switch (_selectedFilter) {
      case 0:
        return EventStatus.DUO;
      case 1:
        return EventStatus.GROUP;
      default:
        return null; // Tous
    }
  }

  Widget _buildEventsList() {
    return StreamBuilder<List<EventModel>>(
      stream: EventRepository().streamEvents(status: _statusFromIndex()),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 40.h),
            child: Center(
              child: Text('${EnumLocale.errorPrefix.name.tr}${snapshot.error}', style: TextStyle(fontSize: 12.sp, color: Colors.red)),
            ),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final events = snapshot.data ?? const <EventModel>[];
        if (events.isEmpty) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 40.h),
            child: Center(
              child: Text(EnumLocale.noEvents.name.tr, style: TextStyle(fontSize: 14.sp)),
            ),
          );
        }
        // Ensure we have keys for each item so we can scroll to next on play
        _currentIndex = _currentIndex.clamp(0, events.length - 1);
        return Column(
          children: [
            EventCard(
              key: (_itemKeys.isNotEmpty && _currentIndex < _itemKeys.length)
                  ? _itemKeys[_currentIndex]
                  : null,
              event: events[_currentIndex],
              onNext: () {
                setState(() => _currentIndex = (_currentIndex + 1) % events.length);
              },
            ),
            if (events.length > 1)
              Padding(
                padding: EdgeInsets.only(top: 8.h),
                child: Text('${_currentIndex + 1}/${events.length}', style: TextStyle(fontSize: 12.sp, color: Colors.grey[700])),
              ),
          ],
        );
      },
    );
  }
}
 