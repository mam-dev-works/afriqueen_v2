import 'package:afriqueen/features/profile/bloc/profile_bloc.dart';
import 'package:afriqueen/features/profile/bloc/profile_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

//---------Widget to show for error state--------------------------
class ProfileErrorContent extends StatelessWidget {
  const ProfileErrorContent({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<ProfileBloc, ProfileState, String?>(
      selector: (state) {
        {
          if (state is Error) {
            return state.error; // error message string
          }
          // no error
        }
        return null;
      },
      builder: (context, errorMessage) {
        return  Scaffold (
          body:  Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.w),
            child: Text(errorMessage!),
          ),
        )
        );
      }
    );
  }
}
