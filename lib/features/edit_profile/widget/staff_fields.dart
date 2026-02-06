import 'package:flutter/material.dart';
import '../model/edit_profile_model.dart';
import 'package:afriqueen/common/constant/constant_colors.dart';
import 'package:afriqueen/common/constant/constant_strings.dart';
import 'package:afriqueen/common/localization/enums/enums.dart';
import 'package:choice/choice.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class StaffFields extends StatefulWidget {
  final EditProfileModel? model;
  const StaffFields({super.key, required this.model});

  @override
  State<StaffFields> createState() => _StaffFieldsState();
}

class _StaffFieldsState extends State<StaffFields> {
  final TextEditingController ageController = TextEditingController();
  List<String> selectedLanguages = [];
  String? selectedReligion;
  String? selectedChildrenCount;
  bool wantsChildren = false;
  List<String> selectedCharacterTraits = [];

  @override
  void initState() {
    super.initState();
    // Initialize with existing values if any
    ageController.text = widget.model?.age?.toString() ?? '';
    selectedLanguages = widget.model?.spokenLanguages ?? [];
    selectedReligion = widget.model?.religion;
    selectedChildrenCount = widget.model?.hasChildren?.toString();
    wantsChildren = widget.model?.wantChildren ?? false;
    selectedCharacterTraits = widget.model?.character ?? [];
  }

  @override
  void dispose() {
    ageController.dispose();
    super.dispose();
  }

  void updateModel() {
    widget.model?.age = int.tryParse(ageController.text);
    widget.model?.spokenLanguages = selectedLanguages;
    widget.model?.religion = selectedReligion;
    widget.model?.hasChildren = int.tryParse(selectedChildrenCount ?? '0');
    widget.model?.wantChildren = wantsChildren;
    widget.model?.character = selectedCharacterTraits;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Basic Info Card
            Card(
              color: AppColors.floralWhite,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Padding(
                padding: EdgeInsets.all(16.r),
                child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
                    // Age
                    Text(
                      EnumLocale.age.name.tr,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    TextField(
                      controller: ageController,
                      keyboardType: TextInputType.number,
                      style: TextStyle(fontSize: 12.sp),
                      decoration: InputDecoration(
                        hintText: EnumLocale.enterAge.name.tr,
                        hintStyle: TextStyle(fontSize: 12.sp),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        contentPadding: EdgeInsets.all(12.r),
                      ),
                      onChanged: (value) => updateModel(),
                    ),
                    SizedBox(height: 16.h),

                    // Spoken Languages
                    Text(
                      EnumLocale.spokenLanguages.name.tr,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Choice<String>.prompt(
                      multiple: true,
                      value: selectedLanguages,
                      onChanged: (value) {
                        setState(() {
                          selectedLanguages = value;
                          updateModel();
                        });
                      },
                      itemCount: AppStrings.language.length,
                      itemBuilder: (state, i) {
                        final item = AppStrings.language[i];
                        final selected = state.selected(item);
                        return CheckboxListTile(
                          dense: true,
                          activeColor: AppColors.primaryColor,
                          value: selected,
                          onChanged: state.onSelected(item),
                          title: Text(
                            item,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        );
                      },
                      modalHeaderBuilder: ChoiceModal.createHeader(
                        automaticallyImplyLeading: false,
                        title: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.w),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                EnumLocale.selectLanguages.name.tr,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              IconButton(
                                onPressed: () => Get.back(),
                                icon: Icon(
                                  selectedLanguages.isNotEmpty
                                      ? Icons.check_circle
                                      : Icons.cancel,
                                  color: AppColors.primaryColor,
                                  size: 20.r,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      promptDelegate: ChoicePrompt.delegateBottomSheet(
                        backgroundColor: AppColors.floralWhite,
                        maxHeightFactor: 0.5,
                      ),
                      anchorBuilder: (state, openModal) {
                        return InkWell(
                          onTap: openModal,
                          child: Container(
                            height: 50.h,
                            width: double.maxFinite,
                            padding: EdgeInsets.symmetric(horizontal: 12.w),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.primaryColor.withOpacity(0.3)),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Center(
                              child: Text(
                                selectedLanguages.isEmpty
                                    ? EnumLocale.selectLanguages.name.tr
                                    : selectedLanguages.join(', '),
                                style: Theme.of(context).textTheme.bodySmall,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 16.h),

                    // Religion
                    Text(
                      EnumLocale.religion.name.tr,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.primaryColor.withOpacity(0.3)),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: DropdownButton<String>(
                        value: selectedReligion != null && AppStrings.religions.contains(selectedReligion) 
                            ? selectedReligion 
                            : null,
                        isExpanded: true,
                        underline: const SizedBox(),
                        style: TextStyle(fontSize: 12.sp, color: Colors.black),
                        hint: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12.w),
                          child: Text(
                            EnumLocale.selectReligion.name.tr,
                            style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                          ),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        items: AppStrings.religions
                            .map((religion) => DropdownMenuItem(
                                  value: religion,
                                  child: Text(religion),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedReligion = value;
                            updateModel();
                          });
                        },
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // Has Children
                    Text(
                      EnumLocale.hasChildren.name.tr,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.primaryColor.withOpacity(0.3)),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: DropdownButton<String>(
                        value: selectedChildrenCount,
                        isExpanded: true,
                        underline: const SizedBox(),
                        style: TextStyle(fontSize: 12.sp, color: Colors.black),
                        hint: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12.w),
                          child: Text(
                            EnumLocale.selectNumberOfChildren.name.tr,
                            style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                          ),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        items: List.generate(11, (index) => index.toString())
                            .map((count) => DropdownMenuItem(
                                  value: count,
                                  child: Text(count),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedChildrenCount = value;
                            updateModel();
                          });
                        },
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // Want Children
                    Row(
                      children: [
                        Checkbox(
                          value: wantsChildren,
                          activeColor: AppColors.primaryColor,
                          onChanged: (value) {
                            setState(() {
                              wantsChildren = value ?? false;
                              updateModel();
                            });
                          },
                        ),
                        Text(
                          EnumLocale.wantChildren.name.tr,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),

                    // Character Traits
                    Text(
                      EnumLocale.characterTraits.name.tr,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Choice<String>.prompt(
                      multiple: true,
                      value: selectedCharacterTraits,
                      onChanged: (value) {
                        setState(() {
                          selectedCharacterTraits = value;
                          updateModel();
                        });
                      },
                      itemCount: AppStrings.characterTraits.length,
                      itemBuilder: (state, i) {
                        final item = AppStrings.characterTraits[i];
                        final selected = state.selected(item);
                        return CheckboxListTile(
                          dense: true,
                          activeColor: AppColors.primaryColor,
                          value: selected,
                          onChanged: state.onSelected(item),
                          title: Text(
                            item,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        );
                      },
                      modalHeaderBuilder: ChoiceModal.createHeader(
                        automaticallyImplyLeading: false,
                        title: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.w),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                EnumLocale.selectCharacterTraits.name.tr,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              IconButton(
                                onPressed: () => Get.back(),
                                icon: Icon(
                                  selectedCharacterTraits.isNotEmpty
                                      ? Icons.check_circle
                                      : Icons.cancel,
                                  color: AppColors.primaryColor,
                                  size: 20.r,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      promptDelegate: ChoicePrompt.delegateBottomSheet(
                        backgroundColor: AppColors.floralWhite,
                        maxHeightFactor: 0.5,
                      ),
                      anchorBuilder: (state, openModal) {
                        return InkWell(
                          onTap: openModal,
                          child: Container(
                            height: 50.h,
                            width: double.maxFinite,
                            padding: EdgeInsets.symmetric(horizontal: 12.w),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.primaryColor.withOpacity(0.3)),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Center(
                              child: Text(
                                selectedCharacterTraits.isEmpty
                                    ? EnumLocale.selectCharacterTraits.name.tr
                                    : selectedCharacterTraits.join(', '),
                                style: Theme.of(context).textTheme.bodySmall,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }
} 