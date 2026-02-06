import 'package:afriqueen/common/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:afriqueen/common/localization/enums/enums.dart';

class DetailedFilterScreen extends StatefulWidget {
  const DetailedFilterScreen({super.key});

  @override
  State<DetailedFilterScreen> createState() => _DetailedFilterScreenState();
}

class _DetailedFilterScreenState extends State<DetailedFilterScreen> {
  RangeValues _heightRange = const RangeValues(140, 220);
  RangeValues _cityDistanceRange = const RangeValues(0, 500);

  // Simple selections
  String silhouette = '';
  String hasChildren = '';
  String wantsChildren = '';
  String hasAnimals = '';
  String alcohol = '';
  String smoking = '';
  String snoring = '';

  bool storyOnly = false;
  bool atLeast3Photos = false;

  // Generic pickers
  String createdMoreThan = 'Tous';
  String createdLessThan = 'Tous';
  String ethnicOrigin = 'Tous';
  String astroSign = 'Tous';
  String religion = 'Tous';
  String qualities = '';
  String defects = '';
  String ownedAnimals = '';
  String secondaryInterest = '';
  String passions = '';
  String hobbies = 'Tous';
  String professions = 'Tous';
  String education = 'Tous';
  String languages = 'Tous';
  String income = '';
  String city = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back, color: AppColors.black, size: 24.r),
        ),
        title: Text(
          EnumLocale.filterViewTitle.name.tr,
          style: TextStyle(
            color: AppColors.black,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            fontFamily: 'Roboto-SemiBold',
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Column(
                children: [
                  _card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _header(EnumLocale.dfHeightTitle.name.tr, trailing: EnumLocale.dfHeightTrailing.name.tr),
                        RangeSlider(
                          values: _heightRange,
                          min: 140,
                          max: 220,
                          divisions: 80,
                          activeColor: AppColors.red,
                          inactiveColor: Colors.grey.shade300,
                          onChanged: (v) => setState(() => _heightRange = v),
                        ),
                      ],
                    ),
                  ),
                  _card(
                    child: _chipRow(
                      title: EnumLocale.dfSilhouetteTitle.name.tr,
                      options: [
                        EnumLocale.dfSilhouetteMince.name.tr,
                        EnumLocale.dfSilhouetteSvelte.name.tr,
                        EnumLocale.dfSilhouetteRonde.name.tr,
                      ],
                      selected: silhouette,
                      onSelect: (v) => setState(() => silhouette = v),
                    ),
                  ),
                  _card(
                    child: _chipRow(
                      title: EnumLocale.dfHasChildrenTitle.name.tr,
                      options: [EnumLocale.yes.name.tr, EnumLocale.no.name.tr],
                      selected: hasChildren,
                      onSelect: (v) => setState(() => hasChildren = v),
                    ),
                  ),
                  _card(
                    child: _chipRow(
                      title: EnumLocale.dfWantsChildrenTitle.name.tr,
                      options: [EnumLocale.yes.name.tr, EnumLocale.no.name.tr],
                      selected: wantsChildren,
                      onSelect: (v) => setState(() => wantsChildren = v),
                    ),
                  ),
                  _card(
                    child: _chipRow(
                      title: EnumLocale.dfHasAnimalsTitle.name.tr,
                      options: [EnumLocale.yes.name.tr, EnumLocale.no.name.tr],
                      selected: hasAnimals,
                      onSelect: (v) => setState(() => hasAnimals = v),
                    ),
                  ),
                  _card(
                    child: _chipRow(
                      title: EnumLocale.dfAlcoholTitle.name.tr,
                      options: [EnumLocale.yes.name.tr, EnumLocale.no.name.tr, EnumLocale.dfOptionSometimes.name.tr],
                      selected: alcohol,
                      onSelect: (v) => setState(() => alcohol = v),
                    ),
                  ),
                  _card(
                    child: _chipRow(
                      title: EnumLocale.dfSmokingTitle.name.tr,
                      options: [EnumLocale.yes.name.tr, EnumLocale.no.name.tr, EnumLocale.dfOptionSometimes.name.tr],
                      selected: smoking,
                      onSelect: (v) => setState(() => smoking = v),
                    ),
                  ),
                  _card(
                    child: _chipRow(
                      title: EnumLocale.dfSnoringTitle.name.tr,
                      options: [
                        EnumLocale.yes.name.tr,
                        EnumLocale.no.name.tr,
                        EnumLocale.dfOptionSometimes.name.tr,
                        EnumLocale.dontKnow.name.tr,
                      ],
                      selected: snoring,
                      onSelect: (v) => setState(() => snoring = v),
                    ),
                  ),

                  // Switch rows
                  _tileSwitch(EnumLocale.dfStoryOnlyTitle.name.tr, storyOnly, (v) => setState(() => storyOnly = v)),
                  _tileSwitch(EnumLocale.dfAtLeast3PhotosTitle.name.tr, atLeast3Photos, (v) => setState(() => atLeast3Photos = v)),

                  // Simple pickers (as list tiles with trailing text and chevron)
                  _pickerTile(EnumLocale.dfCreatedMoreThanTitle.name.tr, createdMoreThan),
                  _pickerTile(EnumLocale.dfCreatedLessThanTitle.name.tr, createdLessThan),
                  _pickerTile(EnumLocale.dfEthnicOriginTitle.name.tr, ethnicOrigin),
                  _pickerTile(EnumLocale.dfAstroSignTitle.name.tr, astroSign),
                  _pickerTile(EnumLocale.dfReligionTitle.name.tr, religion),
                  _pickerTile(EnumLocale.dfQualitiesTitle.name.tr, qualities.isEmpty ? 'Tous' : qualities),
                  _pickerTile(EnumLocale.dfDefectsTitle.name.tr, defects.isEmpty ? 'Tous' : defects),
                  _pickerTile(EnumLocale.dfOwnedAnimalsTitle.name.tr, ownedAnimals.isEmpty ? 'Tous' : ownedAnimals),
                  _pickerTile(EnumLocale.dfSecondaryInterestTitle.name.tr, secondaryInterest.isEmpty ? 'Tous' : secondaryInterest),
                  _pickerTile(EnumLocale.dfPassionsTitle.name.tr, passions.isEmpty ? 'Tous' : passions),
                  _pickerTile(EnumLocale.dfHobbiesTitle.name.tr, hobbies),
                  _pickerTile(EnumLocale.dfProfessionsTitle.name.tr, professions),
                  _pickerTile(EnumLocale.dfEducationTitle.name.tr, education),
                  _pickerTile(EnumLocale.dfLanguagesTitle.name.tr, languages),
                  _pickerTile(EnumLocale.dfIncomeTitle.name.tr, income.isEmpty ? 'Tous' : income),
                  _pickerTile(EnumLocale.dfCityTitle.name.tr, city.isEmpty ? 'Tous' : city),

                  _card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _header(EnumLocale.dfCityDistanceTitle.name.tr, trailing: EnumLocale.dfCityDistanceTrailing.name.tr),
                        RangeSlider(
                          values: _cityDistanceRange,
                          min: 0,
                          max: 500,
                          divisions: 50,
                          activeColor: AppColors.red,
                          inactiveColor: Colors.grey.shade300,
                          onChanged: (v) => setState(() => _cityDistanceRange = v),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 12.h),
                  Center(
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7BD8E),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        EnumLocale.filterBasicOnly.name.tr,
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13.sp),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.primaryColor),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                    ),
                    child: Text(
                      EnumLocale.retour.name.tr,
                      style: TextStyle(color: AppColors.primaryColor, fontSize: 14.sp, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF7BD8E),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      elevation: 0,
                    ),
                    child: Text(EnumLocale.filterApply.name.tr, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: child,
    );
  }

  Widget _header(String title, {String? trailing}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(color: AppColors.black, fontSize: 12.sp, fontWeight: FontWeight.w600)),
        if (trailing != null)
          Text(trailing, style: TextStyle(color: AppColors.black, fontSize: 11.sp, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _chipRow({required String title, required List<String> options, required String selected, required Function(String) onSelect}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(color: AppColors.black, fontSize: 12.sp, fontWeight: FontWeight.w600)),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 12.w,
          runSpacing: 8.h,
          children: options.map((o) => _chip(o, selected == o, () => onSelect(o))).toList(),
        )
      ],
    );
  }

  Widget _chip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 12.w),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF7BD8E) : Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: isSelected ? const Color(0xFFF7BD8E) : Colors.grey.shade300),
        ),
        child: Text(
          label,
          style: TextStyle(color: const Color(0xFF181A1F), fontSize: 10.sp, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  Widget _tileSwitch(String title, bool value, Function(bool) onChanged) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8.r),
        color: Colors.white,
      ),
      child: ListTile(
        title: Text(title, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500)),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.primaryColor,
          inactiveThumbColor: Colors.white,
          inactiveTrackColor: Colors.grey.shade300,
        ),
      ),
    );
  }

  Widget _pickerTile(String title, String value) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8.r),
        color: Colors.white,
      ),
      child: ListTile(
        title: Text(title, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(value, style: TextStyle(color: Colors.grey[700], fontSize: 12.sp)),
            SizedBox(width: 8.w),
            Icon(Icons.arrow_forward_ios, size: 16.r, color: AppColors.black),
          ],
        ),
        onTap: () {},
      ),
    );
  }
}


