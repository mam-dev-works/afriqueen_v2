import 'package:afriqueen/common/constant/constant_colors.dart';
import 'package:afriqueen/common/localization/enums/enums.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class MainInterestScreen extends StatefulWidget {
  final List<String>? initialSelections;
  
  const MainInterestScreen({super.key, this.initialSelections});

  @override
  State<MainInterestScreen> createState() => _MainInterestScreenState();
}

class _MainInterestScreenState extends State<MainInterestScreen> {
  List<String> _selectedInterests = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialSelections != null) {
      _selectedInterests = List.from(widget.initialSelections!);
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
          onPressed: () => Get.back(),
          icon: Icon(
            Icons.close,
            color: AppColors.black,
            size: 24.r,
          ),
        ),
        title: Text(
          'Intérêt principal',
          style: TextStyle(
            color: AppColors.black,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            fontFamily: 'Montserrat',
          ),
        ),
        centerTitle: true,
      ),
             body: Padding(
         padding: EdgeInsets.all(16.w),
         child: Column(
           children: [
             // First row
             Row(
               children: [
                 Expanded(
                   child: _buildInterestButton(
                     EnumLocale.mainInterestMeetings.name.tr,
                     _selectedInterests.contains(EnumLocale.mainInterestMeetings.name.tr),
                     () => setState(() {
                       if (_selectedInterests.contains(EnumLocale.mainInterestMeetings.name.tr)) {
                         _selectedInterests.remove(EnumLocale.mainInterestMeetings.name.tr);
                       } else {
                         _selectedInterests.add(EnumLocale.mainInterestMeetings.name.tr);
                       }
                     }),
                   ),
                 ),
                 SizedBox(width: 12.w),
                 Expanded(
                   child: _buildInterestButton(
                     EnumLocale.mainInterestChat.name.tr,
                     _selectedInterests.contains(EnumLocale.mainInterestChat.name.tr),
                     () => setState(() {
                       if (_selectedInterests.contains(EnumLocale.mainInterestChat.name.tr)) {
                         _selectedInterests.remove(EnumLocale.mainInterestChat.name.tr);
                       } else {
                         _selectedInterests.add(EnumLocale.mainInterestChat.name.tr);
                       }
                     }),
                   ),
                 ),
                 SizedBox(width: 12.w),
                 Expanded(
                   child: _buildInterestButton(
                     EnumLocale.mainInterestSeriousStory.name.tr,
                     _selectedInterests.contains(EnumLocale.mainInterestSeriousStory.name.tr),
                     () => setState(() {
                       if (_selectedInterests.contains(EnumLocale.mainInterestSeriousStory.name.tr)) {
                         _selectedInterests.remove(EnumLocale.mainInterestSeriousStory.name.tr);
                       } else {
                         _selectedInterests.add(EnumLocale.mainInterestSeriousStory.name.tr);
                       }
                     }),
                   ),
                 ),
               ],
             ),
             SizedBox(height: 12.h),
             // Second row
             Row(
               children: [
                 Expanded(
                   child: _buildInterestButton(
                     EnumLocale.mainInterestFriendship.name.tr,
                     _selectedInterests.contains(EnumLocale.mainInterestFriendship.name.tr),
                     () => setState(() {
                       if (_selectedInterests.contains(EnumLocale.mainInterestFriendship.name.tr)) {
                         _selectedInterests.remove(EnumLocale.mainInterestFriendship.name.tr);
                       } else {
                         _selectedInterests.add(EnumLocale.mainInterestFriendship.name.tr);
                       }
                     }),
                   ),
                 ),
                 SizedBox(width: 12.w),
                 Expanded(
                   child: _buildInterestButton(
                     EnumLocale.mainInterestFlirt.name.tr,
                     _selectedInterests.contains(EnumLocale.mainInterestFlirt.name.tr),
                     () => setState(() {
                       if (_selectedInterests.contains(EnumLocale.mainInterestFlirt.name.tr)) {
                         _selectedInterests.remove(EnumLocale.mainInterestFlirt.name.tr);
                       } else {
                         _selectedInterests.add(EnumLocale.mainInterestFlirt.name.tr);
                       }
                     }),
                   ),
                 ),
                 SizedBox(width: 12.w),
                 Expanded(
                   child: _buildInterestButton(
                     EnumLocale.mainInterestAdventure.name.tr,
                     _selectedInterests.contains(EnumLocale.mainInterestAdventure.name.tr),
                     () => setState(() {
                       if (_selectedInterests.contains(EnumLocale.mainInterestAdventure.name.tr)) {
                         _selectedInterests.remove(EnumLocale.mainInterestAdventure.name.tr);
                       } else {
                         _selectedInterests.add(EnumLocale.mainInterestAdventure.name.tr);
                       }
                     }),
                   ),
                 ),
               ],
             ),
             SizedBox(height: 12.h),
             // Third row with "Tous" option
             Row(
               children: [
                 Expanded(
                   child: _buildInterestButton(
                     'Tous',
                     _selectedInterests.contains('Tous'),
                     () => setState(() {
                       if (_selectedInterests.contains('Tous')) {
                         _selectedInterests.remove('Tous');
                       } else {
                         _selectedInterests.add('Tous');
                       }
                     }),
                   ),
                 ),
                 SizedBox(width: 12.w),
                 Expanded(child: SizedBox()), // Empty space
                 SizedBox(width: 12.w),
                 Expanded(child: SizedBox()), // Empty space
               ],
             ),
             SizedBox(height: 32.h),
             // Termine button in the middle
             SizedBox(
               width: double.infinity,
               height: 48.h,
               child: ElevatedButton(
                                   onPressed: () {
                    // Return the selected interests
                    Get.back(result: _selectedInterests);
                  },
                 style: ElevatedButton.styleFrom(
                   backgroundColor: Color(0xFFF7BD8E),
                   foregroundColor: AppColors.white,
                   shape: RoundedRectangleBorder(
                     borderRadius: BorderRadius.circular(24.r),
                   ),
                   elevation: 0,
                 ),
                 child: Text(
                   'TERMINÉ',
                   style: TextStyle(
                     fontSize: 16.sp,
                     fontWeight: FontWeight.w600,
                     fontFamily: 'Montserrat',
                   ),
                 ),
               ),
             ),
           ],
         ),
       ),
    );
  }

  Widget _buildInterestButton(String text, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48.h,
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFFF7BD8E) : AppColors.white,
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(
            color: isSelected ? Color(0xFFF7BD8E) : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF181A1F),
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              fontFamily: 'Montserrat',
            ),
          ),
        ),
      ),
    );
  }
} 