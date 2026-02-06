import 'package:afriqueen/common/widgets/circular_indicator.dart';
import 'package:afriqueen/features/archive/screen/error_screen.dart';
import 'package:afriqueen/features/archive/screen/fetched_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/archive_bloc.dart';
import '../bloc/archive_state.dart';
import 'empty_data_screen.dart';

class ArchiveScreen extends StatelessWidget {
  const ArchiveScreen({super.key});
//-----------------------------Archive Screeen----------------------------------------
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ArchiveBloc, ArchiveState>(
      builder: (context, state) {
        return switch (state) {
          //-----------initial loading---------------------------
          ArchiveUsersLoading() => const CustomCircularIndicator(),
          //------------------Error Screening -----------------------------
          ArchiveUsersError() => const ErrorScreen(),
          //------------empty---------------
          ArchiveDataEmpty() => const NoData(),
          //-------------Data Fetch screen -------------------
          _ => const FetchedScreen(),
        };
      },
    );
  }
}
