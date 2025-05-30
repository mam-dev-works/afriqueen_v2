
import 'dart:io';


import 'package:afriqueen/common/constant/constant_strings.dart';
import 'package:afriqueen/common/localization/enums/enums.dart';

import 'package:afriqueen/common/widgets/common_button.dart';
import 'package:afriqueen/common/widgets/snackbar_message.dart';
import 'package:afriqueen/features/create_profile/bloc/create_profile_bloc.dart';
import 'package:afriqueen/features/create_profile/bloc/create_profile_event.dart';
import 'package:afriqueen/features/create_profile/bloc/create_profile_state.dart';

import 'package:afriqueen/services/permissions/permission_handler.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:lottie/lottie.dart';



//------------------------------------Upload Image for screen sent ---------------------------------------

// ---------------Submit Button--------------------------------------------
class SubmitButton extends StatelessWidget {
  SubmitButton({super.key});
  final box = GetStorage();
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CreateProfileBloc, CreateProfileState>(
      builder: (context, state) {
        return CommonButton(
          onPressed: () {
            if (state.imgURL.isNotEmpty) {
              context.read<CreateProfileBloc>().add(SubmitButtonClicked());
            } else {
              snackBarMessage(
                context,
                EnumLocale.uploadImageTitle.name.tr,
                Theme.of(context),
              );
            }
          },

          buttonText: EnumLocale.submit.name.tr,
        );
      },
    );
  }
}

//------------Center image logo---------------------
class UploadImageCenterLogo extends StatelessWidget {
  const UploadImageCenterLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CreateProfileBloc, CreateProfileState>(
      builder: (context, state) {
        return InkWell(
          splashColor: Colors.transparent,
          hoverColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: () async {
            final BuildContext currentContext = context;
            final isGranted =
                Platform.isAndroid
                    ? await AppPermission.requestStoragePermission()
                    : await AppPermission.requestPhotosPermission();
            if (!currentContext.mounted) return;

            if (isGranted) {
              context.read<CreateProfileBloc>().add(PickImg());
            } else {
              snackBarMessage(
                context,
                Platform.isAndroid
                    ? EnumLocale.storagePermissionRequired.name.tr
                    : EnumLocale.photosPermissionDeniedText.name.tr,
                Theme.of(context),
              );
            }
          },
          child: Center(
            child:
                state.imgURL.isNotEmpty
                    ? Container(
                      height: 220.h,
                      width: 250.w,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(12.r),
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: FileImage(File(state.imgURL)),
                        ),
                      ),
                    )
                    : Lottie.asset(
                      AppStrings.uploadImage,
                      height: 220.h,
                      width: 330.w,
                    ),
          ),
        );
      },
    );
  }
}

//-------------Discription text----------------------
class UploadImageDiscription extends StatelessWidget {
  const UploadImageDiscription({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      EnumLocale.uploadImageDescription.name.tr,
      style: Theme.of(context).textTheme.bodySmall,
    );
  }
}

//-------------Title  text----------------------
class UploadImageTitle extends StatelessWidget {
  const UploadImageTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      EnumLocale.uploadImageTitle.name.tr,
      style: Theme.of(context).textTheme.bodyLarge,
    );
  }
}
