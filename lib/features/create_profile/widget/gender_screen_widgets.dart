import 'package:afriqueen/features/create_profile/bloc/create_profile_bloc.dart';
import 'package:afriqueen/features/create_profile/bloc/create_profile_event.dart';
import 'package:afriqueen/features/create_profile/bloc/create_profile_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../common/localization/enums/enums.dart';

class GenderScreenWidget extends StatelessWidget {
  const GenderScreenWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CreateProfileBloc, CreateProfileState>(
      builder: (context, state) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 24.h),
              // Gender selection
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _GenderCard(
                    label: EnumLocale.genderMale.name.tr,
                    icon: CupertinoIcons.person,
                    selected: state.gender == EnumLocale.genderMale.name.tr,
                    onTap: () => context.read<CreateProfileBloc>().add(GenderChanged(gender: EnumLocale.genderMale.name.tr)),
                  ),
                  SizedBox(width: 24.w),
                  _GenderCard(
                    label: EnumLocale.genderFemale.name.tr,
                    icon: CupertinoIcons.person,
                    selected: state.gender == EnumLocale.genderFemale.name.tr,
                    onTap: () => context.read<CreateProfileBloc>().add(GenderChanged(gender: EnumLocale.genderFemale.name.tr)),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              // Selected gender text
              Text(
                state.gender == EnumLocale.genderFemale.name.tr
                    ? EnumLocale.genderFemaleSelectedText.name.tr
                    : state.gender == EnumLocale.genderMale.name.tr
                        ? EnumLocale.genderMaleSelectedText.name.tr
                        : '',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  fontSize: 12.sp,
                  height: 1.0,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 24.h),
              // Orientation toggle buttons
              _OrientationToggle(
                selected: state.orientation,
                onChanged: (value) => context.read<CreateProfileBloc>().add(OrientationChanged(orientation: value)),
              ),
              SizedBox(height: 32.h),
              // Relationship status
              Center(
                child: Text(
                  EnumLocale.relationshipStatusTitle.name.tr,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    fontSize: 20.sp,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 12.h),
              _RelationshipStatusGrid(
                selected: state.relationshipStatus,
                onChanged: (value) => context.read<CreateProfileBloc>().add(RelationshipStatusChanged(status: value)),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _GenderCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  const _GenderCard({required this.label, required this.icon, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120.w,
        height: 100.h,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFF8F1ED) : Colors.white,
          border: Border.all(
            color: selected ? const Color(0xFFB85C38) : const Color(0xFFE0E0E0),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: selected ? const Color(0xFFB85C38) : Colors.grey, size: 32),
            SizedBox(height: 8.h),
            Text(
              label,
              style: TextStyle(
                color: selected ? const Color(0xFFB85C38) : Colors.black,
                fontWeight: FontWeight.w600,
                fontSize: 16.sp,
              ),
            ),
            if (selected)
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: EdgeInsets.only(top: 4, right: 8),
                  child: Icon(Icons.radio_button_checked, color: const Color(0xFFB85C38), size: 18),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _OrientationToggle extends StatelessWidget {
  final String? selected;
  final ValueChanged<String> onChanged;
  const _OrientationToggle({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final options = [
      EnumLocale.orientationHetero.name.tr,
      EnumLocale.orientationHomo.name.tr,
      EnumLocale.orientationBi.name.tr,
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: options.map((opt) {
        final isSelected = selected == opt;
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.w),
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              backgroundColor: isSelected ? const Color(0xFFB85C38) : Colors.white,
              side: BorderSide(color: isSelected ? const Color(0xFFB85C38) : Colors.grey, width: 1.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
            ),
            onPressed: () => onChanged(opt),
            child: Text(
              opt,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: FontWeight.w600,
                fontSize: 15.sp,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _RelationshipStatusGrid extends StatelessWidget {
  final String? selected;
  final ValueChanged<String> onChanged;
  const _RelationshipStatusGrid({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final options = [
      EnumLocale.relationshipSingle.name.tr,
      EnumLocale.relationshipCouple.name.tr,
      EnumLocale.relationshipFiance.name.tr,
      EnumLocale.relationshipMarried.name.tr,
      EnumLocale.relationshipUnionLibre.name.tr,
      EnumLocale.relationshipDivorced.name.tr,
    ];
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      mainAxisSpacing: 14.h,
      crossAxisSpacing: 50.w,
      childAspectRatio: 102 / 24,
      physics: const NeverScrollableScrollPhysics(),
      children: options.map((opt) {
        final isSelected = selected == opt;
        return GestureDetector(
          onTap: () => onChanged(opt),
          child: SizedBox(
            width: 102.w,
            height: 24.h,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Checkbox(
                  value: isSelected,
                  onChanged: (_) => onChanged(opt),
                  activeColor: const Color(0xFFB85C38),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
                Flexible(
                  child: Text(
                    opt,
                    style: TextStyle(
                      color: isSelected ? const Color(0xFFB85C38) : Colors.black,
                      fontWeight: FontWeight.w500,
                      fontSize: 14.sp,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// You will need to add OrientationChanged and RelationshipStatusChanged events to your CreateProfileBloc if not already present.
