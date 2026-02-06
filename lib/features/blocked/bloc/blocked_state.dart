// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:afriqueen/features/home/model/home_model.dart';
import 'package:equatable/equatable.dart';

//-----------------------------Blocked State-----------------------------
class BlockedState extends Equatable {
  final List<HomeModel> blockedUserList;
  const BlockedState({
    required this.blockedUserList,
  });

  @override
  List<Object> get props => [blockedUserList];
}

final class BlockedInitial extends BlockedState {
  BlockedInitial() : super(blockedUserList: []);
}

final class BlockedUsersLoading extends BlockedState {
  BlockedUsersLoading() : super(blockedUserList: []);
}

final class BlockedUsersError extends BlockedState {
  final String errorMessage;

  BlockedUsersError.fromState(BlockedState state,
      {required this.errorMessage})
      : super(blockedUserList: state.blockedUserList);

  @override
  List<Object> get props => [errorMessage];
}

final class BlockedDataEmpty extends BlockedState {
  BlockedDataEmpty() : super(blockedUserList: []);
} 