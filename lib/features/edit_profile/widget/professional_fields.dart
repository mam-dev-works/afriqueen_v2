import 'package:flutter/material.dart';
import '../model/edit_profile_model.dart';
import 'package:afriqueen/common/constant/constant_colors.dart';
import 'package:afriqueen/common/constant/constant_strings.dart';
import 'package:afriqueen/common/localization/enums/enums.dart';
import 'package:choice/choice.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfessionalFields extends StatefulWidget {
  final EditProfileModel? model;
  const ProfessionalFields({super.key, required this.model});

  @override
  State<ProfessionalFields> createState() => _ProfessionalFieldsState();
}

class _ProfessionalFieldsState extends State<ProfessionalFields> {
  final TextEditingController occupationController = TextEditingController();
  List<String> selectedLevelOfStudy = [];
  List<String> selectedLanguages = [];
  String? selectedIncomeLevel;

  @override
  void initState() {
    super.initState();
    // Initialize with existing values if any
    occupationController.text = widget.model?.occupation ?? '';
    selectedLevelOfStudy = widget.model?.levelOfStudy ?? [];
    selectedLanguages = widget.model?.professionalLanguages ?? [];
    selectedIncomeLevel = widget.model?.incomeLevel;
  }

  @override
  void dispose() {
    occupationController.dispose();
    super.dispose();
  }

  void updateModel() {
    widget.model?.occupation = occupationController.text;
    widget.model?.levelOfStudy = selectedLevelOfStudy;
    widget.model?.professionalLanguages = selectedLanguages;
    widget.model?.incomeLevel = selectedIncomeLevel;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Professional Info Card
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
                    // Occupation
                    Text(
                      EnumLocale.occupation.name.tr,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    TextField(
                      controller: occupationController,
                      style: TextStyle(fontSize: 12.sp),
                      decoration: InputDecoration(
                        hintText: EnumLocale.enterOccupation.name.tr,
                        hintStyle: TextStyle(fontSize: 12.sp),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        contentPadding: EdgeInsets.all(12.r),
                      ),
                      onChanged: (value) => updateModel(),
                    ),
                    SizedBox(height: 16.h),

                    // Level of Study
                    Text(
                      EnumLocale.levelOfStudy.name.tr,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Choice<String>.prompt(
                      multiple: true,
                      value: selectedLevelOfStudy,
                      onChanged: (value) {
                        setState(() {
                          selectedLevelOfStudy = value;
                          updateModel();
                        });
                      },
                      itemCount: AppStrings.levelOfStudy.length,
                      itemBuilder: (state, i) {
                        final item = AppStrings.levelOfStudy[i];
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
                                EnumLocale.selectLevelOfStudy.name.tr,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              IconButton(
                                onPressed: () => Get.back(),
                                icon: Icon(
                                  selectedLevelOfStudy.isNotEmpty
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
                                selectedLevelOfStudy.isEmpty
                                    ? EnumLocale.selectLevelOfStudy.name.tr
                                    : selectedLevelOfStudy.join(', '),
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

                    // Professional Languages
                    Text(
                      EnumLocale.professionalLanguages.name.tr,
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
                                EnumLocale.selectProfessionalLanguages.name.tr,
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
                                    ? EnumLocale.selectProfessionalLanguages.name.tr
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

                    // Income Level
                    Text(
                      EnumLocale.incomeLevel.name.tr,
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
                        value: selectedIncomeLevel != null && AppStrings.incomeLevel.contains(selectedIncomeLevel)
                            ? selectedIncomeLevel
                            : null,
                        isExpanded: true,
                        underline: const SizedBox(),
                        style: TextStyle(fontSize: 12.sp, color: Colors.black),
                        hint: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12.w),
                          child: Text(
                            EnumLocale.selectIncomeLevel.name.tr,
                            style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                          ),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        items: AppStrings.incomeLevel
                            .map((level) => DropdownMenuItem(
                                  value: level,
                                  child: Text(level),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedIncomeLevel = value;
                            updateModel();
                          });
                        },
                      ),
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