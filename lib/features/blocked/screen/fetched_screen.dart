import 'package:afriqueen/common/constant/constant_colors.dart';
import 'package:afriqueen/features/blocked/widgets/fetched_screen_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../home/model/home_model.dart';
import '../bloc/blocked_bloc.dart';
import '../bloc/blocked_event.dart';
import '../bloc/blocked_state.dart';
import '../widgets/blocked_widgets.dart';

class FetchedScreen extends StatelessWidget {
  const FetchedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BlockedBloc, BlockedState>(
      builder: (context, state) {
        final blockedData = state.blockedUserList;
        
        return Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(55.h),
            child: BlockedScreenAppBar(),
          ),
          body: GridView.builder(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10.w,
              mainAxisSpacing: 12.h,
              childAspectRatio: 0.62,
            ),
            itemCount: blockedData.length,
            itemBuilder: (context, index) {
              final item = blockedData[index];
              final hasValidUrl = item.photos.isNotEmpty &&
                  Uri.tryParse(item.photos.first)?.hasAbsolutePath == true;

              if (!hasValidUrl) return const SizedBox.shrink();

              return BlockedGridCard(
                homeModel: item,
                onUnblock: () {
                  context.read<BlockedBloc>().add(BlockedUsersFetched());
                },
              );
            },
          ),
        );
      },
    );
  }
} 