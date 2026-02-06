import 'package:flutter/material.dart';
import '../model/edit_profile_model.dart';
import 'package:afriqueen/common/constant/constant_colors.dart';
import 'package:afriqueen/common/constant/constant_strings.dart';
import 'package:afriqueen/common/localization/enums/enums.dart';
import 'package:choice/choice.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PhysicalFields extends StatefulWidget {
  final EditProfileModel? model;
  const PhysicalFields({super.key, required this.model});

  @override
  State<PhysicalFields> createState() => _PhysicalFieldsState();
}

class _PhysicalFieldsState extends State<PhysicalFields> {
  final TextEditingController ageController = TextEditingController();
  final TextEditingController sizeController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  String? selectedSilhouette;
  List<String> selectedEthnicOrigins = [];

  @override
  void initState() {
    super.initState();
    // Initialize with existing values if any
    ageController.text = widget.model?.age?.toString() ?? '';
    sizeController.text = widget.model?.size?.toString() ?? '';
    weightController.text = widget.model?.weight?.toString() ?? '';
    selectedSilhouette = widget.model?.silhouette;
    selectedEthnicOrigins = widget.model?.ethnicOrigin ?? [];
  }

  @override
  void dispose() {
    ageController.dispose();
    sizeController.dispose();
    weightController.dispose();
    super.dispose();
  }

  void updateModel() {
    widget.model?.age = int.tryParse(ageController.text);
    widget.model?.size = double.tryParse(sizeController.text);
    widget.model?.weight = double.tryParse(weightController.text);
    widget.model?.silhouette = selectedSilhouette;
    widget.model?.ethnicOrigin = selectedEthnicOrigins;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Physical Info Card
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

                    // Size
                    Text(
                      EnumLocale.size.name.tr,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    TextField(
                      controller: sizeController,
                      keyboardType: TextInputType.number,
                      style: TextStyle(fontSize: 12.sp),
                      decoration: InputDecoration(
                        hintText: EnumLocale.enterSize.name.tr,
                        hintStyle: TextStyle(fontSize: 12.sp),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        contentPadding: EdgeInsets.all(12.r),
                      ),
                      onChanged: (value) => updateModel(),
                    ),
                    SizedBox(height: 16.h),

                    // Weight
                    Text(
                      EnumLocale.weight.name.tr,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    TextField(
                      controller: weightController,
                      keyboardType: TextInputType.number,
                      style: TextStyle(fontSize: 12.sp),
                      decoration: InputDecoration(
                        hintText: EnumLocale.enterWeight.name.tr,
                        hintStyle: TextStyle(fontSize: 12.sp),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        contentPadding: EdgeInsets.all(12.r),
                      ),
                      onChanged: (value) => updateModel(),
                    ),
                    SizedBox(height: 16.h),

                    // Silhouette
                    Text(
                      EnumLocale.silhouette.name.tr,
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
                        value: selectedSilhouette != null && AppStrings.silhouettes.contains(selectedSilhouette)
                            ? selectedSilhouette
                            : null,
                        isExpanded: true,
                        underline: const SizedBox(),
                        style: TextStyle(fontSize: 12.sp, color: Colors.black),
                        hint: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12.w),
                          child: Text(
                            EnumLocale.selectSilhouette.name.tr,
                            style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                          ),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        items: AppStrings.silhouettes
                            .map((silhouette) => DropdownMenuItem(
                                  value: silhouette,
                                  child: Text(silhouette),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedSilhouette = value;
                            updateModel();
                          });
                        },
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // Ethnic Origin
                    Text(
                      EnumLocale.ethnicOrigin.name.tr,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Choice<String>.prompt(
                      multiple: true,
                      value: selectedEthnicOrigins,
                      onChanged: (value) {
                        if (value.length <= 2) {
                          setState(() {
                            selectedEthnicOrigins = value;
                            updateModel();
                          });
                        }
                      },
                      itemCount: AppStrings.ethnicOrigins.length,
                      itemBuilder: (state, i) {
                        final item = AppStrings.ethnicOrigins[i];
                        final selected = state.selected(item);
                        final isLimitReached = state.value.length >= 2 && !selected;
                        return CheckboxListTile(
                          dense: true,
                          activeColor: AppColors.primaryColor,
                          value: selected,
                          onChanged: isLimitReached ? null : state.onSelected(item),
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
                                EnumLocale.selectEthnicOrigin.name.tr,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              IconButton(
                                onPressed: () => Get.back(),
                                icon: Icon(
                                  selectedEthnicOrigins.isNotEmpty
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
                                selectedEthnicOrigins.isEmpty
                                    ? EnumLocale.selectEthnicOrigin.name.tr
                                    : selectedEthnicOrigins.join(', '),
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