import 'package:flutter/material.dart';
import '../model/edit_profile_model.dart';
import 'package:afriqueen/common/constant/constant_colors.dart';
import 'package:afriqueen/common/constant/constant_strings.dart';
import 'package:afriqueen/common/localization/enums/enums.dart';
import 'package:choice/choice.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class InterestFields extends StatefulWidget {
  final EditProfileModel? model;
  const InterestFields({Key? key, required this.model}) : super(key: key);

  @override
  State<InterestFields> createState() => _InterestFieldsState();
}

class _InterestFieldsState extends State<InterestFields> {
  late Map<String, List<String>> selected;
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController lookingForController = TextEditingController();
  final TextEditingController dontWantToMeetController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final userSelected = widget.model?.interests ?? [];
    selected = {};
    AppStrings.categorizedUserInterests.forEach((category, items) {
      selected[category] = items.where((item) => userSelected.contains(item)).toList();
    });

    // Initialize text controllers with existing values
    descriptionController.text = widget.model?.description ?? '';
    lookingForController.text = widget.model?.lookingFor ?? '';
    dontWantToMeetController.text = widget.model?.dontWant ?? '';
  }

  @override
  void dispose() {
    descriptionController.dispose();
    lookingForController.dispose();
    dontWantToMeetController.dispose();
    super.dispose();
  }

  void onChanged(List<String> value, String category) {
    setState(() {
      selected[category] = value;
      widget.model?.interests = selected.values.expand((e) => e).toSet().toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final categories = AppStrings.categorizedUserInterests.keys.toList();
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text Input Fields Section
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
                    // Description Section
                    Text(
                      EnumLocale.description.name.tr,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    TextField(
                      controller: descriptionController,
                      maxLines: 3,
                      style: TextStyle(fontSize: 12.sp),
                      decoration: InputDecoration(
                        hintText: EnumLocale.writeAboutYourself.name.tr,
                        hintStyle: TextStyle(fontSize: 12.sp),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        contentPadding: EdgeInsets.all(12.r),
                      ),
                      onChanged: (value) => widget.model?.description = value,
                    ),
                    SizedBox(height: 16.h),

                    // Looking For Section
                    Text(
                      EnumLocale.lookingFor.name.tr,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    TextField(
                      controller: lookingForController,
                      maxLines: 2,
                      style: TextStyle(fontSize: 12.sp),
                      decoration: InputDecoration(
                        hintText: EnumLocale.whatAreYouLookingFor.name.tr,
                        hintStyle: TextStyle(fontSize: 12.sp),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        contentPadding: EdgeInsets.all(12.r),
                      ),
                      onChanged: (value) => widget.model?.lookingFor = value,
                    ),
                    SizedBox(height: 16.h),

                    // Don't Want to Meet Section
                    Text(
                      EnumLocale.dontWantToMeet.name.tr,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    TextField(
                      controller: dontWantToMeetController,
                      maxLines: 2,
                      style: TextStyle(fontSize: 12.sp),
                      decoration: InputDecoration(
                        hintText: EnumLocale.whoDontYouWantToMeet.name.tr,
                        hintStyle: TextStyle(fontSize: 12.sp),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        contentPadding: EdgeInsets.all(12.r),
                      ),
                      onChanged: (value) => widget.model?.dontWant = value,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24.h),

            // Interests Categories Section
            Text(
              EnumLocale.interests.name.tr,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 16.h),
            ...categories.map((category) {
          final items = AppStrings.categorizedUserInterests[category]!;
              return Card(
                color: AppColors.floralWhite,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                margin: EdgeInsets.only(bottom: 12.h),
                child: Padding(
                  padding: EdgeInsets.all(12.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category == 'Friendship' ? EnumLocale.friendshipInterests.name.tr :
                        category == 'Food & Restaurants' ? EnumLocale.foodAndRestaurantsInterests.name.tr :
                        category == 'Passion & Personality' ? EnumLocale.passionAndPersonalityInterests.name.tr :
                        category == 'Love & Romance' ? EnumLocale.loveAndRomanceInterests.name.tr :
                        category == 'Sports & Outdoors' ? EnumLocale.sportsAndOutdoorsInterests.name.tr :
                        category == 'Adventure & Travel' ? EnumLocale.adventureAndTravelInterests.name.tr :
                        category,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Choice<String>.prompt(
                        multiple: true,
                        value: selected[category] ?? [],
                        onChanged: (value) => onChanged(value, category),
                        itemCount: items.length,
                        itemBuilder: (state, i) {
                          final item = items[i];
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
                              overflow: TextOverflow.ellipsis,
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
                                Expanded(
                                  child: Text(
                                    EnumLocale.chooseOption.name.tr,
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: AppColors.primaryColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => Get.back(),
                                  icon: Icon(
                                    (selected[category]?.isNotEmpty ?? false)
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
                                  (state.value.isEmpty)
                                      ? EnumLocale.chooseOption.name.tr
                                      : state.value.join(', '),
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
                );
              }).toList(),
            SizedBox(height: 24.h),
          ],
            ),
      ),
    );
  }
}
