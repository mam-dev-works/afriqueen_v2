import 'package:afriqueen/common/widgets/circular_indicator.dart';
import 'package:afriqueen/features/favorite/bloc/favorite_bloc.dart';
import 'package:afriqueen/features/favorite/bloc/favorite_state.dart';
import 'package:afriqueen/features/favorite/screen/empty_data_screen.dart';
import 'package:afriqueen/features/favorite/screen/error_screen.dart';
import 'package:afriqueen/features/favorite/screen/fetched_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});
//-----------------------------Fav Screeen----------------------------------------
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FavoriteBloc, FavoriteState>(
      builder: (context, state) {
        return switch (state) {
          //-----------initial loading---------------------------
          FavoriteUsersLoading() => const CustomCircularIndicator(),
          //------------------Error Screening -----------------------------
          FavoriteUsersError() => const ErrorScreen(),
          //------------empty---------------
          FavoriteDataEmpty() => const NoData(),
          //-------------Data Fetch screen -------------------
          _ => const FetchedScreen(),
        };
      },
    );
  }
}
