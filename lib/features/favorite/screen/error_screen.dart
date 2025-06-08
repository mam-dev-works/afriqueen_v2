import 'package:afriqueen/features/favorite/bloc/favorite_bloc.dart';
import 'package:afriqueen/features/favorite/bloc/favorite_state.dart';
import 'package:afriqueen/features/favorite/widgets/favorite_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

//------------------Error widget---------------------

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocSelector<FavoriteBloc, FavoriteState, String?>(
      selector: (state) {
        if (state is FavoriteUsersError) {
          return state.errorMessage;
        }

        return null;
      },
      builder: (context, error) {
        return Scaffold(
           appBar: PreferredSize(
            preferredSize: Size.fromHeight(55.h),
            child: FavoriteScreenAppBar(),
          ),
          body: Center(
            child: Text(
              error!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        );
      },
    );
  }
}
