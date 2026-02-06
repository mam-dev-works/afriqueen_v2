import 'package:afriqueen/common/widgets/loading.dart';
import 'package:afriqueen/common/widgets/snackbar_message.dart';
import 'package:afriqueen/common/widgets/steps.dart';
import 'package:afriqueen/features/create_profile/bloc/create_profile_bloc.dart';
import 'package:afriqueen/features/create_profile/bloc/create_profile_state.dart';
import 'package:afriqueen/features/create_profile/widget/upload_image_screen_widgets.dart';
import 'package:afriqueen/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

//------------------------------------Upload Image for screen sent ---------------------------------------
class UploadImageScreen extends StatelessWidget {
  UploadImageScreen({super.key});

  final box = GetStorage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false),
      body: SafeArea(
        child: BlocListener<CreateProfileBloc, CreateProfileState>(
          listener: _listener,
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 10.h,
                children: [
                  //---------------Stepper to show in which step they are in profile creation------------------------
                  const CustomSteps(currentStep: 7),

                  //-------------Title  text----------------------
                  const UploadImageTitle(),

                  //-------------Description text----------------------
                  const UploadImageDescription(),
                  //------------Center image logo---------------------
                  SizedBox(height: 10.h),
                  const UploadImageCenterLogo(),

                  SizedBox(height: 50.h),

                  // ---------------Submit Button--------------------------------------------
                  SubmitButton(),
                  SizedBox(height: 10.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _listener(context, state) {
    if (state is Loading) {
      customLoading(context);
    }

    if (state is Error) {
      Get.back();
      snackBarMessage(context, state.errorMessage.tr, Theme.of(context));
      debugPrint("Error :${state.errorMessage}");
    }

    if (state is Success) {
      box.remove('pageNumber');
      box.remove('pseudo');
      box.remove('sex');
      box.remove('age');
      box.remove('country');
      box.remove('city');
      box.remove('friendship');
      box.remove('passion');
      box.remove('love');
      box.remove('sports');
      box.remove('food');
      box.remove('adventure');
      box.remove('imageURL');
      box.remove('description');
      Get.offAllNamed(
        AppRoutes.main,
      );
    }
  }
}
