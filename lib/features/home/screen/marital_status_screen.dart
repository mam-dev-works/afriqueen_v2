import 'package:afriqueen/common/constant/constant_colors.dart';
import 'package:afriqueen/common/localization/enums/enums.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class MaritalStatusScreen extends StatefulWidget {
  final List<String>? initialSelections;
  
  const MaritalStatusScreen({super.key, this.initialSelections});

  @override
  State<MaritalStatusScreen> createState() => _MaritalStatusScreenState();
}

class _MaritalStatusScreenState extends State<MaritalStatusScreen> {
  List<String> _selectedStatuses = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialSelections != null) {
      _selectedStatuses = List.from(widget.initialSelections!);
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
          'Statut matrimonial',
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
                   child: _buildStatusButton(
                     EnumLocale.relationshipSingle.name.tr,
                     _selectedStatuses.contains(EnumLocale.relationshipSingle.name.tr),
                     () => setState(() {
                       if (_selectedStatuses.contains(EnumLocale.relationshipSingle.name.tr)) {
                         _selectedStatuses.remove(EnumLocale.relationshipSingle.name.tr);
                       } else {
                         _selectedStatuses.add(EnumLocale.relationshipSingle.name.tr);
                       }
                     }),
                   ),
                 ),
                 SizedBox(width: 12.w),
                 Expanded(
                   child: _buildStatusButton(
                     EnumLocale.relationshipCouple.name.tr,
                     _selectedStatuses.contains(EnumLocale.relationshipCouple.name.tr),
                     () => setState(() {
                       if (_selectedStatuses.contains(EnumLocale.relationshipCouple.name.tr)) {
                         _selectedStatuses.remove(EnumLocale.relationshipCouple.name.tr);
                       } else {
                         _selectedStatuses.add(EnumLocale.relationshipCouple.name.tr);
                       }
                     }),
                   ),
                 ),
                 SizedBox(width: 12.w),
                 Expanded(
                   child: _buildStatusButton(
                     EnumLocale.relationshipFiance.name.tr,
                     _selectedStatuses.contains(EnumLocale.relationshipFiance.name.tr),
                     () => setState(() {
                       if (_selectedStatuses.contains(EnumLocale.relationshipFiance.name.tr)) {
                         _selectedStatuses.remove(EnumLocale.relationshipFiance.name.tr);
                       } else {
                         _selectedStatuses.add(EnumLocale.relationshipFiance.name.tr);
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
                   child: _buildStatusButton(
                     EnumLocale.relationshipMarried.name.tr,
                     _selectedStatuses.contains(EnumLocale.relationshipMarried.name.tr),
                     () => setState(() {
                       if (_selectedStatuses.contains(EnumLocale.relationshipMarried.name.tr)) {
                         _selectedStatuses.remove(EnumLocale.relationshipMarried.name.tr);
                       } else {
                         _selectedStatuses.add(EnumLocale.relationshipMarried.name.tr);
                       }
                     }),
                   ),
                 ),
                 SizedBox(width: 12.w),
                 Expanded(
                   child: _buildStatusButton(
                     EnumLocale.relationshipUnionLibre.name.tr,
                     _selectedStatuses.contains(EnumLocale.relationshipUnionLibre.name.tr),
                     () => setState(() {
                       if (_selectedStatuses.contains(EnumLocale.relationshipUnionLibre.name.tr)) {
                         _selectedStatuses.remove(EnumLocale.relationshipUnionLibre.name.tr);
                       } else {
                         _selectedStatuses.add(EnumLocale.relationshipUnionLibre.name.tr);
                       }
                     }),
                   ),
                 ),
                 SizedBox(width: 12.w),
                 Expanded(
                   child: _buildStatusButton(
                     'Séparé(e)',
                     _selectedStatuses.contains('Séparé(e)'),
                     () => setState(() {
                       if (_selectedStatuses.contains('Séparé(e)')) {
                         _selectedStatuses.remove('Séparé(e)');
                       } else {
                         _selectedStatuses.add('Séparé(e)');
                       }
                     }),
                   ),
                 ),
               ],
             ),
             SizedBox(height: 12.h),
             // Third row
             Row(
               children: [
                 Expanded(
                   child: _buildStatusButton(
                     EnumLocale.relationshipDivorced.name.tr,
                     _selectedStatuses.contains(EnumLocale.relationshipDivorced.name.tr),
                     () => setState(() {
                       if (_selectedStatuses.contains(EnumLocale.relationshipDivorced.name.tr)) {
                         _selectedStatuses.remove(EnumLocale.relationshipDivorced.name.tr);
                       } else {
                         _selectedStatuses.add(EnumLocale.relationshipDivorced.name.tr);
                       }
                     }),
                   ),
                 ),
                 SizedBox(width: 12.w),
                 Expanded(
                   child: _buildStatusButton(
                     'Tous',
                     _selectedStatuses.contains('Tous'),
                     () => setState(() {
                       if (_selectedStatuses.contains('Tous')) {
                         _selectedStatuses.remove('Tous');
                       } else {
                         _selectedStatuses.add('Tous');
                       }
                     }),
                   ),
                 ),
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
                    // Return the selected statuses
                    Get.back(result: _selectedStatuses);
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

  Widget _buildStatusButton(String text, bool isSelected, VoidCallback onTap) {
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