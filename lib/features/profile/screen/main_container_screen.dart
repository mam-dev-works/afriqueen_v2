import 'package:afriqueen/common/constant/constant_colors.dart';
import 'package:afriqueen/common/localization/enums/enums.dart';
import 'package:afriqueen/features/profile/bloc/profile_bloc.dart';
import 'package:afriqueen/features/profile/bloc/profile_state.dart';
import 'package:afriqueen/features/profile/widget/profile_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_utils/get_utils.dart';

//---------------Main Container--------------------
class MainContainer extends StatelessWidget {
  const MainContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<ProfileBloc, ProfileState, String>(
      selector: (state) => state.data.imgURL,
      builder: (context, imgUrl) {
        final hasValidUrl =
            imgUrl.isNotEmpty && Uri.tryParse(imgUrl)?.hasAbsolutePath == true;
        return hasValidUrl
            ? Container(
                width: double.maxFinite.w,
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //---------------User Profile Image--------------------
                    ProfileImage(),
                    SizedBox(height: 16.h),
                    
                    //---------------User Profile Details--------------------
                    UserDetails(),
                    SizedBox(height: 24.h),

                    //------------------------------ user interests------------------------------
                    UserInterestsList(),
                    SizedBox(height: 24.h),

                    //-----------Account age----------------------
                    UserSeniority(),
                    SizedBox(height: 24.h),

                    //---------------Description--------------------
                    DescriptionText(),
                    SizedBox(height: 24.h),
                  ],
                ),
              )
            : Center(
                child: Text(
                  EnumLocale.defaultError.name.tr,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              );
      },
    );
  }
}
