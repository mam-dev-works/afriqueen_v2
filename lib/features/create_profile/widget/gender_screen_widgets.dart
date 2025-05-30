
import 'package:afriqueen/common/constant/constant_colors.dart';
import 'package:afriqueen/common/localization/enums/enums.dart';
import 'package:afriqueen/common/widgets/common_button.dart';
import 'package:afriqueen/features/create_profile/bloc/create_profile_bloc.dart';
import 'package:afriqueen/features/create_profile/bloc/create_profile_event.dart';
import 'package:afriqueen/features/create_profile/bloc/create_profile_state.dart';
import 'package:afriqueen/routes/app_routes.dart';
import 'package:afriqueen/services/storage/get_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';




// -----------------------------Gender screen components-----------------------------------

//----------------Text Regarding gender discription--------------------------
class GenderDiscription extends StatelessWidget {
  const GenderDiscription({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      EnumLocale.genderDescription.name.tr,
      style: Theme.of(context).textTheme.bodySmall,
    );
  }
}

//----------------Text Regarding gender Title--------------------------
class GenderTitle extends StatelessWidget {
  const GenderTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      EnumLocale.genderTitle.name.tr,

      style: Theme.of(context).textTheme.bodyLarge,
    );
  }
}

//------------------------Next Button ----------------------------------
class GenderNextButton extends StatelessWidget {
  GenderNextButton({super.key});

  final AppGetStorage app = AppGetStorage();

  @override
  Widget build(BuildContext context) {
    return CommonButton(
      onPressed: () {
        app.setPageNumber(4);
        Get.offAllNamed(AppRoutes.age);
      },
      buttonText: EnumLocale.next.name.tr,
    );
  }
}

//----------------Female gender---------------------

class Female extends StatelessWidget {
  const Female({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 60.h,
        width: 225.w,
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(color: AppColors.primaryColor, width: 1.w),
          borderRadius: BorderRadius.circular(8.r),
        ),

        child: Center(
          child: ListTile(
            leading: Icon(CupertinoIcons.person),
            title: Text(
              EnumLocale.genderFemale.name.tr,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            trailing: BlocBuilder<CreateProfileBloc, CreateProfileState>(
              builder: (context, state) {
                return Radio<String>(
                  activeColor: AppColors.green,

                  value: EnumLocale.genderFemale.name.tr,
                  groupValue: state.gender,
                  onChanged:
                      (value) => context.read<CreateProfileBloc>().add(
                        GenderChanged(gender: value!),
                      ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

//----------------Male gender---------------------
class Male extends StatelessWidget {
  const Male({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 60.h,
        width: 225.w,
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(color: AppColors.primaryColor, width: 1.w),
          borderRadius: BorderRadius.circular(8.r),
        ),

        child: Center(
          child: ListTile(
            leading: Icon(CupertinoIcons.person),
            title: Text(
              EnumLocale.genderMale.name.tr,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            trailing: BlocBuilder<CreateProfileBloc, CreateProfileState>(
              builder: (context, state) {
                return Radio<String>(
                  activeColor: AppColors.green,

                  value: EnumLocale.genderMale.name.tr,
                  groupValue: state.gender,
                  onChanged:
                      (value) => context.read<CreateProfileBloc>().add(
                        GenderChanged(gender: value!),
                      ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
