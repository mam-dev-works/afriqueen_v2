import 'package:afriqueen/common/widgets/circular_indicator.dart';
import 'package:afriqueen/features/home/bloc/home_bloc.dart';
import 'package:afriqueen/features/home/bloc/home_state.dart';
import 'package:afriqueen/features/home/screen/data_fetched_screen.dart';
import 'package:afriqueen/features/home/screen/error_home_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:afriqueen/features/home/repository/home_repository.dart';

import '../bloc/home_event.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HomeRepository _homeRepository = HomeRepository();

  @override
  void initState() {
    super.initState();
    _updateLocationInBackground();
  }

  Future<void> _updateLocationInBackground() async {
    // Update location in background without waiting for result
    _homeRepository.updateLocation().then((_) {
      debugPrint('Location updated in background');
    }).catchError((error) {
      debugPrint('Error updating location in background: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeBloc(repo: _homeRepository)..add(HomeUsersProfileList()),
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          return switch (state) {
            //----------Loading--------------------
            Loading() => const CustomCircularIndicator(),
            //----------------- Get Error--------------------
            Error() => const HomeErrorContent(),
            //---------------Empty Data - Show content with empty list instead of NoData screen--------------------------
            HomeDataIsEmpty() => const HomeDataContent(),
            //---------------After Data Fetched--------------------
            _ => const HomeDataContent(),
          };
        },
      ),
    );
  }
}
