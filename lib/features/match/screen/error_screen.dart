import 'package:afriqueen/common/localization/enums/enums.dart';
import 'package:afriqueen/features/home/bloc/home_bloc.dart';
import 'package:afriqueen/features/home/bloc/home_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class ErrorWhileFetching extends StatelessWidget {
  const ErrorWhileFetching({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<HomeBloc, HomeState, String?>(
      selector: (state) {
        if (state is Error) {
          return state.error;
        }
        return EnumLocale.defaultError.name.tr;
      },
      builder: (context, message) {
        return Scaffold(
          body: Center(
            child:
                Text(message!, style: Theme.of(context).textTheme.bodyMedium),
          ),
        );
      },
    );
  }
}
