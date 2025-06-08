// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:afriqueen/common/constant/constant_colors.dart';
import 'package:afriqueen/common/widgets/seniority.dart';
import 'package:afriqueen/features/archive/bloc/archive_bloc.dart';
import 'package:afriqueen/features/archive/bloc/archive_event.dart';
import 'package:afriqueen/features/archive/repository/archive_repository.dart';
import 'package:afriqueen/features/favorite/bloc/favorite_bloc.dart';
import 'package:afriqueen/features/favorite/bloc/favorite_event.dart';
import 'package:afriqueen/features/favorite/repository/favorite_repository.dart';
import 'package:afriqueen/features/home/model/home_model.dart';
import 'package:afriqueen/features/user_details/widgets/user_details_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class UserDetailsScreen extends StatefulWidget {
  UserDetailsScreen({super.key, required this.data});

  final HomeModel data;

  @override
  State<UserDetailsScreen> createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  bool _isScrollingUp = false;
  double _previousOffset = 0;

  @override
  Widget build(BuildContext context) {
    final date = Seniority.formatJoinedTime(widget.data.createdDate);
    final hasValidUrl = widget.data.imgURL.isNotEmpty &&
        Uri.tryParse(widget.data.imgURL)?.hasAbsolutePath == true;
    return MultiRepositoryProvider(
        providers: [
          RepositoryProvider(
            create: (context) => FavoriteRepository(),
          ),
          RepositoryProvider(
            create: (context) => ArchiveRepository(),
          ),
        ],
        child: MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) =>
                  FavoriteBloc(repository: context.read<FavoriteRepository>())
                    ..add(FavoriteUsersFetched()),
            ),
            BlocProvider(
              create: (context) =>
                  ArchiveBloc(repository: context.read<ArchiveRepository>())
                    ..add(ArchiveUsersFetched()),
            ),
          ],
          child: Scaffold(
            body: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification is ScrollUpdateNotification) {
                  final currentOffset = notification.metrics.pixels;

                  setState(() {
                    _isScrollingUp = currentOffset < _previousOffset;
                    _previousOffset = currentOffset;
                  });
                }
                return false;
              },
              child: CustomScrollView(
                slivers: [
                  //----------------------AppBar------------------------------
                  UserDetailsAppBar(
                    isScrollingUp: _isScrollingUp,
                    name: widget.data.pseudo,
                  ),
                  SliverFillRemaining(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.w),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            //---------------container------------------
                            Container(
                              width: double.maxFinite,
                              decoration: BoxDecoration(
                                color: AppColors.blue.withValues(alpha: 0.1),
                                shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border(
                                  left: BorderSide(
                                      color: AppColors.grey, width: 1.w),
                                  right: BorderSide(
                                      color: AppColors.grey, width: 1.w),
                                  bottom: BorderSide(
                                      color: AppColors.grey, width: 1.w),
                                ),
                              ),
                              child: Column(
                                spacing: 5.h,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  //------------Image and status---------------------------
                                  StackWidget(
                                      hasValidUrl: hasValidUrl, widget: widget),

                                  //-------------age of account-----------------------
                                  CreatedDate(date: date),
                                  SizedBox(
                                    height: 5.h,
                                  ),
                                  //-----------------RowList of Button------------------------
                                  ButtonList(model: widget.data),
                                  //------User  Details like name , age city------------------------
                                  UserDetails(widget: widget),

                                  // Interests grid-----------------------
                                  Interests(widget: widget),

                                  //---------User description-----------------------
                                  Description(widget: widget),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
