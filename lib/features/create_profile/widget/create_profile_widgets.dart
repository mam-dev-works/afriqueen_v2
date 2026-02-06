import 'package:afriqueen/common/constant/constant_colors.dart';
import 'package:afriqueen/common/constant/constant_strings.dart';
import 'package:afriqueen/common/localization/enums/enums.dart';
import 'package:afriqueen/common/widgets/common_button.dart';
import 'package:afriqueen/common/widgets/snackbar_message.dart';
import 'package:afriqueen/features/create_profile/bloc/create_profile_bloc.dart';
import 'package:afriqueen/features/create_profile/bloc/create_profile_event.dart';
import 'package:afriqueen/features/create_profile/bloc/create_profile_state.dart';
import 'package:afriqueen/routes/app_routes.dart';
import 'package:afriqueen/services/storage/get_storage.dart';
import 'package:choice/choice.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

//----------------------------Interest screen components------------------

//-------------------Frienship inlineChoice---------------------------
class FriendshipInchoice extends StatelessWidget {
  const FriendshipInchoice({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CreateProfileBloc, CreateProfileState>(
      builder: (context, state) {
        return Card(
          color: AppColors.floralWhite,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadiusGeometry.circular(8),
          ),

          child: Center(
            child: BlocBuilder<CreateProfileBloc, CreateProfileState>(
              builder: (context, state) {
                return Choice<String>.prompt(
                  multiple: true,
                  value: state.friendship,
                  onChanged: (value) {
                    if (value.length <= 2) {
                      context.read<CreateProfileBloc>().add(
                        FriendsShipChanged(friendship: value),
                      );
                    } else {
                      // Show warning when limit is exceeded
                      snackBarMessage(
                        context,
                        EnumLocale.selectLimit.name.tr,
                        Theme.of(context),
                      );
                    }
                  },
                  itemCount:
                      AppStrings.categorizedUserInterests["Friendship"]!.length,
                  itemBuilder: (state, i) {
                    final item =
                        AppStrings.categorizedUserInterests["Friendship"]![i];
                    final selected = state.selected(item);
                    final isLimitReached = state.value.length >= 2 && !selected;

                    return CheckboxListTile(
                      activeColor: AppColors.primaryColor,
                      value: selected,
                      onChanged: isLimitReached
                          ? null // disables unselected items if limit reached
                          : state.onSelected(item),
                      title: ChoiceText(
                        style: Theme.of(context).textTheme.bodyMedium,
                        highlightColor: AppColors.floralWhite,
                        item,
                        highlight: state.search?.value,
                      ),
                    );
                  },

                  modalHeaderBuilder: ChoiceModal.createHeader(
                    automaticallyImplyLeading: false,
                    title: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 2.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            EnumLocale.chooseOption.name.tr,
                            style: Theme.of(context).textTheme.bodyLarge!
                                .copyWith(
                                  color: AppColors.primaryColor,
                                  fontSize: 19.sp,
                                ),
                          ),

                          IconButton(
                            onPressed: () => Get.back(),

                            icon: Icon(
                              state.friendship.isNotEmpty
                                  ? FontAwesomeIcons.solidCircleCheck
                                  : FontAwesomeIcons.circleXmark,
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  promptDelegate: ChoicePrompt.delegateBottomSheet(
                    backgroundColor: AppColors.floralWhite,
                    maxHeightFactor: 0.5,

                    /// Override tileBuilder to hide trailing icon and label
                  ),

                  anchorBuilder: (state, openModal) {
                    return InkWell(
                      onTap: openModal,
                      child: SizedBox(
                        height: 70.h,
                        width: double.maxFinite,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Center(
                            child: Text(
                              (state.value.isEmpty)
                                  ? EnumLocale
                                        .chooseOption
                                        .name
                                        .tr // empty text = no placeholder
                                  : state.value.join(
                                      ', ',
                                    ), // or use .label if single select
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}

//----------------Friendship text-----------------------
class FriendshipText extends StatelessWidget {
  const FriendshipText({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      EnumLocale.friendshipInterests.name.tr,
      style: Theme.of(context).textTheme.bodyMedium,
    );
  }
}

//-------------------------Title text----------------------------------
class InterestTitle extends StatelessWidget {
  const InterestTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      EnumLocale.interestTitle.name.tr,

      style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontSize: 16),
    );
  }
}

//-------------------Love inlineChoice---------------------------
class LoveInchoice extends StatelessWidget {
  const LoveInchoice({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CreateProfileBloc, CreateProfileState>(
      builder: (context, state) {
        return Card(
          color: AppColors.floralWhite,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadiusGeometry.circular(8),
          ),

          child: Center(
            child: BlocBuilder<CreateProfileBloc, CreateProfileState>(
              builder: (context, state) {
                return Choice<String>.prompt(
                  multiple: true,
                  value: state.love,
                  onChanged: (value) {
                    if (value.length <= 2) {
                      context.read<CreateProfileBloc>().add(
                        LoveChanged(love: value),
                      );
                    } else {
                      // Show warning when limit is exceeded
                      snackBarMessage(
                        context,
                        EnumLocale.selectLimit.name.tr,
                        Theme.of(context),
                      );
                    }
                  },
                  itemCount: AppStrings
                      .categorizedUserInterests["Love & Romance"]!
                      .length,
                  itemBuilder: (state, i) {
                    final item = AppStrings
                        .categorizedUserInterests["Love & Romance"]![i];
                    final selected = state.selected(item);
                    final isLimitReached = state.value.length >= 2 && !selected;

                    return CheckboxListTile(
                      activeColor: AppColors.primaryColor,
                      value: selected,
                      onChanged: isLimitReached
                          ? null // disables unselected items if limit reached
                          : state.onSelected(item),
                      title: ChoiceText(
                        style: Theme.of(context).textTheme.bodyMedium,
                        highlightColor: AppColors.floralWhite,
                        item,
                        highlight: state.search?.value,
                      ),
                    );
                  },

                  modalHeaderBuilder: ChoiceModal.createHeader(
                    automaticallyImplyLeading: false,
                    title: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 2.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            EnumLocale.chooseOption.name.tr,
                            style: Theme.of(context).textTheme.bodyLarge!
                                .copyWith(
                                  color: AppColors.primaryColor,
                                  fontSize: 19.sp,
                                ),
                          ),

                          IconButton(
                            onPressed: () => Get.back(),

                            icon: Icon(
                              state.love.isNotEmpty
                                  ? FontAwesomeIcons.solidCircleCheck
                                  : FontAwesomeIcons.circleXmark,
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  promptDelegate: ChoicePrompt.delegateBottomSheet(
                    backgroundColor: AppColors.floralWhite,
                    maxHeightFactor: 0.5,

                    /// Override tileBuilder to hide trailing icon and label
                  ),

                  anchorBuilder: (state, openModal) {
                    return InkWell(
                      onTap: openModal,
                      child: SizedBox(
                        height: 70.h,
                        width: double.maxFinite,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Center(
                            child: Text(
                              (state.value.isEmpty)
                                  ? EnumLocale
                                        .chooseOption
                                        .name
                                        .tr // empty text = no placeholder
                                  : state.value.join(
                                      ', ',
                                    ), // or use .label if single select
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}

//----------------Love text-----------------------
class LoveText extends StatelessWidget {
  const LoveText({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      EnumLocale.loveAndRomanceInterests.name.tr,
      style: Theme.of(context).textTheme.bodyMedium,
    );
  }
}

//-------------------Sports inlineChoice---------------------------
class SportsInchoice extends StatelessWidget {
  const SportsInchoice({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CreateProfileBloc, CreateProfileState>(
      builder: (context, state) {
        return Card(
          color: AppColors.floralWhite,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadiusGeometry.circular(8),
          ),

          child: Center(
            child: BlocBuilder<CreateProfileBloc, CreateProfileState>(
              builder: (context, state) {
                return Choice<String>.prompt(
                  multiple: true,
                  value: state.sports,
                  onChanged: (value) {
                    if (value.length <= 2) {
                      context.read<CreateProfileBloc>().add(
                        SportChanged(sports: value),
                      );
                    } else {
                      // Show warning when limit is exceeded
                      snackBarMessage(
                        context,
                        EnumLocale.selectLimit.name.tr,
                        Theme.of(context),
                      );
                    }
                  },
                  itemCount: AppStrings
                      .categorizedUserInterests["Sports & Outdoors"]!
                      .length,
                  itemBuilder: (state, i) {
                    final item = AppStrings
                        .categorizedUserInterests["Sports & Outdoors"]![i];
                    final selected = state.selected(item);
                    final isLimitReached = state.value.length >= 2 && !selected;

                    return CheckboxListTile(
                      activeColor: AppColors.primaryColor,
                      value: selected,
                      onChanged: isLimitReached
                          ? null // disables unselected items if limit reached
                          : state.onSelected(item),
                      title: ChoiceText(
                        style: Theme.of(context).textTheme.bodyMedium,
                        highlightColor: AppColors.floralWhite,
                        item,
                        highlight: state.search?.value,
                      ),
                    );
                  },

                  modalHeaderBuilder: ChoiceModal.createHeader(
                    automaticallyImplyLeading: false,
                    title: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 2.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            EnumLocale.chooseOption.name.tr,
                            style: Theme.of(context).textTheme.bodyLarge!
                                .copyWith(
                                  color: AppColors.primaryColor,
                                  fontSize: 19.sp,
                                ),
                          ),

                          IconButton(
                            onPressed: () => Get.back(),

                            icon: Icon(
                              state.sports.isNotEmpty
                                  ? FontAwesomeIcons.solidCircleCheck
                                  : FontAwesomeIcons.circleXmark,
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  promptDelegate: ChoicePrompt.delegateBottomSheet(
                    backgroundColor: AppColors.floralWhite,
                    maxHeightFactor: 0.5,

                    /// Override tileBuilder to hide trailing icon and label
                  ),

                  anchorBuilder: (state, openModal) {
                    return InkWell(
                      onTap: openModal,
                      child: SizedBox(
                        height: 70.h,
                        width: double.maxFinite,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Center(
                            child: Text(
                              (state.value.isEmpty)
                                  ? EnumLocale
                                        .chooseOption
                                        .name
                                        .tr // empty text = no placeholder
                                  : state.value.join(
                                      ', ',
                                    ), // or use .label if single select
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}

//----------------Sports text-----------------------
class SportsText extends StatelessWidget {
  const SportsText({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      EnumLocale.sportsAndOutdoorsInterests.name.tr,
      style: Theme.of(context).textTheme.bodyMedium,
    );
  }
}

//-------------------Food inlineChoice---------------------------
class FoodInchoice extends StatelessWidget {
  const FoodInchoice({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CreateProfileBloc, CreateProfileState>(
      builder: (context, state) {
        return Card(
          color: AppColors.floralWhite,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadiusGeometry.circular(8),
          ),

          child: Center(
            child: BlocBuilder<CreateProfileBloc, CreateProfileState>(
              builder: (context, state) {
                return Choice<String>.prompt(
                  multiple: true,
                  value: state.food,
                  onChanged: (value) {
                    if (value.length <= 2) {
                      context.read<CreateProfileBloc>().add(
                        FoodChanged(food: value),
                      );
                    } else {
                      // Show warning when limit is exceeded
                      snackBarMessage(
                        context,
                        EnumLocale.selectLimit.name.tr,
                        Theme.of(context),
                      );
                    }
                  },
                  itemCount: AppStrings
                      .categorizedUserInterests["Food & Restaurants"]!
                      .length,
                  itemBuilder: (state, i) {
                    final item = AppStrings
                        .categorizedUserInterests["Food & Restaurants"]![i];
                    final selected = state.selected(item);
                    final isLimitReached = state.value.length >= 2 && !selected;

                    return CheckboxListTile(
                      activeColor: AppColors.primaryColor,
                      value: selected,
                      onChanged: isLimitReached
                          ? null // disables unselected items if limit reached
                          : state.onSelected(item),
                      title: ChoiceText(
                        style: Theme.of(context).textTheme.bodyMedium,
                        highlightColor: AppColors.floralWhite,
                        item,
                        highlight: state.search?.value,
                      ),
                    );
                  },

                  modalHeaderBuilder: ChoiceModal.createHeader(
                    automaticallyImplyLeading: false,
                    title: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 2.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            EnumLocale.chooseOption.name.tr,
                            style: Theme.of(context).textTheme.bodyLarge!
                                .copyWith(
                                  color: AppColors.primaryColor,
                                  fontSize: 19.sp,
                                ),
                          ),

                          IconButton(
                            onPressed: () => Get.back(),

                            icon: Icon(
                              state.food.isNotEmpty
                                  ? FontAwesomeIcons.solidCircleCheck
                                  : FontAwesomeIcons.circleXmark,
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  promptDelegate: ChoicePrompt.delegateBottomSheet(
                    backgroundColor: AppColors.floralWhite,
                    maxHeightFactor: 0.5,

                    /// Override tileBuilder to hide trailing icon and label
                  ),

                  anchorBuilder: (state, openModal) {
                    return InkWell(
                      onTap: openModal,
                      child: SizedBox(
                        height: 70.h,
                        width: double.maxFinite,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Center(
                            child: Text(
                              (state.value.isEmpty)
                                  ? EnumLocale
                                        .chooseOption
                                        .name
                                        .tr // empty text = no placeholder
                                  : state.value.join(
                                      ', ',
                                    ), // or use .label if single select
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}

//----------------Food text-----------------------
class FoodText extends StatelessWidget {
  const FoodText({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      EnumLocale.foodAndRestaurantsInterests.name.tr,
      style: Theme.of(context).textTheme.bodyMedium,
    );
  }
}

//-------------------Adventure inlineChoice---------------------------
class AdventureInchoice extends StatelessWidget {
  const AdventureInchoice({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CreateProfileBloc, CreateProfileState>(
      builder: (context, state) {
        return Card(
          color: AppColors.floralWhite,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadiusGeometry.circular(8),
          ),

          child: Center(
            child: BlocBuilder<CreateProfileBloc, CreateProfileState>(
              builder: (context, state) {


                return Choice<String>.prompt(
                  multiple: true,
                  value: state.adventure,
                  onChanged: (value) {
                    if (value.length <= 2) {
                      context.read<CreateProfileBloc>().add(
                        AdventureChanged(adventure: value),
                      );
                    } else {
                      // Show warning when limit is exceeded
                      snackBarMessage(
                        context,
                        EnumLocale.selectLimit.name.tr,
                        Theme.of(context),
                      );
                    }
                  },
                  itemCount: AppStrings
                      .categorizedUserInterests["Adventure & Travel"]!
                      .length,
                  itemBuilder: (state, i) {
                    final item = AppStrings
                        .categorizedUserInterests["Adventure & Travel"]![i];
                    final selected = state.selected(item);
                    final isLimitReached = state.value.length >= 2 && !selected;

                    return CheckboxListTile(
                      activeColor: AppColors.primaryColor,
                      value: selected,
                      onChanged: isLimitReached
                          ? null // disables unselected items if limit reached
                          : state.onSelected(item),
                      title: ChoiceText(
                        style: Theme.of(context).textTheme.bodyMedium,
                        highlightColor: AppColors.floralWhite,
                        item,
                        highlight: state.search?.value,
                      ),
                    );
                  },

                  modalHeaderBuilder: ChoiceModal.createHeader(
                    automaticallyImplyLeading: false,
                    title: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 2.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            EnumLocale.chooseOption.name.tr,
                            style: Theme.of(context).textTheme.bodyLarge!
                                .copyWith(
                                  color: AppColors.primaryColor,
                                  fontSize: 19.sp,
                                ),
                          ),

                          IconButton(
                            onPressed: () => Get.back(),

                            icon: Icon(
                              state.adventure.isNotEmpty
                                  ? FontAwesomeIcons.solidCircleCheck
                                  : FontAwesomeIcons.circleXmark,
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  promptDelegate: ChoicePrompt.delegateBottomSheet(
                    backgroundColor: AppColors.floralWhite,
                    maxHeightFactor: 0.5,

                    /// Override tileBuilder to hide trailing icon and label
                  ),

                  anchorBuilder: (state, openModal) {
                    return InkWell(
                      onTap: openModal,
                      child: SizedBox(
                        height: 70.h,
                        width: double.maxFinite,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Center(
                            child: Text(
                              (state.value.isEmpty)
                                  ? EnumLocale
                                        .chooseOption
                                        .name
                                        .tr // empty text = no placeholder
                                  : state.value.join(
                                      ', ',
                                    ), // or use .label if single select
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}

//----------------Adventure text-----------------------
class AdventureText extends StatelessWidget {
  const AdventureText({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      EnumLocale.adventureAndTravelInterests.name.tr,
      style: Theme.of(context).textTheme.bodyMedium,
    );
  }
}

//-----------------Next Button---------------
class InterestsNextButton extends StatelessWidget {
  InterestsNextButton({super.key});
  final AppGetStorage app = AppGetStorage();
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CreateProfileBloc, CreateProfileState>(
      builder: (context, state) {
        return CommonButton(
          onPressed: () {
            if (state.friendship.isNotEmpty &&
                state.love.isNotEmpty &&
                state.sports.isNotEmpty) {
              app.setPageNumber(7);
              Get.toNamed(AppRoutes.passion);
            } else {
              snackBarMessage(
                context,
                EnumLocale.interestsRequired.name.tr,
                Theme.of(context),
              );
            }
          },
          buttonText: EnumLocale.next.name.tr,
        );
      },
    );
  }
}

//-------------------------PassionTitle text----------------------------------
class PassionTitle extends StatelessWidget {
  const PassionTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      EnumLocale.passion.name.tr,
      style: Theme.of(context).textTheme.bodyMedium,
    );
  }
}

//------------------ Passion choice-------------------
class PassionChoice extends StatelessWidget {
  const PassionChoice({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.floralWhite,

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.circular(8),
      ),

      child: Center(
        child: BlocBuilder<CreateProfileBloc, CreateProfileState>(
          builder: (context, state) {
            return Choice<String>.prompt(
              multiple: true,
              value: state.passion,
              onChanged: (value) {
                if (value.length <= 2) {
                  context.read<CreateProfileBloc>().add(
                    PassionChanged(passion: value),
                  );
                } else {
                  // Show warning when limit is exceeded
                  snackBarMessage(
                    context,
                    EnumLocale.selectLimit.name.tr,
                    Theme.of(context),
                  );
                }
              },
              itemCount: AppStrings.categorizedUserInterests["Passion"]!.length,
              itemBuilder: (state, i) {
                final item = AppStrings.categorizedUserInterests["Passion"]![i];
                final selected = state.selected(item);
                final isLimitReached = state.value.length >= 2 && !selected;

                return CheckboxListTile(
                  activeColor: AppColors.primaryColor,
                  value: selected,
                  onChanged: isLimitReached
                      ? null // disables unselected items if limit reached
                      : state.onSelected(item),
                  title: ChoiceText(
                    style: Theme.of(context).textTheme.bodyMedium,
                    highlightColor: AppColors.floralWhite,
                    item,
                    highlight: state.search?.value,
                  ),
                );
              },

              modalHeaderBuilder: ChoiceModal.createHeader(
                automaticallyImplyLeading: false,
                title: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 2.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        EnumLocale.chooseOption.name.tr,
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          color: AppColors.primaryColor,
                          fontSize: 19.sp,
                        ),
                      ),

                      IconButton(
                        onPressed: () => Get.back(),

                        icon: Icon(
                          state.passion.isNotEmpty
                              ? FontAwesomeIcons.solidCircleCheck
                              : FontAwesomeIcons.circleXmark,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              promptDelegate: ChoicePrompt.delegateBottomSheet(
                backgroundColor: AppColors.floralWhite,
                maxHeightFactor: 0.5,

                /// Override tileBuilder to hide trailing icon and label
              ),

              anchorBuilder: (state, openModal) {
                return InkWell(
                  onTap: openModal,
                  child: SizedBox(
                    height: 70.h,
                    width: double.maxFinite,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Center(
                        child: Text(
                          (state.value.isEmpty)
                              ? EnumLocale
                                    .chooseOption
                                    .name
                                    .tr // empty text = no placeholder
                              : state.value.join(
                                  ', ',
                                ), // or use .label if single select
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

//-----------------Next Button---------------
class PassionNextButton extends StatelessWidget {
  PassionNextButton({super.key});
  final AppGetStorage app = AppGetStorage();
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CreateProfileBloc, CreateProfileState>(
      builder: (context, state) {
        return CommonButton(
          onPressed: () {
            if (state.passion.isNotEmpty &&
                state.food.isNotEmpty &&
                state.adventure.isNotEmpty) {
              app.setPageNumber(8);
              Get.toNamed(AppRoutes.description);
            } else {
              snackBarMessage(
                context,
                EnumLocale.interestsRequired.name.tr,
                Theme.of(context),
              );
            }
          },
          buttonText: EnumLocale.next.name.tr,
        );
      },
    );
  }
}
