import 'package:afriqueen/common/constant/constant_colors.dart';
import 'package:afriqueen/common/constant/constant_strings.dart';
import 'package:afriqueen/common/localization/enums/enums.dart';
import 'package:afriqueen/common/widgets/common_button.dart';
import 'package:afriqueen/features/wellcome/bloc/wellcome_bloc.dart';
import 'package:afriqueen/features/wellcome/bloc/wellcome_event.dart';
import 'package:afriqueen/features/wellcome/bloc/wellcome_state.dart';
import 'package:afriqueen/routes/app_routes.dart';
import 'package:afriqueen/services/storage/get_storage.dart';

import 'package:cool_dropdown/cool_dropdown.dart';
import 'package:cool_dropdown/models/cool_dropdown_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

//------------------------Next Button ----------------------------------
class NextButton extends StatelessWidget {
  NextButton({super.key});

  final AppGetStorage app = AppGetStorage();

  @override
  Widget build(BuildContext context) {
    return CommonButton(
      onPressed: () async {
        app.setHasOpenedApp();
        Get.offAllNamed(AppRoutes.login);
      },

      buttonText: EnumLocale.next.name.tr,
    );
  }
}

//--------------------Welcome page discription----------------------------
class WelcomeDiscription extends StatelessWidget {
  const WelcomeDiscription({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      EnumLocale.welcomeDescriptionText.name.tr,
      style: Theme.of(context).textTheme.bodySmall,
    );
  }
}

//-----------------Wellcome Text      and  langugage selector drop down-----------------------------
class WellcomeTextAndDropDown extends StatelessWidget {
  const WellcomeTextAndDropDown({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          EnumLocale.welcome.name.tr,
          style: Theme.of(context).textTheme.bodyLarge,
        ),

        DropDownForLanguage(),
      ],
    );
  }
}

//------------------Languages of app ------------------------
class DropDownForLanguage extends StatelessWidget {
  DropDownForLanguage({super.key});

  final DropdownController controller = DropdownController();

  final List<CoolDropdownItem<String>> country = [
 
    CoolDropdownItem(
      label: "Français",
      value: "fr",
      icon: Image.asset(AppStrings.fr, height: 30.h, width: 30.w),
      selectedIcon: Image.asset(AppStrings.fr, height: 30.h, width: 30.w),
    ),
       CoolDropdownItem(
      label: "English",
      value: "en",
      icon: Image.asset(AppStrings.us, height: 30.h, width: 30.w),
      selectedIcon: Image.asset(AppStrings.us, height: 30.h, width: 30.w),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WellcomeBloc, WellcomeState>(
      builder: (context, state) {
        final defaultItem = country.firstWhere(
          (item) => item.value == state.languageCode,
          orElse: () => country[0],
        );

        return SizedBox(
          height: 50.h,
          width: 90.w,
          child: CoolDropdown(
            controller: controller,
            dropdownList: country,
            defaultItem: defaultItem,
            onChange: (value) {
              context.read<WellcomeBloc>().add(
                ChangeLanguageEvent(languageCode: value),
              );
              controller.close();
            },
            dropdownItemOptions: DropdownItemOptions(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
            ),

            dropdownOptions: DropdownOptions(width: 130.w),
            resultOptions: ResultOptions(
              render: ResultRender.icon,
              placeholder: "Select Language",
              alignment: Alignment.centerRight,
              placeholderTextStyle: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey,
              ),
              boxDecoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: AppColors.primaryColor),
              ),
            ),
          ),
        );
      },
    );
  }
}

//-------------------center image logo----------------------------

class CenterImage extends StatefulWidget {
  const CenterImage({super.key});

  @override
  State<CenterImage> createState() => _CenterImageState();
}

class _CenterImageState extends State<CenterImage> {
  final image = AssetImage(AppStrings.couple);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      precacheImage(image, context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(child: Image(image: image));
  }
}
