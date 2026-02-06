import 'package:afriqueen/common/widgets/circular_indicator.dart';
import 'package:afriqueen/features/blocked/screen/error_screen.dart';
import 'package:afriqueen/features/blocked/screen/fetched_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/blocked_bloc.dart';
import '../bloc/blocked_state.dart';
import 'empty_data_screen.dart';

class BlockedScreen extends StatelessWidget {
  const BlockedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BlockedBloc, BlockedState>(
      builder: (context, state) {
        return switch (state) {
          //-----------initial loading---------------------------
          BlockedUsersLoading() => const CustomCircularIndicator(),
          //------------------Error Screening -----------------------------
          BlockedUsersError() => const ErrorScreen(),
          //------------empty---------------
          BlockedDataEmpty() => const NoData(),
          //-------------Data Fetch screen -------------------
          _ => const FetchedScreen(),
        };
      },
    );
  }
} 