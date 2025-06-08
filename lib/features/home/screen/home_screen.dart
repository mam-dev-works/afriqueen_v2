import 'package:afriqueen/common/widgets/circular_indicator.dart';
import 'package:afriqueen/features/favorite/screen/empty_data_screen.dart';
import 'package:afriqueen/features/home/bloc/home_bloc.dart';
import 'package:afriqueen/features/home/bloc/home_state.dart';
import 'package:afriqueen/features/home/screen/data_fetched_screen.dart';
import 'package:afriqueen/features/home/screen/error_home_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        return switch (state) {
          //----------Loading--------------------
          Loading() => const CustomCircularIndicator(),
          //----------------- Get Error--------------------
          Error() => const HomeErrorContent(),
          //---------------Empty Data--------------------------
          HomeDataIsEmpty() => NoData(),
          //---------------After Data Fetched--------------------
          _ => const HomeDataContent(),
        };
      },
    );
  }
}
