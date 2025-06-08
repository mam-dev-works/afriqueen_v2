import 'package:afriqueen/common/constant/constant_colors.dart';
import 'package:afriqueen/features/home/bloc/home_bloc.dart';
import 'package:afriqueen/features/home/bloc/home_state.dart';
import 'package:afriqueen/features/home/model/home_model.dart';
import 'package:afriqueen/features/match/widget/card_screen_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CardScreen extends StatelessWidget {
  const CardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<HomeBloc, HomeState, List<HomeModel?>>(
      selector: (state) => state.data,
      builder: (context, userData) {
        return Scaffold(
          body: SafeArea(
              child: Center(
            child: SizedBox(
              height: 540,
              child: CardSwiper(
                  duration: Duration(milliseconds: 100),
                  numberOfCardsDisplayed: 2,
                  padding: EdgeInsetsGeometry.symmetric(horizontal: 5.w),
                  cardBuilder: (
                    context,
                    index,
                    horizontalThresholdPercentage,
                    verticalThresholdPercentage,
                  ) {
                    final item = userData[index];
                    return Container(
                      width: double.maxFinite,
                      decoration: BoxDecoration(
                        color: AppColors.floralWhite,
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border(
                          left: BorderSide(color: AppColors.grey, width: 1.w),
                          right: BorderSide(color: AppColors.grey, width: 1.w),
                          bottom: BorderSide(color: AppColors.grey, width: 1.w),
                        ),
                      ),
                      child: Align(
                        alignment: AlignmentDirectional.topCenter,
                        child: Column(
                          spacing: 5.h,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ImageAndStatus(user: item!),
                            ListOfButtons(),
                            UserDetails(user: item),
                            Interests(
                              user: item,
                            ),
                            Description(user: item)
                          ],
                        ),
                      ),
                    );
                  },
                  cardsCount: userData.length),
            ),
          )),
        );
      },
    );
  }
}
