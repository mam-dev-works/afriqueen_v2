
import 'package:afriqueen/features/home/bloc/home_bloc.dart';
import 'package:afriqueen/features/home/bloc/home_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

//---------Widget to show for error state--------------------------
class HomeErrorContent extends StatelessWidget {
  const HomeErrorContent({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<HomeBloc, HomeState, String?>(
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
        return  Scaffold(
          body: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.w),
            child: Text(errorMessage!),
          ),
        ),
        );
      },
    );
  }
}
