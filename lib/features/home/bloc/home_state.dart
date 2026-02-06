import 'package:afriqueen/features/home/model/home_model.dart';

import 'package:equatable/equatable.dart';

class HomeState extends Equatable {
  final List<HomeModel?> data;
  final List<HomeModel?> profileList;
  final int selectedTabIndex;
  const HomeState({required this.data, required this.profileList, required this.selectedTabIndex});

  HomeState copyWith({List<HomeModel?>? data, List<HomeModel?>? profileList, int? selectedTabIndex}) =>
      HomeState(
          data: data ?? this.data,
          profileList: profileList ?? this.profileList,
          selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex);

  factory HomeState.initial() {
    return HomeState(data: [], profileList: [], selectedTabIndex: 0);
  }
  @override
  List<Object> get props => [data, profileList, selectedTabIndex];
}

final class HomeInitial extends HomeState {
  HomeInitial() : super(data: [], profileList: [], selectedTabIndex: 0);
}

final class Loading extends HomeState {
  Loading.fromState(HomeState state)
      : super(data: state.data, profileList: state.profileList, selectedTabIndex: state.selectedTabIndex);
}

final class Error extends HomeState {
  final String error;
  Error.fromState(HomeState state, {required this.error})
      : super(data: state.data, profileList: state.profileList, selectedTabIndex: state.selectedTabIndex);
  @override
  List<Object> get props => [error];
}

final class HomeDataIsEmpty extends HomeState {
  HomeDataIsEmpty.fromState(HomeState state)
      : super(data: state.data, profileList: state.profileList, selectedTabIndex: state.selectedTabIndex);
}
